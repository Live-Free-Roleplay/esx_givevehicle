ESX = exports["es_extended"]:getSharedObject()

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('givecar', function(source, args)
	givevehicle(source, args, 'car')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveplane', function(source, args)
	givevehicle(source, args, 'airplane')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveboat', function(source, args)
	givevehicle(source, args, 'boat')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveheli', function(source, args)
	givevehicle(source, args, 'helicopter')
end)

RegisterServerEvent('esx_giveownedcar:logGiveCar')
AddEventHandler('esx_giveownedcar:logGiveCar', function (model, newPlate, playerID)
	local src = source
	local xAdmin = ESX.GetPlayerFromId(src)
	local xPlayer = ESX.GetPlayerFromId(playerID)

	local data = {
		{
			title = 'Vehicle Granted',
			description = ('Admin **%s** (%s, %s) **granted** vehicle **%s** with plate **%s** to player **%s** (%s, %s).')
				:format(
					xAdmin.getName(),
					xAdmin.getIdentifier(),
					src,
					model,
					newPlate,
					xPlayer.getName(),
					xPlayer.getIdentifier(),
					playerID
				),
			color = 0x00ff00
		}
	}

	PerformHttpRequest(
			"https://discord.com/api/webhooks/1240860709953474560/dEnXaFLa8ZFrvm394HLsKEpm7cGCTc8oupHtozoeiH0iNByE1vBIAST99IGeFEHReu-R",
			function(err, text, headers)
			end,
			'POST',
			json.encode({ embeds = data }),
			{ ['Content-Type'] = 'application/json' }
	)
end)

function givevehicle(_source, _args, vehicleType)
  local isAdmin = false
  if IsPlayerAceAllowed(_source, "giveownedcar.command") then isAdmin = true end

	if isAdmin then
    if _args[1] == nil or _args[2] == nil then
      TriggerClientEvent('esx:showNotification', _source, '~r~/givevehicle playerID carModel [plate]')
    elseif _args[3] ~= nil then
      local xPlayer = ESX.GetPlayerFromId(_args[1])
      local playerName = xPlayer.getName()
      local plate = _args[3]
      if #_args > 3 then
        for i=4, #_args do
          plate = plate.." ".._args[i]
        end
      end	
      plate = string.upper(plate)
      TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', _source, _args[1], _args[2], plate, playerName, 'player', vehicleType)
    else
      local xPlayer1 = ESX.GetPlayerFromId(_args[1])
      local playerName = xPlayer1.getName()
      TriggerClientEvent('esx_giveownedcar:spawnVehicle', _source, _args[1], _args[2], playerName, 'player', vehicleType)
    end
  else
    TriggerClientEvent('esx:showNotification', _source, '~r~You don\'t have permission to do this command!')
  end
end

RegisterCommand('_givecar', function(source, args)
	_givevehicle(source, args, 'car')
end)

RegisterCommand('_giveplane', function(source, args)
	_givevehicle(source, args, 'airplane')
end)

RegisterCommand('_giveboat', function(source, args)
	_givevehicle(source, args, 'boat')
end)

RegisterCommand('_giveheli', function(source, args)
	_givevehicle(source, args, 'helicopter')
end)

function _givevehicle(_source, _args, vehicleType)
	if _source == 0 then
		local sourceID = _args[1]
		if _args[1] == nil or _args[2] == nil then
			print("SYNTAX ERROR: _givevehicle <playerID> <carModel> [plate]")
		elseif _args[3] ~= nil then
			local xPlayer = ESX.GetPlayerFromId(_args[1])
      local playerName = xPlayer.getName()
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end
			plate = string.upper(plate)
			TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', sourceID, _args[1], _args[2], plate, playerName, 'console', vehicleType)
		else
			local xPlayer = ESX.GetPlayerFromId(_args[1])
      local playerName = xPlayer.getName()
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', sourceID, _args[1], _args[2], playerName, 'console', vehicleType)
		end
	end
end

