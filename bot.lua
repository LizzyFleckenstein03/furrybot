furrybot.commands = {}
furrybot.requests = {}
furrybot.unsafe_commands = {}

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
	if message:find("!") == 1 then
		local args = message:sub(2, #message):split(" ")
		local cmd = table.remove(args, 1)
		local func = furrybot.commands[cmd]
		if func then
			if furrybot.unsafe_commands[cmd] and discord then
				furrybot.error_message(player, "Sorry, you cannot run this command from discord: ", cmd)
			else
				func(player, unpack(args))
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
			return false, furrybot.colors.error .. "Error: " .. furrybot.colors.detail .. init
		end
	else
		return false, furrybot.colors.error .. "Syntax error: " .. furrybot.colors.detail .. err
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

function furrybot.interactive_roleplay_command(action)
	return function(name, target)
		if furrybot.online_or_error(name, target) then
			furrybot.send(name .. " " .. action .. " " .. target .. ".", furrybot.colors.roleplay)
		end
	end
end

function furrybot.solo_roleplay_command(action)
	return function(name)
		furrybot.send(name .. " " .. action .. ".", furrybot.colors.roleplay)
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

-- General purpose commands

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

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage

	for _, f in ipairs {"nsfw", "roleplay", "death", "economy", "random", "http"} do
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
