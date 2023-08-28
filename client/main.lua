ESX = exports['es_extended']:getSharedObject()

local spawnedChemicals = {}
local chemicalPlants = {}
local isPickingUp, isProcessing, hasdeleted = false, false, false
local PlayerData = {}
local ActiveDrugs = {}
local StartAllThreads = false
local turnedon = {}
CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end

    while ESX.PlayerData == nil do
        Citizen.Wait(50)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    TriggerServerEvent("sl-drugs-resync:drugstates")
end)



local blip = AddBlipForCoord(1850.298, 4924.742, 44.78823)
SetBlipSprite (blip, 496)
SetBlipDisplay(blip, 4)
SetBlipScale  (blip, 1.1)
SetBlipColour (blip, 25)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Wiet Pluk")
EndTextCommandSetBlipName(blip)	

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    ESX.PlayerData.job = job
end)

function IsGovermentJob()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == "police" then
        return true
    end

    return false
end

local drugData = {}

local drugStates = {}
for _, drugType in ipairs({"Meth", "Coke", "Weed"}) do
    drugStates[drugType] = false
end

for _, drugType in ipairs({"Meth", "Coke", "Weed"}) do
    spawnedChemicals[drugType] = 0
end


RegisterNetEvent("sl-setactivemode:drugs")
AddEventHandler("sl-setactivemode:drugs", function(drugType, coord)
    local hasCoord = false
    local ped = GetPlayerServerId(PlayerId())
    for i, data in ipairs(drugData) do
        if data.type == drugType then
            hasCoord = true
            if drugStates[data.type] and data.type ~= "Weed" then
                TriggerEvent("sl-setdrugsinactive:drugs", data.type)
                Wait(5000)
                hasCoord = false
                drugStates[data.type] = false
                table.remove(drugData, i)
                for value, drugtype in ipairs(turnedon[ped]) do
                    if drugtype == data.type then
                        table.remove(turnedon[ped], value)
                    end
                end
            end
            break
        end
    end

    Wait(2500)

    if not hasCoord then
        table.insert(drugData, { type = drugType, coord = coord })
    end

    for _, data in ipairs(drugData) do
        Wait(500)
        drugStates[data.type] = true
        StartDrugsThread(data.coord, data.type)
    end
end)


function GetClosestActiveDrug()
    local closestDist = math.huge 
    local closestCoord
    for _, data in ipairs(drugData) do
        if drugStates[data.type] then
            drugStates[data.type] = true
            local dist
            if type(data.coord) == "table" then
                for _, coord in ipairs(data.coord) do
                    dist = #(coords - coord)
                    if dist < closestDist then
                        closestDist = dist
                        closestCoord = coord
                    end
                end
            else
                dist = #(coords - data.coord)
                if dist < closestDist then
                    closestDist = dist
                    closestCoord = data.coord
                end
            end
            StartMainThread(closestCoord, data.type)
        end
    end
    return closestCoord, closestDist
end


RegisterNetEvent("sl-setdrugsinactive:drugs")
AddEventHandler("sl-setdrugsinactive:drugs", function(drugtype)
    local coordsfromcurrentdrugs = vector3(0,0,0)
    local player = GetPlayerServerId(PlayerId())
    for _, data in ipairs(drugData) do
        if drugStates[drugtype] then
            coordsfromcurrentdrugs = data.coord 
        end
    end
    Wait(100)

    if coordsfromcurrentdrugs == vector3(0,0,0) then
        return
    end

    Citizen.Wait(500)

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(coordsfromcurrentdrugs - playerCoords)
    if dist < 50 then
        ESX.ShowNotification("De " .. drugtype .. " is inactief geworden!")
        print("Deleting: " .. coordsfromcurrentdrugs .. " | " .. player .. " | " .. drugtype) 
        DeleteAllObjectsType(drugtype)
        drugStates[drugtype] = nil
        return
    end
end)

