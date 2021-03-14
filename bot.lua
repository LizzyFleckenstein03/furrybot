furrybot.commands = {}
furrybot.requests = {}
furrybot.unsafe_commands = {}

local C = minetest.get_color_escape_sequence

furrybot.colors = {
	ping = C("#00DCFF"),
	system = C("#FFFA00"),
	error = C("#D70029"),
	detail = C("#FF6683"),
	rpg = C("#FFD94E"),
	braces = C("#FFFAC0"),
	info = C("#00FFC3"),
	fun = C("#A0FF24"),
	random = C("#A300BE"),
	money = C("#A11600"),
}

-- helper functions

function furrybot.send(msg, color)
	minetest.send_chat_message("/me " .. furrybot.colors.braces .. "[" .. color .. msg .. furrybot.colors.braces .. "]")
end

function furrybot.ping(player, color)
	return furrybot.colors.ping .. "@" .. player .. color
end

function furrybot.ping_message(player, message, color)
	furrybot.send(furrybot.ping(player, color) .. ": " .. message, "")
end

function furrybot.error_message(player, error, detail)
	furrybot.ping_message(player, error .. (detail and furrybot.colors.detail .. " '" .. detail .. "'" .. furrybot.colors.error or "") .. ".", furrybot.colors.error)
end

