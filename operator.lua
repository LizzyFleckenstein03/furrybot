local http, env, storage
local C = minetest.get_color_escape_sequence

function furrybot.is_operator(name)
	return name == minetest.localplayer:get_name() or furrybot.operators[name]
end

function furrybot.operator_command(cmd, func)
	furrybot.commands[cmd] = function (name, ...)
		if furrybot.is_operator(name) then
			func(name, ...)
		else
			furrybot.error_message(name, "Sorry, you need to be an operator run this command: ", cmd)
		end
	end
	furrybot.unsafe_commands[cmd] = true
end

function furrybot.status_command(cmd, list_name, title, status)
	furrybot.operator_command(cmd, function(name, target)
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
	end)
end

function furrybot.list_command(list_name, title)
	return function()
		local names = {}

		for name in pairs(furrybot[list_name]) do
			table.insert(names, name)
		end

		furrybot.send("List of " .. title .. ": " .. table.concat(names, ", "), furrybot.colors.system)
	end
end

furrybot.operator_command("reload", function()
	furrybot.reload(http, env, storage)
end)

furrybot.operator_command("disconnect", function()
	minetest.disconnect()
end)

furrybot.status_command("op", "operators", "an operator", true)
furrybot.status_command("deop", "operators", "an operator", nil)
furrybot.commands.oplist = furrybot.list_command("operators", "operators")

furrybot.status_command("ignore", "ignored", "ignored", true)
furrybot.status_command("unignore", "ignored", "ignored", nil)
furrybot.commands.ignorelist = furrybot.list_command("ignored", "ignored players")

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage

	furrybot.operators = minetest.deserialize(storage:get_string("operators")) or {}
	furrybot.ignored = minetest.deserialize(storage:get_string("ignored")) or {}
end