RegisterCommand('delcarplate', function(source, args)
  local isAdmin = false
  if IsPlayerAceAllowed(source, "giveownedcar.command") then isAdmin = true end

  if isAdmin then
    if args[1] == nil then
      TriggerClientEvent('esx:showNotification', source, '~r~/delcarplate <plate>')
    else
      local plate = args[1]
      if #args > 1 then
        for i=2, #args do
          plate = plate.." "..args[i]
        end		
      end
      plate = string.upper(plate)
      exports.wasabi_carlock:RemoveKeys(plate, source)
      local result = MySQL.Sync.execute('DELETE FROM `owned_vehicles` WHERE `plate` = @plate', {
        ['@plate'] = plate
      })
      if result == 1 then
        TriggerClientEvent('esx:showNotification', source, _U('del_car', plate))
      elseif result == 0 then
        TriggerClientEvent('esx:showNotification', source, _U('del_car_error', plate))
      end		
    end
  else
    TriggerClientEvent('esx:showNotification', source, '~r~You don\'t have permission to do this command!')
  end
end)

RegisterCommand('_delcarplate', function(source, args)
    if source == 0 then
		if args[1] == nil then	
			print("SYNTAX ERROR: _delcarplate <plate>")
		else
			local plate = args[1]
			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end		
			end
			plate = string.upper(plate)
			
			local result = MySQL.Sync.execute('DELETE FROM `owned_vehicles` WHERE `plate` = @plate', {
				['@plate'] = plate
			})
			if result == 1 then
				print('Deleted car plate: ' ..plate)
			elseif result == 0 then
				print('Can\'t find car with plate is ' ..plate)
			end
		end
	end
end)


--functions--

RegisterServerEvent('esx_giveownedcar:setVehicle')
AddEventHandler('esx_giveownedcar:setVehicle', function (vehicleProps, playerID, vehicleType)
	local _source = playerID
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO `owned_vehicles` (`owner`, `plate`, `vehicle`, `stored`, `type`) VALUES (@owner, @plate, @vehicle, @stored, @type)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
		['@stored']  = 1,
		['@type'] = vehicleType
	}, function ()
		if Config.ReceiveMsg then
      --TriggerClientEvent('cd_garage:AddKeys', _source, vehicleProps.plate)
      --exports['t1ger_keys']:UpdateKeysToDatabase(vehicleProps.plate, true)
      exports.wasabi_carlock:GiveKeys(vehicleProps.plate, _source)
			TriggerClientEvent('esx:showNotification', _source, _U('received_car', string.upper(vehicleProps.plate)))
		end
	end)
end)

RegisterServerEvent('esx_giveownedcar:printToConsole')
AddEventHandler('esx_giveownedcar:printToConsole', function(msg)
	print(msg)
end)

RegisterServerEvent('esx_giveownedcar:genPlate')
AddEventHandler('esx_giveownedcar:genPlate', function (playerID, vehicle, vehicleType, playerName, model, type)
	local src = source
	local chars = {}
	for i = 65, 90 do
			table.insert(chars, string.char(i))
	end
	for i = 48, 57 do
			table.insert(chars, string.char(i))
	end
	math.randomseed(os.time())
	local plate_number = {}
	for i = 1, 8 do
			table.insert(plate_number, chars[math.random(1, #chars)])
	end

	TriggerClientEvent('esx_giveownedcar:genPlateRet', src, table.concat(plate_number), playerID, vehicle, vehicleType, playerName, model, type)
end)

RegisterServerEvent('esx_giveownedcar:checkOwned')
AddEventHandler('esx_giveownedcar:checkOwned', function (model, coords, vehicle, playerID, vehicleType, plate, model, playerName, type, carExist)
	local src = source
	MySQL.query('SELECT `plate` FROM `owned_vehicles` WHERE `plate` = ?', {
    plate
	}, function(response)
		TriggerClientEvent('esx_giveownedcar:checkOwnedRet', src, #response, model, coords, vehicle, playerID, vehicleType, plate, model, playerName, type, carExist)
	end)
end)