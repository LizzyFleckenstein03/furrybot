local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.kill_deathmessages = {
	"%s walked into fire whilst fighting %s",
	"%s was struck by lightning whilst fighting %s",
	"%s was burnt to a crisp whilst fighting %s",
	"%s tried to swim in lava to escape %s",
	"%s walked into danger zone due to %s",
	"%s suffocated in a wall whilst fighting %s",
	"%s drowned whilst trying to escape %s",
	"%s starved to death whilst fighting %s",
	"%s walked into a cactus whilst trying to escape %s",
	"%s hit the ground too hard whilst trying to escape %s",
	"%s experienced kinetic energy whilst trying to escape %s",
	"%s didn't want to live in the same world as %s",
	"%s died because of %s",
	"%s was killed by magic whilst trying to escape %s",
	"%s was killed by %s using magic",
	"%s was roasted in dragon breath by %s",
	"%s withered away whilst fighting %s",
	"%s was shot by a skull from %s",
	"%s was squashed by a falling anvil whilst fighting %s",
	"%s was slain by %s",
	"%s was shot by %s",
	"%s was fireballed by %s",
	"%s was killed trying to hurt %s",
	"%s was blown up by %s",
	"%s was squashed by %s",
}

furrybot.deathmessages = {
	"%s went up in flames",
	"%s was struck by lightning",
	"%s burned to death",
	"%s tried to swim in lava",
	"%s discovered the floor was lava",
	"%s suffocated in a wall",
	"%s drowned",
	"%s starved to death",
	"%s was pricked to death",
	"%s hit the ground too hard",
	"%s experienced kinetic energy",
	"%s fell out of the world",
	"%s died",
	"%s was killed by magic",
	"%s was roasted in dragon breath",
	"%s withered away",
	"%s was squashed by a falling anvil",
	"%s blew up",
	"%s was squished too much",
	"%s went off with a bang",
}

furrybot.commands.kill = {
	func = function(name, target)
		if furrybot.online_or_error(name, target, true) then
			if name == target then
				furrybot.send(string.format("%s died due to lack of friends", target), furrybot.colors.roleplay)
			else
				furrybot.send(string.format(furrybot.kill_deathmessages[math.random(#furrybot.kill_deathmessages)], target, name), furrybot.colors.roleplay)
			end
		end
	end,
}

furrybot.commands.die = {
	func = function(name)
		furrybot.send(string.format(furrybot.deathmessages[math.random(#furrybot.deathmessages)], name), furrybot.colors.roleplay)
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
