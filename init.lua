furrybot = {}

dofile(minetest.get_modpath("furrybot") .. "/bot.lua")

local env = assert(minetest.request_insecure_environment())

minetest.register_on_receiving_chat_message(function(msg)
	furrybot.recieve(msg)
end)

minetest.register_chatcommand("furrybot-reload", {
	func = function()
		furrybot.reload()
	end
})

function furrybot.reload()
	local func = env.loadfile("clientmods/furrybot/bot.lua")
	func()
end
