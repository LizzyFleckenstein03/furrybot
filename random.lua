local http, env, storage
local C = minetest.get_color_escape_sequence

function furrybot.commands.rolldice(name)
	furrybot.ping_message(name, "rolled a dice and got a " .. furrybot.random(1, 6, furrybot.colors.system) .. ".", furrybot.colors.system)
end

function furrybot.commands.coinflip(name)
	furrybot.ping_message(name, "flipped a coin and got " .. furrybot.choose({"Heads", "Tails"}, furrybot.colors.system) .. ".", furrybot.colors.system)
end

function furrybot.commands.choose(name, ...)
	local options = {...}
	if #options > 1 then
		furrybot.ping_message(name, "I choose " .. furrybot.choose(options, "", furrybot.colors.system) .. ".", furrybot.colors.system)
	else
		furrybot.error_message(name, "Not enough options")
	end
end

function furrybot.commands.uwu()
	local msg = ""

	local m = math.random(10)

	for i = 1, m do
		local u_list = {"u", "ü", "o", "ö"}

		local u = u_list[math.random(#u_list)]
		local w = "w"

		if math.random() < 0.5 then
			u = u:upper()
		end

		if math.random() < 0.5 then
			w = w:upper()
		end

		msg = msg .. u .. w .. u

		if i ~= m then
			msg = msg .. " "
		end
	end

	furrybot.send(msg, furrybot.colors.system)
end

function furrybot.commands.extinct(name, species)
	if species then
		furrybot.ping_message(name, species:sub(1, 1):upper() .. species:sub(2, #species) .. (species:sub(#species, #species):lower() == "s" and "" or "s") .. " are " .. (furrybot.strrandom(species, 420, 0, 1) == 0 and "not " or "") .. "extinct." , furrybot.colors.system)
	else
		furrybot.error_message(name, "You need to specify a species")
	end
end

function furrybot.commands.german(name)
	local messages = {
		"Schnauze!",
		"Sprich Deutsch, du Hurensohn!",
		"NEIN NEIN NEIN NEIN NEIN NEIN",
		"Deine Mutter",
		"Das war ein BEFEHL!",
		"Das bleibt hier alles so wie das hier ist!",
		"Scheißße",
		"Digga was falsch bei dir",
		"Lass mich deine Arschfalten sehen",
		"Krieg mal deinen Ödipuskomplex unter Kontrolle",
		"Meine Nudel ist 30cm lang und al dente",
		"Wie die Nase eines Mannes, so auch sein Johannes.",
	}

	local msg = messages[math.random(#messages)]
	local stripe = math.floor(#msg / 3)

	furrybot.ping_message(name, msg:sub(1, stripe) .. C("red") .. msg:sub(stripe + 1, stripe * 2) .. C("yellow") .. msg:sub(stripe * 2 + 1, #msg), C("black"))
end

function furrybot.commands.color(name)
	local color = string.format("#%06x", math.random(16777216) - 1):upper()

	furrybot.ping_message(name, "Here's your color: " .. C(color) .. color, furrybot.colors.system)
end

function furrybot.commands.book(name)
	local books = {
		"Johann Wolfgang von Goethe - Faust, Der Tragödie Erster Teil",
		"Johann Wolfgang von Goethe - Faust, Der Tragödie Zweiter Teil",
		"Karl Marx & Friedrich Engels - The Communist Manifesto",
		"Brian Kernhigan & Dennis Ritchie - The C Programming Language",
		"Heinrich Heine - Die Harzreise",
		"Johann Wolfgang von Goethe - Die Leiden des jungen Werther",
		"Friedrich Schiller - Die Jungfrau von Orleans",
		"Theodor Fontane - Irrungen, Wirrungen",
		"Friedrich Schiller - Die Räuber",
		"Theodor Storm - Der Schimmelreiter",
		"Josef von Eichendorff - Aus dem Leben eines Taugenichts",
		"Richard Esplin - Advanced Linux Programming",
		"Joey de Vries - Learn OpenGL",
		"Gerard Beekmans - Linux From Scratch",
	}

	furrybot.ping_message(name, books[math.random(#books)], furrybot.colors.system)
end

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
