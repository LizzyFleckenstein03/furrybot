furrybot.commands = {}
furrybot.requests = {}

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

function furrybot.recieve(msg)
	msg = minetest.strip_colors(msg)
	if msg:find("<") == 1 then
		local idx = msg:find(">")
		local player = msg:sub(2, idx - 1)
		local message = msg:sub(idx + 3, #msg)
		if message:find("!") == 1 then
			local args = message:sub(2, #message):split(" ")
			local cmd = table.remove(args, 1)
			local func = furrybot.commands[cmd]
			if func then
				func(player, unpack(args))
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
	return furrybot.colors.random .. math.random(#list) .. color
end

function furrybot.http_request(url, name, callback)
	furrybot.http.fetch({url = url}, function(res)
		if res.succeeded then
			callback(res.data)
		else
			furrybot.ping_player_error(name, "Request failed with code", res.code)
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

function furrybot.simple_rpg_command(action)
	return function(name, target)
		if furrybot.online_or_error(name, target) then
			furrybot.send(name .. " " .. action .. " " .. target .. ".", furrybot.colors.rpg)
		end
	end
end

function furrybot.request_command(on_request, on_accept)
	return function(name, target)
		if furrybot.online_or_error(name, target) then
			furrybot.requests[target] = {
				origin = name,
				func = on_accept,
			}
			on_request(name, target)
		end
	end
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

function furrybot.commands.deny(name)
	local tbl = furrybot.requests[name]
	if tbl then
		furrybot.requests[name] = nil
		furrybot.ping_message(name, "Denied request")
	else
		furrybot.error_message(name, "Nothing to deny")
	end
end

-- don't bug players that are running ClamityBot commands from discord
function furrybot.commands.status()
end

function furrybot.commands.cmd()
end

-- rpg
furrybot.commands.hug = furrybot.simple_rpg_command("hugs")
furrybot.commands.cuddle = furrybot.simple_rpg_command("cuddles")
furrybot.commands.kiss = furrybot.simple_rpg_command("kisses")
furrybot.commands.hit = furrybot.simple_rpg_command("hits")
furrybot.commands.slap = furrybot.simple_rpg_command("slap")
furrybot.commands.beat = furrybot.simple_rpg_command("beat")

furrybot.commands.sex = furrybot.request_command(function(name, target)
	furrybot.ping_message(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " and " .. target .. " are having sex! OwO", furrybot.colors.rpg)
end)
furrybot.commands.bang = furrybot.commands.sex
furrybot.commands.fuck = furrybot.commands.sex

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
furrybot.commands["8ball"] = furrybot.commands.choose

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

-- send reload message
if furrybot.loaded then
	furrybot.send("Reloaded", furrybot.colors.system)
else
	furrybot.loaded = true
end