function StartDrugsThread(drugcoords, currentdrugstype)
    local ped = GetPlayerServerId(PlayerId())
    if not turnedon[ped] then
        turnedon[ped] = {}
    end
    for _, drugtype in ipairs(turnedon[ped]) do
        if drugtype == currentdrugstype then
            return
        end
    end
    Citizen.CreateThread(function()
        while drugStates[currentdrugstype] do
            Citizen.Wait(10)
            local coords = GetEntityCoords(PlayerPedId())
            local dist = #(coords - drugcoords)
            local pedid = GetPlayerServerId(PlayerId())
            local data = nil
            for _, d in ipairs(drugData) do
                if d.type == currentdrugstype then
                    data = d
                    break
                end
            end

            if dist < 50 and currentdrugstype == data.type then
                spawnChemicalPlants(data.type, data.coord)
                Citizen.Wait(500)
                hasdeleted = false
            elseif not hasdeleted then
                for _, d in ipairs(drugData) do
                    if d.type == currentdrugstype then
                        local distToDrug = #(coords - d.coord)
                        if distToDrug > 50 then
                            DeleteOnlyTypeObjects(pedid, currentdrugstype)
                            hasdeleted = true
                            break
                        end
                    end
                end
            end
            table.insert(turnedon[ped], currentdrugstype)
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local nearbyObject, nearbyID, currentdrugstate
        local playerId = GetPlayerServerId(PlayerId())

        if chemicalPlants[playerId] == nil then
            chemicalPlants[playerId] = {}
        end
        
        for drugType, drugState in pairs(drugStates) do
            if drugState then
                if chemicalPlants[playerId][drugType] ~= nil then 
                    for i=1, #chemicalPlants[playerId][drugType], 1 do
                        local distancetocoords = #(coords - GetEntityCoords(chemicalPlants[playerId][drugType][i]))
                        if distancetocoords < 1.5 then
                            nearbyObject, nearbyID, currentdrugstate = chemicalPlants[playerId][drugType][i], i, drugType
                        end
                    end
                end
            end
        end
        if nearbyObject then 
            if nearbyID == nil then 
                ESX.Game.DeleteObject(nearbyObject)
            else
                if IsPedOnFoot(playerPed) then
                    if not isPickingUp then
                        ESX.ShowHelpNotification('Druk op ~INPUT_CONTEXT~ om ' .. currentdrugstate .. ' te plukken')
                    end
                    if IsControlJustReleased(0, 38) and not isPickingUp then
                        isPickingUp = true
                        TriggerServerEvent("sl-drugs-sync", chemicalPlants[playerId][currentdrugstate], currentdrugstate)
                        Citizen.Wait(100)
                        GatherDrugs(nearbyObject, nearbyID)
                    end
                end
            end
        end
    end
end)

local controlsToDisable = {
    21, 30, 31, 32, 33, 34, 35, 73, 117
}


function GatherDrugs(nearbyObject, nearbyObjectID)
    local playerId = GetPlayerServerId(PlayerId())

    local currentdrugstype = nil
    for drugType, drugData in pairs(Config.DrugTypes) do
        if GetEntityModel(nearbyObject) == GetHashKey(drugData.prop) then
            currentdrugstype = drugType
            break
        end
    end
    if not currentdrugstype then
        ESX.ShowNotification("Dit object kan niet worden opgepakt")
        isPickingUp = false
        return
    end

    TaskStartScenarioInPlace(PlayerPedId(), Config.DrugTypes[currentdrugstype].anim, 0, false)
    local isDoingAction = true

    Citizen.CreateThread(function()
        local start = GetGameTimer()
        while isDoingAction and GetGameTimer() - start < 5000 do
            Citizen.Wait(0)
            for i=1, #controlsToDisable do
                DisableControlAction(0, controlsToDisable[i], true)
            end
        end
    end)

    Citizen.Wait(2200)
    ESX.Game.DeleteObject(nearbyObject)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("esx_illegal:pickedUpChemicals", nearbyObject, nearbyObjectID, currentdrugstype)
    isDoingAction = false
    isPickingUp = false
    if chemicalPlants[playerId][currentdrugstype] ~= nil then
        table.remove(chemicalPlants[playerId][currentdrugstype], nearbyObjectID)
    end

    if spawnedChemicals[currentdrugstype] ~= nil then
        spawnedChemicals[currentdrugstype] = spawnedChemicals[currentdrugstype] - 1
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteAllObjects()
    end
end)

RegisterNetEvent("respawnplants:player")
AddEventHandler("respawnplants:player", function(player)
    DeleteAllObjectsForPlayer(player)
end)

