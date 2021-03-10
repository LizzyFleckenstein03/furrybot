furrybot.commands = {}

local C = minetest.get_color_escape_sequence

function furrybot.send(msg, color)
	minetest.send_chat_message("/me " .. C("#00FF3C") .. "[" .. C(color or "#FFFA00") .. msg .. C("#00FF3C") .. "]")
end

function furrybot.ping(player)
	return C("#00DCFF") .. "@" .. player .. C("#FFFA00")
end

function furrybot.ping_player(player, message)
	furrybot.send(furrybot.ping(player) .. ": " .. message)
end

function furrybot.ping_player_error(player, err, detail)
	furrybot.ping_player(player, C("#D70029") .. " " .. err .. (detail and C("#FF6683") .. " '" .. detail .. "'" .. C("#D70029") or "") .. ".")
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
				furrybot.ping_player_error(player, "Invalid command", cmd)
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

function furrybot.check_online(name, target)
	if not target then
		furrybot.ping_player_error(name, "You need to specify a player")
	elseif name == target then
		furrybot.ping_player_error(name, "You need to specify a different player than yourself")
	elseif furrybot.player_online(target) then
		return true
	else
		furrybot.ping_player_error(name, "Player not online", target)
	end
end

function furrybot.choose(list)
	return list[math.random(#list)]
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
	furrybot.http_request(url, name, function(data)
		callback(minetest.parse_json(data)[1])
	end)
end

function furrybot.rand(str, seed, ...)
	local v = 0
	local pr = PseudoRandom(seed)
	for i = 1, #str do
		v = v + str:byte(i) * pr:next()
	end
	return PseudoRandom(v):next(...)
end

-- commands

function furrybot.commands.hug(name, target)
	if furrybot.check_online(name, target) then
		furrybot.send(name .. " hugs " .. target .. ".")
	end
end

furrybot.commands.cuddle = furrybot.commands.hug

function furrybot.commands.kiss(name, target)
	if furrybot.check_online(name, target) then
		furrybot.send(name .. " kisses " .. target .. ".")
	end
end

furrybot.target_list = {}

function furrybot.commands.bang(name, target)
	if furrybot.check_online(name, target) then
		furrybot.target_list[target] = function()
			furrybot.send(ping(name) .. " and " .. ping(target) .. " are having sex! OwO")
		end,
		furrybot.ping_player(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.")
	end
end

furrybot.commands.sex = furrybot.commands.bang
furrybot.commands.fuck = furrybot.commands.bang

function furrybot.commands.accept(name)
	local func = furrybot.target_list[name]
	if func then
		func()
	else
		furrybot.ping_player_error(name, "Nothing to accept")
	end
end

function furrybot.commands.deny(name)
	if furrybot.target_list[name] then
		furrybot.target_list[name] = nil
		furrybot.ping_player(name, "Denied request")
	else
		furrybot.ping_player_error(name, "Nothing to deny")
	end
end

function furrybot.commands.hit(name, target)
	if furrybot.check_online(name, target) then
		furrybot.send(name .. " hits " .. target)
	end
end

furrybot.commands.slap = furrybot.commands.hit
furrybot.commands.beat = furrybot.commands.hit

function furrybot.commands.help()
	local keys = {}
	for k in pairs(furrybot.commands) do
		table.insert(keys, k)
	end
	furrybot.send("Available commands: " .. table.concat(keys, ", "))
end

function furrybot.commands.verse(name)
	furrybot.json_http_request("https://labs.bible.org/api/?type=json&passage=random", name, function(data)
		furrybot.send(data.text .. C("#00FFC3") .. "[" .. data.bookname .. " " .. data.chapter .. "," .. data.verse .. "]")
	end)
end

function furrybot.commands.define(name, word)
	if word then
		furrybot.json_http_request("https://api.dictionaryapi.dev/api/v1/entries/en_US/" .. word, name, function(data)
			local meaning = data.meaning
			local selected = meaning.exclamation or meaning.noun or meaning.verb or meaning.adjective or meaning["transitive verb"] or meaning.adverb or meaning["relative adverb"]
			if not selected then
				print(dump(meaning))
				furrybot.ping_player_error(name, "Error in parsing response")
			else
				furrybot.send(C("#00FFC3") .. word:sub(1, 1):upper() .. word:sub(2, #word):lower() .. ": " .. C("#FFFA00") .. selected[1].definition)
			end
		end)
	else
		furrybot.ping_player_error(name, "You need to specify a word")
	end
end

function furrybot.commands.insult(name, target)
	if furrybot.check_online(name, target) then
		furrybot.http_request("https://insult.mattbas.org/api/insult", name, function(data)
			furrybot.ping_player(target, data)
		end)
	end
end

function furrybot.commands.rolldice(name)
	furrybot.ping_player(name, "rolled a dice and got a " .. C("#AAFF43") .. math.random(6))
end

function furrybot.commands.coinflip(name)
	furrybot.ping_player(name, "flipped a coin and got " .. C("#AAFF43") .. furrybot.choose({"Heads", "Tails"}))
end

function furrybot.commands.status()
end

function furrybot.commands.cmd()
end

function furrybot.commands.cocksize(name, target)
	target = target or name
	local msg = C("#FF4DE1")
	local size = furrybot.rand(target, 31242, 2, 10)
	for i = 1, size do
		msg = msg .. "="
	end
	msg = msg .. "D"
	furrybot.send(msg .. C("#FFFA00") .. "  <= " .. furrybot.ping(target) .. "'s Cock")
end

furrybot.commands.dicksize = furrybot.commands.cocksize

if furrybot.loaded then
	furrybot.send("Reloaded")
else
	furrybot.loaded = true
end
