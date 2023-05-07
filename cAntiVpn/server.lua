 --╔══════════════════════════════════════════════════╗--
---║                    ©cato.dev                     ║---
 --╚══════════════════════════════════════════════════╝--

Config = {
	ConsolePrints = true,
	AllowedCountrys = {	--| a list of all country codes that are allowed to connect >> https://www.iban.com/country-codes (Alpha-2 code)
		'DE',
		'AT',
	},
	Translation = {
		['checking'] = 'Checking your IP Address.',
		['noIpFound'] = 'We could not find your IP Address. Please try again.',
		['rejected'] = 'You are trying to connect with an VPM or from an not allowed Country! Please contact the Support!',
	}
}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	local identifiers = GetPlayerIdentifiers(source)
	local ipIdentifier = nil
	deferrals.defer()
	Wait(500)
	deferrals.update(Config.Translation.checking)
	for _, v in pairs(identifiers) do
		if string.find(v, 'ip') then
			ipIdentifier = v:sub(4)
			break
		end
	end
	Wait(500)
	if not ipIdentifier then
		deferrals.done(Config.Translation.noIpFound)
	else
		local country = nil
		PerformHttpRequest('http://ip-api.com/json/' .. ipIdentifier .. '?fields=proxy', function(err, proxyResponse, headers)
			PerformHttpRequest('http://ip-api.com/json/' .. ipIdentifier .. '?fields=countryCode', function(err, countryResponse, headers)
				local haveProxy = (json.decode(proxyResponse)).proxy
				local country = (json.decode(countryResponse)).countryCode
				local reject1 = true
				local reject2 = true
				if not haveProxy then
					reject1 = false
				end

				if Config.AllowedCountrys then
					for _, i in pairs(Config.AllowedCountrys) do
						if i == country then
							reject2 = false
						end
					end
				end

				if reject1 or reject2 then
					deferrals.done('\n\n' .. Config.Translation.rejected)
					dPrint('Connection from ^4' .. name .. ' ^7rejected! => ^4' .. ipIdentifier .. '^7, ^4' .. country .. '^7.')
				end
			end)
		end)
	end
end)

function dPrint(text)
	if Config.ConsolePrints then
		print(text)
	end
end