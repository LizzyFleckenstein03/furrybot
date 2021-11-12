local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.request_command("marry", "marry another player", function(name, target)
	if storage:contains(name .. ".partner", target) then
		furrybot.error_message(name, "You are already married to", storage:get_string(name .. ".partner"))
		return false
	elseif storage:contains(target .. ".partner", name) then
		furrybot.error_message(name, target .. " is already married to", storage:get_string(target .. ".partner"))
		return false
	else
		furrybot.ping_message(target, name .. " proposes to you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
	end
end, function(name, target)
	storage:set_string(name .. ".partner", target)
	storage:set_string(target .. ".partner", name)
	furrybot.send("Congratulations, " .. furrybot.ping(name, furrybot.colors.roleplay) .. "&" .. furrybot.ping(target, furrybot.colors.roleplay) .. ", you are married. You may now kiss :).", furrybot.colors.roleplay)
end, true)

furrybot.commands.divorce = {
	unsafe = true,
	func = function(name)
		if storage:contains(name .. ".partner") then
			local partner = storage:get_string(name .. ".partner")
			storage:set_string(name .. ".partner", "")
			storage:set_string(partner .. ".partner", "")
			furrybot.ping_message(name, "divorces from " .. partner .. " :(", furrybot.colors.roleplay)
		else
			furrybot.error_message(name, "You are not married")
		end
	end,
}

furrybot.commands.partner = {
	func = function(name, target)
		target = target or name
		if storage:contains(target .. ".partner") then
			furrybot.ping_message(name, (target == name and "You are" or target .. " is") .. " married to " .. storage:get_string(target .. ".partner"), furrybot.colors.system)
		else
			furrybot.error_message(name, (target == name and "You are" or target .. " is") .. " not married")
		end
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
