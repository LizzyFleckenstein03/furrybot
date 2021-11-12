local http, env, storage
local C = minetest.get_color_escape_sequence

function furrybot.get_money(name)
	local key = name .. ".money"
	if storage:contains(key) then
		return storage:get_int(key)
	else
		return 100
	end
end

function furrybot.set_money(name, money)
	storage:set_int(name .. ".money", money)
end

function furrybot.add_money(name, add)
	local money = furrybot.get_money(name)
	furrybot.set_money(name, money + add)
end

function furrybot.take_money(name, remove)
	local money = furrybot.get_money(name)
	local new = money - remove
	if new < 0 then
		return false
	else
		furrybot.set_money(name, new)
		return true
	end
end

function furrybot.money(money, color)
	return furrybot.colors.money .. "$" .. money .. color
end

furrybot.commands.money = {
	func = function(name, target)
		target = target or name
		furrybot.ping_message(name, (target == name and "You have " or target .. " has ") .. furrybot.money(furrybot.get_money(target), furrybot.colors.system) .. ".", furrybot.colors.system)
	end,
}

furrybot.commands.pay = {
	unsafe = true,
	func = function(name, target, number)
		if furrybot.online_or_error(name, target) then
			local money = tonumber(number or "")
			if not money or money <= 0 or math.floor(money) ~= money then
				furrybot.error_message(name, "Invalid amount of money")
			else
				if furrybot.take_money(name, money) then
					furrybot.add_money(target, money)
					furrybot.ping_message(target, name .. " has payed you " .. furrybot.money(money, furrybot.colors.system) .. ".", furrybot.colors.system)
				else
					furrybot.error_message(name, "You don't have enough money")
				end
			end
		end
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
