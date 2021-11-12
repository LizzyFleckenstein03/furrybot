furrybot = {}

local path = minetest.get_modpath("furrybot")

utf8 = dofile(path .. "/utf8.lua")

local http = minetest.request_http_api()
local env = minetest.request_insecure_environment()
local storage = minetest.get_mod_storage()

libclamity.register_on_chat_message(function(...)
	furrybot.parse_message(...)
end)

loadfile(path .. "/bot.lua")()(http, env, storage)
