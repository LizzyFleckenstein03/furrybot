local http, env, storage
local C = minetest.get_color_escape_sequence

function furrybot.get_ascii_genitals(name, begin, middle, ending, seed)
	return begin .. furrybot.repeat_string(middle, furrybot.strrandom(name, seed, 2, 10)) .. ending
end

function furrybot.get_ascii_dick(name)
	return minetest.rainbow(furrybot.get_ascii_genitals(name, "8", "=", "D", 69))
end

function furrybot.get_ascii_boobs(name)
	return furrybot.get_ascii_genitals(name, "E", "Ξ", "B", 420)
end

function furrybot.commands.dicksize(name, target)
	target = target or name
	furrybot.send(furrybot.get_ascii_dick(target) .. furrybot.colors.system .. "   ← " .. furrybot.ping(target, furrybot.colors.system) .. "'s Dick", furrybot.colors.system)
end
furrybot.commands.cocksize = furrybot.commands.dicksize

function furrybot.commands.boobsize(name, target)
	target = target or name
	furrybot.send(furrybot.get_ascii_boobs(target) .. furrybot.colors.system .. "   ← " .. furrybot.ping(target, furrybot.colors.system) .. "'s Boobs", furrybot.colors.system)
end

furrybot.commands.smellfeet = furrybot.request_command(function(name, target)
	furrybot.ping_message(target, name .. " wants to smell your feet. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.ping_message(name, " you are smelling " .. target .. "'s feet. They are kinda stinky!", furrybot.colors.roleplay)
end)

furrybot.commands.blowjob = furrybot.request_command(function(name, target)
	furrybot.ping_message(target, name .. " wants to suck your dick. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " is sucking " .. target .. "'s cock. ˣoˣ IT'S SO HUGE", furrybot.colors.roleplay)
end)

furrybot.commands.sex = furrybot.request_command(function(name, target)
	furrybot.ping_message(target, name .. " wants to have sex with you. Type !accept to accept or !deny to deny.", furrybot.colors.system)
end, function(name, target)
	furrybot.send(name .. " and " .. target .. " are having sex! OwO", furrybot.colors.roleplay)
end)
furrybot.commands.bang = furrybot.commands.sex
furrybot.commands.fuck = furrybot.commands.sex

furrybot.commands.cum = function(name)
	furrybot.send(name .. " is cumming: " .. furrybot.get_ascii_dick(name) .. C("#FFFFFF") .. furrybot.repeat_string("~", math.random(1, 10)), furrybot.colors.roleplay)
end

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
