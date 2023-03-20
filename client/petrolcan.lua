local isFuelingCan = false
local ox_inventory = exports.ox_inventory
local bones = {'wheel_rr', 'wheel_lr'}
local fuelingCan = nil

AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon)
	fuelingCan = currentWeapon?.name == 'WEAPON_PETROLCAN' and currentWeapon
end)
local function raycast(flag)
	local playerCoords = GetEntityCoords(cache.ped)
	local plyOffset = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.2, -0.25)
	local rayHandle = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, plyOffset.x, plyOffset.y, plyOffset.z, 2.2, flag or 30, cache.ped)
	while true do
		Wait(0)
		local result, _, _, _, entityHit = GetShapeTestResult(rayHandle)

		if result ~= 1 then
			if entityHit and GetEntityType(entityHit) == 2 then
				return entityHit
			end

			return false
		end
	end
end
-- fuelingMode = 1 - Pump
-- fuelingMode = 2 - Can
local function startFuelingCan(vehicle, isPump)
	isFuelingCan = true
	local Vehicle = Entity(vehicle).state
	local fuel = Vehicle.fuel or GetVehicleFuelLevel(vehicle)
	local duration = math.ceil((100 - fuel) / 0.50) * 250
	local price, moneyAmount
	local durability = 0

	if 100 - fuel < 0.50 then
		isFuelingCan = false
		return lib.notify({type = 'error', description = locale('tank_full')})
	end

	TaskTurnPedToFaceEntity(cache.ped, vehicle, duration)

	Wait(500)

	CreateThread(function()
		lib.progressCircle({
			duration = duration,
			useWhileDead = false,
			canCancel = true,
			disable = {
				move = true,
				car = true,
				combat = true,
			},
			anim = {
				dict = 'weapon@w_sp_jerrycan',
				clip = 'fire',
			},
		})

		isFuelingCan = false
	end)

	while isFuelingCan do
		durability += 1.3

		if durability >= fuelingCan.metadata.ammo then
			lib.cancelProgress()
			durability = fuelingCan.metadata.ammo
			break
		end

		fuel += 0.50

		if fuel >= 100 then
			isFuelingCan = false
			fuel = 100.0
		end

		Wait(250)
	end
    TriggerServerEvent('fuel:updateFuelCan', durability, NetworkGetNetworkIdFromEntity(vehicle), fuel)
end

RegisterCommand('startfueling', function()
	if isFuelingCan or cache.vehicle or lib.progressActive() then return end

	local petrolCan = GetSelectedPedWeapon(cache.ped) == `WEAPON_PETROLCAN`
	local playerCoords = GetEntityCoords(cache.ped)

	
	if petrolCan and fuelingCan.metadata.ammo > 0 then
		local vehicle = raycast()

		if vehicle then
			for i = 1, #bones do
				local fuelcapPosition = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, bones[i]))

				if #(playerCoords - fuelcapPosition) < 1.3 then
					return startFuelingCan(vehicle, false)
				end
			end

			return lib.notify({type = 'error', description = locale('vehicle_far')})
		end
	end
end)

RegisterKeyMapping('startfueling', 'Fuel vehicle', 'keyboard', 'e')
TriggerEvent('chat:removeSuggestion', '/startfueling')


