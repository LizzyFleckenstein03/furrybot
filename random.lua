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

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
