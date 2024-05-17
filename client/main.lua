ESX = exports["es_extended"]:getSharedObject()

TriggerEvent('chat:addSuggestion', '/givecar', 'Give a car to player', {
	{ name="id", help="The ID of the player" },
    { name="vehicle", help="Vehicle model" },
    { name="<plate>", help="Vehicle plate, skip if you want random generate plate number" }
})

--[[TriggerEvent('chat:addSuggestion', '/giveplane', 'Give an airplane to player', {
	{ name="id", help="The ID of the player" },
    { name="vehicle", help="Vehicle model" },
    { name="<plate>", help="Vehicle plate, skip if you want random generate plate number" }
})

TriggerEvent('chat:addSuggestion', '/giveboat', 'Give a boat to player', {
	{ name="id", help="The ID of the player" },
    { name="vehicle", help="Vehicle model" },
    { name="<plate>", help="Vehicle plate, skip if you want random generate plate number" }
})

TriggerEvent('chat:addSuggestion', '/giveheli', 'Give a helicopter to player', {
	{ name="id", help="The ID of the player" },
    { name="vehicle", help="Vehicle model" },
    { name="<plate>", help="Vehicle plate, skip if you want random generate plate number" }
})--]]

TriggerEvent('chat:addSuggestion', '/delcarplate', 'Delete a owned vehicle by plate number', {
	{ name="plate", help="Vehicle's plate number" }
})

RegisterNetEvent('esx_giveownedcar:spawnVehicle')
AddEventHandler('esx_giveownedcar:spawnVehicle', function(playerID, model, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local carExist  = false
	ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info
		if DoesEntityExist(vehicle) then
			carExist = true
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			TriggerServerEvent('esx_giveownedcar:genPlate', playerID, vehicle, vehicleType, playerName, model, type)
		end		
	end)
	
	Wait(2000)
	if not carExist then
		if type ~= 'console' then
			ESX.ShowNotification(_U('unknown_car', model))
		else
			TriggerServerEvent('esx_giveownedcar:printToConsole', "ERROR: "..model.." is an unknown vehicle model")
		end		
	end
end)

RegisterNetEvent('esx_giveownedcar:genPlateRet')
AddEventHandler('esx_giveownedcar:genPlateRet', function(newPlate, playerID, vehicle, vehicleType, playerName, model, type)
	local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
	vehicleProps.plate = newPlate
	TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
	ESX.Game.DeleteVehicle(vehicle)
	if type ~= 'console' then
		ESX.ShowNotification(_U('gived_car', model, newPlate, playerName))
		TriggerServerEvent('esx_giveownedcar:logGiveCar', model, newPlate, playerID)
	else
		local msg = ('addCar: ' ..model.. ', plate: ' ..newPlate.. ', toPlayer: ' ..playerName)
		TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
	end	
end)

RegisterNetEvent('esx_giveownedcar:spawnVehiclePlate')
AddEventHandler('esx_giveownedcar:spawnVehiclePlate', function(playerID, model, plate, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local generatedPlate = string.upper(plate)
	local carExist  = false

	TriggerServerEvent('esx_giveownedcar:checkOwned', model, coords, vehicle, playerID, vehicleType, plate, model, playerName, type, carExist)
end)

RegisterNetEvent('esx_giveownedcar:checkOwnedRet')
AddEventHandler('esx_giveownedcar:checkOwnedRet', function(response, model, coords, vehicle, playerID, vehicleType, plate, model, playerName, type, carExist)
	print(response)
	if response == 0 then
		ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info	
			if DoesEntityExist(vehicle) then
				carExist = true
				SetEntityVisible(vehicle, false, false)
				SetEntityCollision(vehicle, false)	
				
				local newPlate     = string.upper(plate)
				local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
				vehicleProps.plate = newPlate
				TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
				ESX.Game.DeleteVehicle(vehicle)
				if type ~= 'console' then
					ESX.ShowNotification(_U('gived_car',  model, newPlate, playerName))
					TriggerServerEvent('esx_giveownedcar:logGiveCar', model, newPlate, playerID)
				else
					local msg = ('addCar: ' ..model.. ', plate: ' ..newPlate.. ', toPlayer: ' ..playerName)
					TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
				end				
			end
		end)
	else
		carExist = true
		if type ~= 'console' then
			ESX.ShowNotification(_U('plate_already_have'))
		else
			local msg = ('Error: this plate is already been used on another vehicle')
			TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
		end					
	end

	Wait(2000)

	if not carExist then
		if type ~= 'console' then
			ESX.ShowNotification(_U('unknown_car', model))
		else
			TriggerServerEvent('esx_giveownedcar:printToConsole', "ERROR: "..model.." is an unknown vehicle model")
		end		
	end	
end)