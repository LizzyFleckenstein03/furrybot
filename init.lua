local commands = {}
local C = minetest.get_color_escape_sequence
local http = minetest.get_http_api()

local function send(msg, color)
	minetest.send_chat_message("/me " .. C("#00FF3C") .. "[" .. C(color or "#FFFA00") .. msg .. C("#00FF3C") .. "]")
end

local function ping(player)
	return C("#00DCFF") .. "@" .. player .. C("#FFFA00")
end

local function ping_player(player, message)
	send(ping(player) .. ": " .. message)
end

local function ping_player_error(player, err, detail)
	ping_player(player, C("#D70029") .. " " .. err ..  " " .. (detail and C("#FF6683") .. "'" .. detail .. "'" .. C("#D70029") or "") .. ".")
end

local function player_online(name)
	for _, n in ipairs(minetest.get_player_names()) do
		if name == n then
			return true
		end
	end
end

minetest.register_on_receiving_chat_message(function(msg)
	msg = minetest.strip_colors(msg)
	if msg:find("<") == 1 then
		local idx = msg:find(">")
		local player = msg:sub(2, idx - 1)
		local message = msg:sub(idx + 3, #msg)
		if message:find("!") == 1 then
			local args = message:sub(2, #message):split(" ")
			local cmd = table.remove(args, 1)
			local func = commands[cmd]
			if func then
				func(player, unpack(args))
			else
				ping_player_error(player, "Invalid command", cmd)
			end
		end
	end
end)

local function check_online(name, target)
	if name == target then
		ping_player_error(name, "You need to specify another player")
	elseif player_online(target) then
		return true
	else
		ping_player_error(name, "Player not online", target)
	end
end

function commands.furhug(name, target)
	if check_online(name, target) then
		send(name .. " hugs " .. target .. ".")
	end
end

commands.furcuddle = commands.furhug

function commands.furkiss(name, target)
	if check_online(name, target) then
		send(name .. " kisses " .. target .. ".")
	end
end

local target_list = {}

function commands.furbang(name, target)
	if check_online(name, target) then
		target_list[target] = function()
			send(ping(name) .. " and " .. ping(target) .. " are having sex! OwO")
		end,
		ping_player(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.")
	end
end

commands.fursex = commands.furbang
commands.furfuck = commands.furbang

function commands.accept(name)
	local func = target_list[name]
	if func then
		func()
	else
		ping_player_error(name, "Nothing to accept")
	end			
end

function commands.deny(name)
	if target_list[name] then
		target_list[name] = nil
		ping_player(name, "Denied request")
	else
		ping_player_error(name, "Nothing to deny")
	end			
end

function commands.furhit(name, target)
	if check_online(name, target) then
		send(name .. " hits " .. target)
	end
end

commands.furslap = commands.furhit

function commands.furhelp()
	local keys = {}
	for k in pairs(commands) do
		table.insert(keys, k)
	end
	send("Available commands: " .. table.concat(keys, ", "))
end

function commands.verse()
	http.fetch_async({
		url = "https://labs.bible.org/api/",
        data = "passage=random&type=json",
	})
end
