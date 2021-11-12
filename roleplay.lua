local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.solo_roleplay_command("cry", "cries")
furrybot.solo_roleplay_command("laugh", "laughs")
furrybot.solo_roleplay_command("confused", "is confused", "Be confused")
furrybot.solo_roleplay_command("smile", "smiles")
furrybot.interactive_roleplay_command("hug", "hugs")
furrybot.interactive_roleplay_command("cuddle", "cuddles")
furrybot.interactive_roleplay_command("kiss", "kisses")
furrybot.interactive_roleplay_command("hit", "hits")

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
