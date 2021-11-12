local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.alphabeth = {
	vowels = {},
	consonants = {},
}

function furrybot.get_waifu_name()
	local state = math.random() < 0.5
	local r = math.random(3, 8)
	local str = ""

	for i = 1, r do
		local tbl = state and furrybot.alphabeth.vowels or furrybot.alphabeth.consonants
		str = str .. tbl[math.random(#tbl)]

		state = not state
	end

	return furrybot.uppercase(str)
end

function furrybot.random_distribution(tbl)
	local accum = 0
	local edges = {}

	for i, v in ipairs(tbl) do
		accum = accum + v[2]
		edges[i] = accum
	end

	local r = math.random(accum)

	for i, v in ipairs(tbl) do
		if r <= edges[i] then
			return v[1]
		end
	end
end

function furrybot.get_waifu_species()
	return furrybot.random_distribution({
		{nil, 100}, 			-- Human
		{"Catgirl", 15},
		{"Foxgirl", 15},
		{"Wolfgirl", 15},
		{"Orc", 5},
		{"Elb", 5},
		{"Dwarf", 5},
		{"Femboy", 3},
		{"Apache Helicopter", 1},
		{"C++ Programmer", 1},
	})
end

function furrybot.get_waifu_gender()
	return furrybot.random_distribution({
		{"Male", 50},
		{"Female", 50},
		{"nil", 1},
	})
end

function furrybot.get_waifu_hair()
	return furrybot.random_distribution({
		{{"Brown", "#DDAE92"}, 25},
		{{"Black", "#433F3A"}, 25},
		{{"Blonde", "#ECC87E"}, 20},
		{{"Red", "#E2887F"}, 10},
	})
end

function furrybot.get_waifu_eyes()
	return furrybot.random_distribution({
		{{"Brown", "#463230"}, 15},
		{{"Blue", "#97C6FE"}, 10},
		{{"Green", "#36CC4E"}, 5},
	})
end

function furrybot.get_waifu_age()
	local agetab = furrybot.random_distribution({
		{{200, 600}, 25}, -- deamon
		{{1000, 2000}, 5}, -- next level deamon
		{{12, 16}, 50}, -- teen loli
		{{18, 19}, 5}, -- legal loli
		{{5, 9}, 5}, -- true loli
		{nil, 1}, -- unknown
	})

	return agetab and math.random(agetab[1], agetab[2])
end

function furrybot.get_waifu(id)
	id = id or math.random(0, 32767)

	math.randomseed(id)

	local waifu = {
		id = id,
		name = furrybot.get_waifu_name(),
		species = furrybot.get_waifu_species(),
		gender = furrybot.get_waifu_gender(),
		hair = furrybot.get_waifu_hair(),
		eyes = furrybot.get_waifu_eyes(),
		age = furrybot.get_waifu_age(),
	}

	math.randomseed(os.time() + os.clock() + math.random())

	return waifu
end

furrybot.commands.waifu = {
	func = function(name, id)
		local waifu = furrybot.get_waifu(tonumber(id or ""))
		furrybot.send(waifu.name
			.. furrybot.colors.system .. (waifu.species and " | Species: " .. furrybot.colors.random .. waifu.species or "")
			.. furrybot.colors.system .. " | Age: " .. furrybot.colors.random .. (waifu.age or "Unknown")
			.. furrybot.colors.system .. " | Gender: " .. furrybot.colors.random .. waifu.gender
			.. furrybot.colors.system .. " | " .. C(waifu.hair[2]) .. waifu.hair[1] .. furrybot.colors.system .. " Hair"
			.. furrybot.colors.system .. " | " .. C(waifu.eyes[2]) .. waifu.eyes[1] .. furrybot.colors.system .. " Eyes"
			.. furrybot.colors.system .. " | " .. "#" .. waifu.id .. ""
		, furrybot.colors.random)
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage

	local is_vowel = {
		a = true,
		e = true,
		i = true,
		o = true,
		u = true,
	}

	local bounds = "az"

	local f = env.io.open("clientmods/furrybot/LICENSE", "r")
	local src = f:read("*a")

	for i = 1, #src do
		local c = src:sub(i, i):lower()

		if c:byte(1) >= bounds:byte(1) and c:byte(1) <= bounds:byte(2) then
			table.insert(is_vowel[c] and furrybot.alphabeth.vowels or furrybot.alphabeth.consonants, c)
		end
	end
end