function DeleteAllObjectsForPlayer(playerId)
    for k, v in pairs(drugStates) do
        if v == true then
            if chemicalPlants[playerId][k] ~= nil then
                for k2, v2 in pairs(chemicalPlants[playerId][k]) do
                    ESX.Game.DeleteObject(v2)
                end
                chemicalPlants[playerId][k] = {}
            end
        end
    end     
end

function DeleteOnlyTypeObjects(playerId, drugtype)
    for drugType, drugState in pairs(drugStates) do
        if drugState then
            if drugType == drugtype then
                if chemicalPlants[playerId] and chemicalPlants[playerId][drugType] ~= nil then
                    for k2, v2 in pairs(chemicalPlants[playerId][drugType]) do
                        if DoesEntityExist(v2) then
                            ESX.Game.DeleteObject(v2)
                        end
                    end
                    chemicalPlants[playerId][drugType] = {}
                end
            end
        end
    end
end

function DeleteAllObjectsType(type)
    for k, v in pairs(drugStates) do
        if v then
            if k == type then
                for playerId, _ in pairs(chemicalPlants) do
                    if chemicalPlants[playerId][k] ~= nil then
                        for k2, v2 in pairs(chemicalPlants[playerId][k]) do
                            ESX.Game.DeleteObject(v2)
                        end
                        chemicalPlants[playerId][k] = {}
                    end
                end
            end
        end
    end
end

function DeleteAllObjects()
    for k, v in pairs(drugStates) do
        if v == true then
            for playerId, _ in pairs(chemicalPlants) do
                if chemicalPlants[playerId][k] ~= nil then
                    for k2, v2 in pairs(chemicalPlants[playerId][k]) do
                        ESX.Game.DeleteObject(v2)
                    end
                    chemicalPlants[playerId][k] = {}
                end
            end
        end
    end
end


function spawnChemicalPlants(currentdrugstype, drugcoords)
    local playerId = GetPlayerServerId(PlayerId())
    if not chemicalPlants[playerId] then
        chemicalPlants[playerId] = {}
    end
    if not chemicalPlants[playerId][currentdrugstype] then
        chemicalPlants[playerId][currentdrugstype] = {}
    end
    while #chemicalPlants[playerId][currentdrugstype] < 15 do
        Citizen.Wait(0)
        local methCoords = GenerateMethCoords(drugcoords, currentdrugstype)
        ESX.Game.SpawnLocalObject(Config.DrugTypes[currentdrugstype].prop, methCoords, function(obj)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            table.insert(chemicalPlants[playerId][currentdrugstype], obj)
            if #chemicalPlants[playerId][currentdrugstype] == 15 then
                TriggerServerEvent('sl-drugs-sync', chemicalPlants[playerId][currentdrugstype]) 
            else 
                TriggerServerEvent('sl-drugs-update', obj, currentdrugstype, playerId) 
            end
        end)
    end
end


function ValidateMethCoord(plantCoord, veccoords, curdrug)
    local id = GetPlayerServerId(PlayerId())
	if spawnedChemicals[curdrug] > 0 then
		local validate = true

		for k, v in pairs(chemicalPlants[id][curdrug]) do
			if #(plantCoord - GetEntityCoords(v)) < 5 then
				validate = false
			end
		end

		if #(plantCoord - veccoords) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateMethCoords(veccoords, curdrug)
	local currentxcoords = veccoords.x 
	local currentycoords = veccoords.y
	while true do
		Citizen.Wait(1)
		local methCoordX, methCoordY

		math.randomseed(GetGameTimer())

		local modX = math.random(-20, 20)
		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		methCoordX = currentxcoords + modX
		methCoordY = currentycoords + modY

		local coordZ = GetCoordZMeth(methCoordX, methCoordY)
		local coord = vector3(methCoordX, methCoordY, coordZ)
		if ValidateMethCoord(coord, veccoords, curdrug) then
			return coord
		end
	end
end

function GetCoordZMeth(x, y)
	local groundCheckHeights = { 119, 116.0, 117.0, 118.0, 115.0, 114.0, 120.0, 121.0, 122.0, 123.0, 124.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 53.85
end


