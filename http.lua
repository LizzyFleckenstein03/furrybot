local http, env, storage
local C = minetest.get_color_escape_sequence

furrybot.commands.verse = {
	func = function(name)
		furrybot.json_http_request("https://labs.bible.org/api/?type=json&passage=random", name, function(data)
			furrybot.send(data.text .. furrybot.colors.info .. "[" .. data.bookname .. " " .. data.chapter .. "," .. data.verse .. "]", furrybot.colors.fun)
		end)
	end,
}

furrybot.commands.define = {
	func = function(name, word)
		if word then
			furrybot.json_http_request("https://api.dictionaryapi.dev/api/v1/entries/en_US/" .. word:gsub("computer", "person"), name, function(data)
				local meaning = data.meaning
				local selected = meaning.abbreviation or meaning["cardinal number"] or meaning.exclamation or meaning.noun or meaning.verb or meaning.adjective or meaning["transitive verb"] or meaning.adverb or meaning["relative adverb"] or meaning.preposition
				if not selected then
					print(dump(meaning))
					furrybot.error_message(name, "Error in parsing response")
				else
					furrybot.send(word:sub(1, 1):upper() .. word:sub(2, #word):lower() .. ": " .. furrybot.colors.fun .. selected[1].definition, furrybot.colors.info)
				end
			end)
		else
			furrybot.error_message(name, "You need to specify a word")
		end
	end,
}

furrybot.commands.insult = {
	func = function(name, target)
		if furrybot.online_or_error(name, target, true) then
			furrybot.http_request("https://insult.mattbas.org/api/insult", name, function(data)
				furrybot.ping_message(target, data, furrybot.colors.fun)
			end)
		end
	end,
}

furrybot.commands.joke = {
	func = function(name, first, last)
		if not first then
			first = "Chuck"
			last = "Norris"
		elseif not last then
			last = ""
		end
		furrybot.json_http_request("http://api.icndb.com/jokes/random?firstName=" .. first .. "&lastName=" .. last, name, function(data)
			local joke = data.value.joke:gsub("&quot;", "\""):gsub("  ", " ")
			furrybot.send(joke, furrybot.colors.fun)
		end)
	end,
}

furrybot.commands["8ball"] = {
	func = function(name)
		furrybot.json_http_request("https://8ball.delegator.com/magic/JSON/anything", name, function(data)
			furrybot.ping_message(name, data.magic.answer, furrybot.colors.fun)
		end)
	end,
}

return function(_http, _env, _storage)
	http, env, storage = _http, _env, _storage
end
