furrybot = {}

local http = minetest.request_http_api()
local env = minetest.request_insecure_environment()
local storage = minetest.get_mod_storage()

libclamity.register_on_chat_message(function(...)
	furrybot.parse_message(...)
end)

minetest.register_chatcommand("fbreload", {
	func = function()
		return furrybot.reload(http, env, storage)
	end
})

loadfile(minetest.get_modpath("furrybot") .. "/bot.lua")()(http, env, storage)
