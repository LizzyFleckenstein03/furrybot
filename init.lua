furrybot = {}

local http = minetest.request_http_api()
local env = minetest.request_insecure_environment()
local storage = minetest.get_mod_storage()

minetest.register_on_receiving_chat_message(function(msg)
	furrybot.recieve(msg)
end)

minetest.register_chatcommand("fbreload", {
	func = function()
		return furrybot.reload(http, env, storage)
	end
})

loadfile(minetest.get_modpath("furrybot") .. "/bot.lua")()(http, env, storage)
