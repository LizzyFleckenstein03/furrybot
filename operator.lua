local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.commands.reload = {
	operator = true,
	func = function()
		furrybot.reload()
	end,
}

furrybot.commands.disconnect = {
	operator = true,
	func = function()
		minetest.disconnect()
	end,
}

furrybot.list_change_command("op", "operators", "an operator", true)
furrybot.list_change_command("deop", "operators", "an operator", nil)
furrybot.list_command("oplist", "operators", "operators")

furrybot.list_change_command("ignore", "ignored", "ignored", true)
furrybot.list_change_command("unignore", "ignored", "ignored", nil)
furrybot.list_command("ignorelist", "ignored", "ignored players")

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
