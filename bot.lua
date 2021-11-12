furrybot.commands = {}
furrybot.requests = {}

local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.colors = {
	ping = C("#00DCFF"),
	system = C("#FFFA00"),
	error = C("#D70029"),
	detail = C("#FF6683"),
	roleplay = C("#FFD94E"),
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

function furrybot.parse_message(player, message, discord)
	if message:find("!") == 1 and not furrybot.ignored[player] then
		local args = message:sub(2, #message):split(" ")
		local cmd = table.remove(args, 1)
		local def = furrybot.commands[cmd]

		if def then
			if (def.unsafe or def.operator) and discord then
				furrybot.error_message(player, "Sorry, you cannot run this command from discord: ", cmd)
			elseif def.operator and not furrybot.is_operator(player) then
				furrybot.error_message(player, "Sorry, you need to be an operator run this command: ", cmd)
			elseif not def.ignore then
				def.func(player, unpack(args))
			end
		else
			furrybot.error_message(player, "Invalid command", cmd)
		end
	end
end

function furrybot.reload()
	local func, err = env.loadfile("clientmods/furrybot/bot.lua")
	if func then
		local old_fb = table.copy(furrybot)
		local status, init = pcall(func)

		if status then
			status, init = init(http, env, storage)
		end

		if not status then
			furrybot = old_fb
			furrybot.send("Error: " .. furrybot.colors.detail .. init, furrybot.colors.error)
		end
	else
		furrybot.send("Syntax error: " .. furrybot.colors.detail .. err, furrybot.colors.error)
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
	http.fetch({url = url}, function(res)
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

function furrybot.uppercase(str)
	return str:sub(1, 1):upper() .. str:sub(2, #str)
end

function furrybot.interactive_roleplay_command(cmd, action)
	furrybot.commands[cmd] = {
		params = "<player>",
		help = furrybot.uppercase(cmd) .. " another player",
		func = function(name, target)
			if furrybot.online_or_error(name, target) then
				furrybot.send(name .. " " .. action .. " " .. target .. ".", furrybot.colors.roleplay)
			end
		end,
	}
end

function furrybot.solo_roleplay_command(cmd, action, help)
	furrybot.commands[cmd] = {
		help = furrybot.uppercase(cmd),
		func = function(name)
			furrybot.send(name .. " " .. action .. ".", furrybot.colors.roleplay)
		end,
	}
end

function furrybot.request_command(cmd, help, on_request, on_accept, unsafe)
	furrybot.commands[cmd] = {
		unsafe = true,
		params = "<player>",
		help = "Request to " .. help,
		func = function(name, target)
			if furrybot.online_or_error(name, target) and on_request(name, target) ~= false then
				furrybot.requests[target] = {
					origin = name,
					func = on_accept,
				}
			end
		end,
	}
end

function furrybot.is_operator(name)
	return name == minetest.localplayer:get_name() or furrybot.operators[name]
end

function furrybot.list_change_command(cmd, list_name, title, status)
	furrybot.commands[cmd] = {
		operator = true,
		func = function(name, target)
			if target then
				if furrybot[list_name][target] == status then
					furrybot.error_message(name, "Player " .. (status and "already" or "not") .. " " .. title .. ": ", target)
				else
					furrybot[list_name][target] = status
					storage:set_string(list_name, minetest.serialize(furrybot[list_name]))
					furrybot.ping_message(name, "Successfully " .. cmd .. (cmd:sub(#cmd, #cmd) == "e" and "" or "e") .. "d " .. target, furrybot.colors.system)
				end
			else
				furrybot.error_message(name, "You need to specify a player")
			end
		end,
	}
end

function furrybot.list_command(cmd, list_name, title)
	furrybot.commands[cmd] = {
		func = function()
			local names = {}

			for name in pairs(furrybot[list_name]) do
				table.insert(names, name)
			end

			furrybot.send("List of " .. title .. ": " .. table.concat(names, ", "), furrybot.colors.system)
		end,
	}
end

furrybot.commands.cmd = {
	ignore = true,
}

furrybot.commands.status = {
	ignore = true,
}

furrybot.commands.help = {
	params = "[<command>]",
	help = "Display help for a commands or show list of available commands",
	func = function(name, command)
		if command then
			local def = furrybot.commands[command]

			if def then
				furrybot.send("!" .. command .. (def.params and " " .. def.params or "") .. ": " .. (def.help or "No description given"), furrybot.colors.system)
			else
				furrybot.error_message(name, "Invalid command", command)
			end
		else
			local commands = {}

			for cmd in pairs(furrybot.commands) do
				table.insert(commands, cmd)
			end

			table.sort(commands)

			furrybot.send("Available commands: " .. table.concat(commands, ", "), furrybot.colors.system)
		end
	end,
}

furrybot.commands.accept = {
	unsafe = true,
	help = "Accept a request",
	func = function(name)
		local tbl = furrybot.requests[name]
		if tbl then
			furrybot.requests[name] = nil
			tbl.func(tbl.origin, name)
		else
			furrybot.error_message(name, "Nothing to accept")
		end
	end,
}

furrybot.commands.deny = {
	unsafe = true,
	help = "Deny a request",
	func = function(name)
		local tbl = furrybot.requests[name]
		if tbl then
			furrybot.requests[name] = nil
			furrybot.ping_message(name, "Denied request", furrybot.colors.system)
		else
			furrybot.error_message(name, "Nothing to deny")
		end
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage

	furrybot.operators = minetest.deserialize(storage:get_string("operators")) or {}
	furrybot.ignored = minetest.deserialize(storage:get_string("ignored")) or {}

	for _, f in ipairs {"nsfw", "roleplay", "death", "economy", "random", "http", "operator", "bullshit", "marriage", "waifu"} do
		local func, err = env.loadfile("clientmods/furrybot/" .. f .. ".lua")

		if not func then
			return false, err
		end

		func()(http, env, storage)
	end

	furrybot.send("FurryBot - " .. C("#170089") .. "https://github.com/EliasFleckenstein03/furrybot", furrybot.colors.system)

	if furrybot.loaded then
		furrybot.send("Reloaded", furrybot.colors.system)
	else
		furrybot.loaded = true
	end

	return true
end
