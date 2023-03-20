local ox_inventory = exports.ox_inventory
RegisterServerEvent('esx-fuel:server:Pay', function(amount)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    Player.removeMoney(amount)
    TriggerEvent('addfeetobusiness', src, 'char1:b4eaa6f80adbfaa5ee80c031d57ff1d3e6596f25', amount)
end)

RegisterServerEvent('esx-fuel:server:GiveJerrican', function()
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Config.JerryCanWeaponAsItem then
        Player.addInventoryItem('weapon_petrolcan', 1)
    else
        Player.addWeapon('weapon_petrolcan', 4500)
    end
end)

RegisterServerEvent('esx-fuel:server:AttachRope', function(netIdProp, coordPumps, model)
	local src = source
    local Player = ESX.GetPlayerFromId(src)
    local citizenid = Player.identifier
    TriggerClientEvent('esx-fuel:client:AttachRope', -1, netIdProp, coordPumps, model, citizenid)
end)

RegisterServerEvent('esx-fuel:server:DetachRope', function(src)
	local srctemp = source
    local Player = ESX.GetPlayerFromId(srctemp)
    local citizenid = Player.identifier
    TriggerClientEvent('esx-fuel:client:DetachRope', -1, citizenid, src)
end)

RegisterNetEvent('esx-fuel:server:UpdateVehicleDateTimeIn', function(plate)
    MySQL.update('UPDATE owned_vehicles SET datetimein = ? WHERE plate = ?', {os.time(), plate})
end)

ESX.RegisterServerCallback('esx-fuel:server:GetTimeInGarage', function(source, cb, plate)
    local result = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', { plate })
    if result then
        if result.datetimein and result.datetimein ~= 0 then
            cb(os.time() - result.datetimein)
        else
            cb(false)            
        end
    else
        cb(false)
    end
end)

RegisterNetEvent('fuel:updateFuelCan', function(durability)
	local source = source
	local item = ox_inventory:GetCurrentWeapon(source)

	if item and durability > 0 then
		durability = math.floor(item.metadata.durability - durability)
		item.metadata.durability = durability
		item.metadata.ammo = durability

		ox_inventory:SetMetadata(source, item.slot, item.metadata)
		Wait(0)
		return --TriggerClientEvent('ox_inventory:disarm', source)
	end

	-- player is sus?
end)
RegisterNetEvent('fuel:updateRefillFuelCan', function(durability)
	local source = source
	local item = ox_inventory:GetCurrentWeapon(source)

	if item and durability > 0 then
		durability = math.floor(item.metadata.durability + durability)
		item.metadata.durability = durability
		item.metadata.ammo = durability

		ox_inventory:SetMetadata(source, item.slot, item.metadata)
		Wait(0)
		return --TriggerClientEvent('ox_inventory:disarm', source)
	end

	-- player is sus?
end)

-- ESX.RegisterCommand("fuel", 'admin', function(xPlayer, args, showError)
--     local amount = tonumber(args.amount)
--     if not amount then
--         amount = 100
--     end
--     xPlayer.triggerEvent('esx-fuel:SetFuel', amount)
-- end, false, {help = "Set fuel/charge for vehicle", validate = false, arguments = {
-- 	{name = 'amount',validate = false, help = "Amount", type = 'string'}
-- }}) 