function furrybot.recieve(rawmsg)
	local msg = minetest.strip_colors(rawmsg)
	local nameidx = msg:find("<")
	local first_byte = rawmsg:byte(1)
	if nameidx and (first_byte == 60 or first_byte == 27) then
		local idx = msg:find(">")
		local player = msg:sub(nameidx + 1, idx - 1)
		local message = msg:sub(idx + 3, #msg)
		if message:find("!") == 1 then
			local args = message:sub(2, #message):split(" ")
			local cmd = table.remove(args, 1)
			local func = furrybot.commands[cmd]
			if func then
				if furrybot.unsafe_commands[cmd] and first_byte == 27 and rawmsg:sub(2, 12) == "(c@#63d269)" and nameidx == 1 then
					furrybot.error_message(player, "Sorry, you cannot run this command from discord", cmd)
				else
					func(player, unpack(args))
				end
			else
				furrybot.error_message(player, "Invalid command", cmd)
			end
		end
	end
end

function furrybot.player_online(name)
	for _, n in ipairs(minetest.get_player_names()) do
		if name == n then
			return true
		end
	end
end

function furrybot.online_or_error(name, other, allow_self)
	if not other then
		furrybot.error_message(name, "You need to specify a player")
	elseif name == other and not allow_self then
		furrybot.error_message(name, "You need to specify a different player than yourself")
	elseif furrybot.player_online(other) then
		return true
	else
		furrybot.error_message(name, "Player not online", other)
	end
end

function furrybot.choose(list, color)
	return furrybot.colors.random .. list[math.random(#list)] .. color
end

function furrybot.random(min, max, color)
	return furrybot.colors.random .. math.random(min, max) .. color
end

function furrybot.http_request(url, name, callback)
	furrybot.http.fetch({url = url}, function(res)
		if res.succeeded then
			callback(res.data)
		else
			furrybot.error_message(name, "Request failed with code", res.code)
		end
	end)
end

function furrybot.json_http_request(url, name, callback)
	furrybot.http_request(url, name, function(raw)
		local data = minetest.parse_json(raw)
		callback(data[1] or data)
	end)
end

function furrybot.strrandom(str, seed, ...)
	local v = 0
	local pr = PseudoRandom(seed)
	for i = 1, #str do
		v = v + str:byte(i) * pr:next()
	end
	return PseudoRandom(v):next(...)
end

function furrybot.repeat_string(str, times)
	local msg = ""
	for i = 1, times do
		msg = msg .. str
	end
	return msg
end

function furrybot.interactive_rpg_command(action)
	return function(name, target)
		if furrybot.online_or_error(name, target) then
			furrybot.send(name .. " " .. action .. " " .. target .. ".", furrybot.colors.rpg)
		end
	end
end

function furrybot.solo_rpg_command(action)
	return function(name)
		furrybot.send(name .. " " .. action .. ".", furrybot.colors.rpg)
	end
end

function furrybot.request_command(on_request, on_accept)
	return function(name, target)
		if furrybot.online_or_error(name, target) and on_request(name, target) ~= false then
			furrybot.requests[target] = {
				origin = name,
				func = on_accept,
			}
		end
	end
end

function furrybot.get_money(name)
	local key = name .. ".money"
	if furrybot.storage:contains(key) then
		return furrybot.storage:get_int(key)
	else
		return 100
	end
end

function furrybot.set_money(name, money)
	furrybot.storage:set_int(name .. ".money", money)
end

function furrybot.add_money(name, add)
	local money = furrybot.get_money(name)
	furrybot.set_money(name, money + add)
end

function furrybot.take_money(name, remove)
	local money = furrybot.get_money(name)
	local new = money - remove
	if new < 0 then
		return false
	else
		furrybot.set_money(name, new)
		return true
	end
end

function furrybot.money(money, color)
	return furrybot.colors.money .. "$" .. money .. color
end

-- Commands

-- system
function furrybot.commands.help()
	local keys = {}
	for k in pairs(furrybot.commands) do
		table.insert(keys, k)
	end
	furrybot.send("Available commands: " .. table.concat(keys, ", "), furrybot.colors.system)
end

function furrybot.commands.accept(name)
	local tbl = furrybot.requests[name]
	if tbl then
		furrybot.requests[name] = nil
		tbl.func(tbl.origin, name)
	else
		furrybot.error_message(name, "Nothing to accept")
	end
end
furrybot.unsafe_commands.accept = true

function furrybot.commands.deny(name)
	local tbl = furrybot.requests[name]
	if tbl then
		furrybot.requests[name] = nil
		furrybot.ping_message(name, "Denied request", furrybot.colors.system)
	else
		furrybot.error_message(name, "Nothing to deny")
	end
end
furrybot.unsafe_commands.deny = true

-- don't bug players that are running ClamityBot commands from discord
function furrybot.commands.status()
end

function furrybot.commands.cmd()
end

-- rpg
furrybot.commands.cry = furrybot.solo_rpg_command("cries")
furrybot.commands.laugh = furrybot.solo_rpg_command("laughs")
furrybot.commands.confused = furrybot.solo_rpg_command("is confused")
furrybot.commands.hug = furrybot.interactive_rpg_command("hugs")
furrybot.commands.cuddle = furrybot.interactive_rpg_command("cuddles")
furrybot.commands.kiss = furrybot.interactive_rpg_command("kisses")
furrybot.commands.hit = furrybot.interactive_rpg_command("hits")
furrybot.commands.slap = furrybot.interactive_rpg_command("slaps")
furrybot.commands.beat = furrybot.interactive_rpg_command("beats")
furrybot.commands.lick = furrybot.interactive_rpg_command("licks")

furrybot.commands.sex = furrybot.request_command(function(name, target)
	furrybot.ping_message(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " and " .. target .. " are having sex! OwO", furrybot.colors.rpg)
end)
furrybot.commands.bang = furrybot.commands.sex
furrybot.commands.fuck = furrybot.commands.sex

furrybot.commands.marry = furrybot.request_command(function(name, target)
	if furrybot.storage:contains(name .. ".partner", target) then
		furrybot.error_message(name, "You are already married to", furrybot.storage:get_string(name .. ".partner"))
		return false
	elseif furrybot.storage:contains(target .. ".partner", name) then
		furrybot.error_message(name, target .. " is already married to", furrybot.storage:get_string(name .. ".partner"))
		return false
	else
		furrybot.ping_message(target, name .. " proposes to you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
	end
end, function(name, target)
	furrybot.storage:set_string(name .. ".partner", target)
	furrybot.storage:set_string(target .. ".partner", name)
	furrybot.send("Congratulations, " .. furrybot.ping(name, furrybot.colors.rpg) .. "&" .. furrybot.ping(target, furrybot.colors.rpg) .. ", you are married. You may now kiss :).", furrybot.colors.rpg)
end)
furrybot.commands.propose = furrybot.commands.marry
furrybot.unsafe_commands.marry = true
furrybot.unsafe_commands.propose = true

function furrybot.commands.divorce(name)
	if furrybot.storage:contains(name .. ".partner") then
		local partner = furrybot.storage:get_string(name .. ".partner")
		furrybot.storage:set_string(name .. ".partner", "")
		furrybot.storage:set_string(partner .. ".partner", "")
		furrybot.ping_message(name, "divorces from " .. partner .. " :(", furrybot.colors.rpg)
	else
		furrybot.error_message(name, "You are not married")
	end
end
furrybot.unsafe_commands.divorce = true

function furrybot.commands.partner(name, target)
	target = target or name
	if furrybot.storage:contains(target .. ".partner") then
		furrybot.ping_message(name, (target == name and "You are" or target .. " is") .. " married to " .. furrybot.storage:get_string(target .. ".partner"), furrybot.colors.system)
	else
		furrybot.error_message(name, (target == name and "You are" or target .. " is") .. " not married")
	end
end
furrybot.commands.married = furrybot.commands.partner

-- misc
function furrybot.commands.rolldice(name)
	furrybot.ping_message(name, "rolled a dice and got a " .. furrybot.random(1, 6, furrybot.colors.system) .. ".", furrybot.colors.system)
end

function furrybot.commands.coinflip(name)
	furrybot.ping_message(name, "flipped a coin and got " .. furrybot.choose({"Heads", "Tails"}, furrybot.colors.system) .. ".", furrybot.colors.system)
end

function furrybot.commands.choose(name, ...)
	local options = {...}
	if #options > 1 then
		furrybot.ping_message(name, "I choose " .. furrybot.choose(options, "", furrybot.colors.system) .. ".", furrybot.colors.system)
	else
		furrybot.error_message(name, "Not enough options")
	end
end

function furrybot.commands.dicksize(name, target)
	target = target or name
	local size = furrybot.strrandom(target, 31242, 2, 10)
	local dick = furrybot.repeat_string("=", size) .. "D"
	furrybot.send(dick .. furrybot.colors.system .. "   <= " .. furrybot.ping(target, furrybot.colors.system) .. "'s Dick", C("#FF4DE1"))
end
furrybot.commands.cocksize = furrybot.commands.dicksize

-- fun
function furrybot.commands.verse(name)
	furrybot.json_http_request("https://labs.bible.org/api/?type=json&passage=random", name, function(data)
		furrybot.send(data.text .. furrybot.colors.info .. "[" .. data.bookname .. " " .. data.chapter .. "," .. data.verse .. "]", furrybot.colors.fun)
	end)
end

function furrybot.commands.define(name, word)
	if word then
		furrybot.json_http_request("https://api.dictionaryapi.dev/api/v1/entries/en_US/" .. word, name, function(data)
			local meaning = data.meaning
			local selected = meaning.exclamation or meaning.noun or meaning.verb or meaning.adjective or meaning["transitive verb"] or meaning.adverb or meaning["relative adverb"]
			if not selected then
				print(dump(meaning))
				furrybot.error_message(name, "Error in parsing response")
			else
				furrybot.send(word:sub(1, 1):upper() .. word:sub(2, #word):lower() .. ": " .. furrybot.colors.fun .. selected[1].definition, furrybot.colors.info)
			end
		end)
	else
		furrybot.error_message(name, "You need to specify a word")
	end
end

function furrybot.commands.insult(name, target)
	if furrybot.online_or_error(name, target, true) then
		furrybot.http_request("https://insult.mattbas.org/api/insult", name, function(data)
			furrybot.ping_message(target, data, furrybot.colors.fun)
		end)
	end
end

function furrybot.commands.joke(name, first, last)
	if not first then
		first = "Chuck"
		last = "Norris"
	elseif not last then
		last = ""
	end
	furrybot.json_http_request("http://api.icndb.com/jokes/random?firstName=" .. first .. "&lastName=" .. last, name, function(data)
		local joke = data.value.joke:gsub("&quot;", "\""):gsub("  ", " ")
		furrybot.send(joke, furrybot.colors.fun)
	end)
end

function furrybot.commands.question(name)
	furrybot.json_http_request("https://8ball.delegator.com/magic/JSON/anything", name, function(data)
		furrybot.ping_message(name, data.magic.answer, furrybot.colors.fun)
	end)
end
furrybot.commands["8ball"] = furrybot.commands.question

-- economy
function furrybot.commands.money(name, target)
	target = target or name
	furrybot.ping_message(name, (target == name and "You have " or target .. " has ") .. furrybot.money(furrybot.get_money(target), furrybot.colors.system) .. ".", furrybot.colors.system)
end
furrybot.commands.balance = furrybot.commands.money

function furrybot.commands.pay(name, target, number)
	if furrybot.online_or_error(name, target) then
		local money = tonumber(number or "")
		if not money or money <= 0 or math.floor(money) ~= money then
			furrybot.error_message(name, "Invalid amount of money")
		else
			if furrybot.take_money(name, money) then
				furrybot.add_money(target, money)
				furrybot.ping_message(target, name .. " has payed you " .. furrybot.money(money, furrybot.colors.system) .. ".", furrybot.colors.system)
			else
				furrybot.error_message(name, "You don't have enough money")
			end
		end
	end
end
furrybot.unsafe_commands.pay = true

-- send load message
furrybot.send("FurryBot - " .. C("#170089") .. "https://github.com/EliasFleckenstein03/furrybot", furrybot.colors.system)

if furrybot.loaded then
	furrybot.send("Reloaded", furrybot.colors.system)
else
	furrybot.loaded = true
end
