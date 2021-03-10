furrybot = {}

dofile(minetest.get_modpath("furrybot") .. "/bot.lua")

furrybot.http = minetest.request_http_api()
furrybot.storage = minetest.get_mod_storage()
local env = assert(minetest.request_insecure_environment())

minetest.register_on_receiving_chat_message(function(msg)
	furrybot.recieve(msg)
end)

minetest.register_chatcommand("fbreload", {
	func = function()
		local func = env.loadfile("clientmods/furrybot/bot.lua")
		func()
	end
})
