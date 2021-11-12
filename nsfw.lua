local http, env, storage
local C = minetest.get_color_escape_sequence

function furrybot.get_ascii_genitals(name, begin, middle, ending, seed)
	return begin .. furrybot.repeat_string(middle, furrybot.strrandom(name, seed, 2, 10)) .. ending
end

function furrybot.get_ascii_dick(name)
	return minetest.rainbow(furrybot.get_ascii_genitals(name, "8", "=", "D", 31242))
end

function furrybot.get_ascii_boobs(name)
	return furrybot.get_ascii_genitals(name, "E", "Ξ", "3", 31243)
end

furrybot.commands.dicksize = {
	params = "[<player>]",
	help = "Display the size of your own or another player's dick",
	func = function(name, target)
		target = target or name
		furrybot.send(furrybot.get_ascii_dick(target) .. furrybot.colors.system .. "   ← " .. furrybot.ping(target, furrybot.colors.system) .. "'s Dick", furrybot.colors.system)
	end,
}

furrybot.commands.boobsize = {
	params = "[<player>]",
	help = "Display the size of your own or another player's boobs",
	func = function(name, target)
		target = target or name
		furrybot.send(furrybot.get_ascii_boobs(target) .. furrybot.colors.system .. "   ← " .. furrybot.ping(target, furrybot.colors.system) .. "'s Boobs", furrybot.colors.system)
	end,
}

furrybot.request_command("smellfeet", "smell another player's feet", function(name, target)
	furrybot.ping_message(target, name .. " wants to smell your feet. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.ping_message(name, " you are smelling " .. target .. "'s feet. They are kinda stinky!", furrybot.colors.roleplay)
end)

furrybot.request_command("blowjob", "suck another player's dick", function(name, target)
	furrybot.ping_message(target, name .. " wants to suck your dick. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " is sucking " .. target .. "'s cock. " .. furrybot.get_ascii_dick(target) .. " ˣoˣ ", furrybot.colors.roleplay)
end)

furrybot.request_command("sex", "have sex with another player", function(name, target)
	furrybot.ping_message(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " and " .. target .. " are having sex! OwO", furrybot.colors.roleplay)
end)

furrybot.commands.cum = {
	help = "Cum",
	func = function(name)
		furrybot.send(name .. " is cumming: " .. furrybot.get_ascii_dick(name) .. C("#FFFFFF") .. furrybot.repeat_string("~", math.random(1, 10)), furrybot.colors.roleplay)
	end
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
