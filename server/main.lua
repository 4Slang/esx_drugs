ESX = exports['es_extended']:getSharedObject()

local openWeed = false
local methCounter = 0
local MethHours = {}
local CokeHours = {}
local DrugHours = {}
timechange = {}
local TimeCounter = {}
local NumberCounter = {}
local currentDrug = "nil"
local openHours = {
    ["Coke"] = {},
    ["Meth"] = {},
    ["Weed"] = {},
}
local openMethhour, openCokehour = false, false
local sendmessage = false
local hassendcoke, issendalready = false, false
PlantsClientSide = {}
local VerwerkData, VerkoopData = {}, {}
local DrugsLocaties = {
    ["Meth"] = {
        {value = 1, coords = vector3(1579.505, -2677.373, 34.14355)},
        {value = 2, coords = vector3(-932.8402, 6163.117, 3.72375)},
        {value = 3, coords = vector3(-1126.172, 83.27342, 55.60291)},
    },
    ["Coke"] = {
        {value = 1, coords = vector3(3714.896, 3092.996, 11.66529)},
        {value = 2, coords = vector3(1008.076, 4362.452, 42.53058)},
        {value = 3, coords = vector3(-333.4809, 2490.749, 82.42476)},
    }
}

local VerwerkLocaties = {
    ["Weed"] = {
        vector3(1219.84, 1874.05, 77.9206)
    },
    ["Coke"] = {
        vector3(572.6389, 2797.12, 41.04488)
    },
    ["Meth"] = {
        vector3(-1885.039, 2077.396, 139.9968)
    }
}

local VerkoopLocaties = {
    ["Weed"] = {
        vector3(1506.535, -2147.283, 76.11008),
    },
    ["Coke"] = {
        vector3(453.103, -3072.912, 5.09933),
    },
    ["Meth"] = {
        vector3(2678.871, 3509.136, 52.30326)
    }
}

ESX.RegisterServerCallback('esx_illegal:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

GetPoliceCount = function()
    local players = ESX.GetPlayers()
    local policeCount = 0
    local ambulanceCount = 0

    for i=1, #players, 1 do
        local xPlayer = ESX.GetPlayerFromId(players[i])

        if xPlayer.job.name == 'police' then
            policeCount = policeCount + 1
        elseif xPlayer.job.name == 'ambulance' then
            ambulanceCount = ambulanceCount + 1
        end
    end

    return policeCount
end

local Verkopen = {}
RegisterServerEvent("esx_drugs:leave:drugstype_1")
AddEventHandler("esx_drugs:leave:drugstype_1", function()
    Verkopen[source] = false
end)

RegisterServerEvent("esx_drugs:request:verkopen")
AddEventHandler("esx_drugs:request:verkopen", function(data, typesec)
    if data == nil then
        print("Cheater 2")
        return
    end
    local src = source
    local item = nil
    local type = nil
    local loc = nil
    local verwerkitemhere = nil
    for k,v in pairs(data) do
        if v.type == typesec then
            type = v.type
            loc = v.location
            break
        end
    end
    
    if not type or not loc then
        print("Cheater 2")
        return
    end

    if type == "Weed" then
        item = "weed_pooch"
    elseif type == "Coke" then
        item = "coke_pooch"
    elseif type == "Meth" then
        item = "meth_pooch"
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    
    local distance = #(xPlayer.getCoords(true) - loc)
    
    if distance > 10 then
        print("Cheater 3")
        return
    end
    
    Verkopen[src] = true
    
    while Verkopen[src] do 
        local PoliteCount = "low"
        local politie = GetPoliceCount()
        local newitem = math.random(1, 2)
        if politie > 3 then
            PoliteCount = "medium"
            newitem = math.random(3, 4)
        elseif politie > 7 then
            PoliteCount = "hard"
            newitem = math.random(5, 6)
        end
    
        Citizen.Wait(7000)
    
        if Verkopen[src] then
            print("Is selling: " .. newitem .. " | " .. item)
            local amountitem = xPlayer.getInventoryItem(item)
            print(amountitem.count)
            if amountitem.count <= 0 then
                xPlayer.showNotification("Je hebt niet genoeg items")
                return
            end

            

            xPlayer.removeInventoryItem(item, newitem)
            if type == "Weed" then
                if PoliteCount == "low" then
                    xPlayer.addAccountMoney("black_money", math.random(500, 900))
                elseif PoliteCount == "medium" then
                    xPlayer.addAccountMoney("black_money", math.random(1400, 1900))
                elseif PoliteCount == "hard" then
                    xPlayer.addAccountMoney("black_money", math.random(2400, 2900))
                end
            elseif type == "Coke" then
                if PoliteCount == "low" then
                    xPlayer.addAccountMoney("black_money", math.random(1000, 1750))
                elseif PoliteCount == "medium" then
                    xPlayer.addAccountMoney("black_money", math.random(2500, 4000))
                elseif PoliteCount == "hard" then
                    xPlayer.addAccountMoney("black_money", math.random(4500, 5200))
                end
            elseif type == "Meth" then
                if PoliteCount == "low" then
                    xPlayer.addAccountMoney("black_money", math.random(1500, 2200))
                elseif PoliteCount == "medium" then
                    xPlayer.addAccountMoney("black_money", math.random(3300, 4800))
                elseif PoliteCount == "hard" then
                    xPlayer.addAccountMoney("black_money", math.random(5800, 7000))
                end
            end
        end
    end
end)

local Verwerking = {}
RegisterServerEvent("esx_drugs:leave:drugstype")
AddEventHandler("esx_drugs:leave:drugstype", function()
    Verwerking[source] = false
end)

RegisterServerEvent("esx_drugs:request:verwerking")
AddEventHandler("esx_drugs:request:verwerking", function(data, typesec)
    if data == nil then
        print("Cheater 2")
        return
    end
    local src = source
    local item = nil
    local type = nil
    local loc = nil
    local verwerkitemhere = nil
    for k,v in pairs(data) do
        if v.type == typesec then
            type = v.type
            loc = v.location
            break
        end
    end
    
    if not type or not loc then
        print("Cheater 2")
        return
    end
    print(type)
    if type == "Weed" then
        item = "weed"
        verwerkitemhere = "weed_pooch"
    elseif type == "Coke" then
        item = "coke"
        verwerkitemhere = "coke_pooch"
    elseif type == "Meth" then
        item = "meth"
        verwerkitemhere = "meth_pooch"
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    
    local distance = #(xPlayer.getCoords(true) - loc)
    
    if distance > 10 then
        print("Cheater 3")
        return
    end
    
    Verwerking[src] = true
    
    while Verwerking[src] do 
        local politie = GetPoliceCount()
        local newitem = math.random(3, 7)
    
        newitem = math.floor(newitem * tonumber(politie))
    
        local additem = newitem - math.random(1,3)
    
        Citizen.Wait(math.random(7000, 10000))
    
        if Verwerking[src] then
            local amountitem = xPlayer.getInventoryItem(item)
            if amountitem.count <= 0 then
                xPlayer.showNotification("Je hebt niet genoeg items")
                return
            end


            if not xPlayer.canCarryItem(verwerkitemhere, 4) then
                xPlayer.showNotification("Je inventory zit vol")
                return
            else
                if additem >= 0 then
                    xPlayer.removeInventoryItem(item, 4)
                    xPlayer.addInventoryItem(verwerkitemhere, 1)
                end
            end
        end
    end
end)

RegisterCommand("force_respawnplants", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification("Plants are respawning...")
    TriggerClientEvent("respawnplants:player", source, source)
end)

RegisterServerEvent('sl-drugs-sync')
AddEventHandler('sl-drugs-sync', function(newtable)
    PlantsClientSide[source] = newtable
end)

RegisterServerEvent('sl-drugs-update')
AddEventHandler('sl-drugs-update', function(obj, currentdrugstype, playerId)
    if not PlantsClientSide[playerId] then
        PlantsClientSide[playerId] = {}
    end
    if not PlantsClientSide[playerId][currentdrugstype] then
        PlantsClientSide[playerId][currentdrugstype] = {}
    end
    table.insert(PlantsClientSide[playerId][currentdrugstype], obj)
end)

RegisterServerEvent('sl-drugs-resync:drugstates')
AddEventHandler('sl-drugs-resync:drugstates', function()
    StartServerside(source)
end)



function IsValidNetworkID(nearbyid, src)
    if not PlantsClientSide then
        return false
    end
    for playerId, plants in pairs(PlantsClientSide) do
        if playerId == src then
            for i, drugPlants in pairs(plants) do
                if i == nearbyid then
                    table.remove(PlantsClientSide[src], i)
                    return true
                end
            end
        end
    end
    return false
end

RegisterServerEvent('esx_illegal:pickedUpChemicals')
AddEventHandler('esx_illegal:pickedUpChemicals', function(obj, nearbyid, drugstype)
    local item = "none"
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local newrandom = math.random(1,3)
    local index = nil
    for _, urentable in ipairs(DrugHours) do
        index = table.checkvaluesOf(TimeCounter, string.format("%02d:%02d", urentable.hour, urentable.minutes))
    end
    Wait(100)
    if index == nil and drugstype ~= "Weed" then
        xPlayer.showNotification("Er is iets misgegaan met the match van de server naar de netid van de objects")
        xPlayer.showNotification("Probeer het later opnieuw.")
        return
    end


    if obj == nil or nearbyid == nil or drugstype == nil then
        print("banned 2")
        return
    end
    
    if type(obj) ~= "number" then 
        print("banned 3")
        return
    end
    print(tostring(nearbyid))
    if not IsValidNetworkID(nearbyid, src) then
        print("banned 4")
        return
    end
    if drugstype == "Meth" then
        item = "meth"
    elseif drugstype == "Coke" then
        item = "coke" 
    elseif drugstype == "Weed" then
        item = "weed"
    else
        print("[sl-Drugs]: error.")
        TriggerClientEvent("sl-setdrugsinactive:drugs", -1, drugstype, 0)
        return
    end
    if xPlayer.job.name == "police" or xPlayer.job.name == "offpolice" then
        xPlayer.showNotification("Je kan geen drugs plukken als Politie agent!")
        return
    end

    if tonumber(NumberCounter[index]) >= (methCounter + newrandom) and drugstype == tostring("Weed") == false then
        if xPlayer.canCarryItem(item, newrandom) then
            xPlayer.addInventoryItem(item, newrandom)
            methCounter = methCounter + newrandom
            local newmath = math.random(1, 100)
            if newmath < 4 then
                local amountadd = newmath / 10
                TriggerEvent("stadus_skills:addDrugs", src, amountadd)
            end
        else
            xPlayer.showNotification('Je kan niet meer zoveel items dragen!')
        end
    elseif drugstype == "Weed" then
        if xPlayer.canCarryItem(item, newrandom) then
            xPlayer.addInventoryItem(item, newrandom)
            methCounter = methCounter + newrandom
            local newmath = math.random(1, 100)
            if newmath < 4 then
                local amountadd = newmath / 10
                TriggerEvent("stadus_skills:addDrugs", src, amountadd)
            end
        else
            xPlayer.showNotification('Je kan niet meer zoveel items dragen!')
        end
    else
        print("ye this error")
        --TriggerClientEvent("sl-setdrugsinactive:drugs", -1, drugstype, 0)
    end
end)

RegisterCommand("start_newdrugs", function(source, args, rawCommand)
    local nearestHour, nearestMinute, nearestType
    local currentTime = os.date("*t")
    local currentHour = currentTime.hour
    local currentMinute = currentTime.min
    local currentSecond = currentTime.sec
    local currentGameTimer = GetGameTimer()

    for i = 1, #DrugHours do
        local item = DrugHours[i]
        if item.hour > currentHour or (item.hour == currentHour and item.minutes >= currentMinute) then
            nearestHour = currentHour
            nearestMinute = currentMinute

            if currentSecond >= 50 then
                currentMinute = (currentMinute == 59) and 0 or (currentMinute + 1)
            end

            nearestType = item.drug
            DrugHours[i].hour = currentHour
            DrugHours[i].minutes = currentMinute
            break
        end
    end

    if nearestHour == nil or nearestMinute == nil then
        nearestHour = DrugHours[1].hour
        nearestMinute = DrugHours[1].minutes
        nearestType = DrugHours[1].drug
    end

    Wait(500)
    openHours[nearestType] = currentMinute
    openMethhour = true
    currentDrug = nearestType
    timechange[nearestType] = {timeout = currentGameTimer + 1800000}
    print("De eerst volgende actieve drugs is: " .. nearestType .. " om " .. string.format("%02d:%02d", nearestHour, nearestMinute))
end, false)

CreateThread(function()
    for hour = 0, 23 do
        for minute = 0, 59 do
            table.insert(TimeCounter, string.format("%02d:%02d", hour, minute))
            if isThisintable(MethHours, minute) then
                table.insert(NumberCounter, math.random(900, 1000)) 
            elseif isThisintable(CokeHours, minute) then
                table.insert(NumberCounter, math.random(1000, 1100)) 
            else
                table.insert(NumberCounter, math.random(900, 1100))
            end
        end
    end

    while #MethHours < 6 do
        local minutes = math.random(0, 59)
        if not isThisintable(MethHours, minutes) then
            table.insert(MethHours, minutes)
        end
    end

    while #CokeHours < 9 do
        local minutes = math.random(0, 59)
        if not isThisintable(CokeHours, minutes) then
            table.insert(CokeHours, minutes)
        end
    end
    local randomCount = 0
    
    for _, minutes in ipairs(MethHours) do
        if randomCount < 3 then
            local hour = math.random(0, 11)
            local outhour = (hour == 11 and minutes >= 30) and 12 or (hour + math.floor((minutes + 30) / 60))
            local outminute = (minutes + 30) % 60
            table.insert(DrugHours, {hour = hour, minutes = minutes, outhour = outhour, outminute = outminute, drug = "Meth", taken = false})
            randomCount = randomCount + 1
        else
            local hour = math.random(11, 23)
            local outhour = (hour == 23 and minutes >= 30) and 0 or (hour + math.floor((minutes + 30) / 60))
            local outminute = (minutes + 30) % 60
            table.insert(DrugHours, {hour = hour, minutes = minutes, outhour = outhour, outminute = outminute, drug = "Meth", taken = false})
        end
    end
    
    randomCount = 0
    
    for _, minutes in ipairs(CokeHours) do
        if randomCount < 3 then
            local hour = math.random(0, 11)
            local outhour = (hour == 11 and minutes >= 30) and 12 or (hour + math.floor((minutes + 30) / 60))
            local outminute = (minutes + 30) % 60
            table.insert(DrugHours, {hour = hour, minutes = minutes, outhour = outhour, outminute = outminute, drug = "Coke", taken = false})
            randomCount = randomCount + 1
        else
            local hour = math.random(11, 23)
            local outhour = (hour == 23 and minutes >= 30) and 0 or (hour + math.floor((minutes + 30) / 60))
            local outminute = (minutes + 30) % 60
            table.insert(DrugHours, {hour = hour, minutes = minutes, outhour = outhour, outminute = outminute, drug = "Coke", taken = false})
        end
    end



    for k,v in pairs(VerwerkLocaties) do
        table.insert(VerwerkData, {type = k, location = VerwerkLocaties[k][math.random(#VerwerkLocaties[k])]})
    end

    for k,v in pairs(VerkoopLocaties) do
        table.insert(VerkoopData, {type = k, location = VerkoopLocaties[k][math.random(#VerwerkLocaties[k])]})
    end
    

    table.sort(DrugHours, function(a, b) return a.hour < b.hour or (a.hour == b.hour and a.minutes < b.minutes) end)
    
    while #MethHours < 5 or #CokeHours < 7 or #DrugHours < 12 do 
        Wait(1000)
    end

    local descriptionMeth = ""
    local descriptionCoke = ""
    local verwerkDataMeth = {}
    local verwerkDataCoke = {}
    
    for _, item in ipairs(DrugHours) do
        local index = table.checkvaluesOf(TimeCounter, string.format("%02d:%02d", item.hour, item.minutes))
        local itemDescription = string.format("Hour: %02d:%02d - %s: %d items - OutHour: %02d:%02d\n", item.hour, item.minutes, item.drug, NumberCounter[index], (item.hour + math.floor((item.minutes + 30) / 60)) % 24, (item.minutes + 30) % 60)
    
        local verwerkDataFiltered = {}
        for _, verwerkItem in ipairs(VerwerkData) do
            if verwerkItem.type == item.drug then
                table.insert(verwerkDataFiltered, verwerkItem)
            end
        end
    
        if item.drug == "Meth" then
            descriptionMeth = descriptionMeth .. itemDescription
            verwerkDataMeth = verwerkDataFiltered
        elseif item.drug == "Coke" then
            descriptionCoke = descriptionCoke .. itemDescription
            verwerkDataCoke = verwerkDataFiltered
        end
    end

    descriptionMeth = descriptionMeth .. "\nVerwerkData:\n"
    for _, verwerkItem in ipairs(verwerkDataMeth) do
        descriptionMeth = descriptionMeth .. string.format("- %s\n", verwerkItem.location)
    end
    
    descriptionCoke = descriptionCoke .. "\nVerwerkData:\n"
    for _, verwerkItem in ipairs(verwerkDataCoke) do
        descriptionCoke = descriptionCoke .. string.format("- %s\n", verwerkItem.location)
    end
    
    local discordInfo = {
        ["color"] = "65280",
        ["type"] = "green",
        ["title"] = "Active Meth",
        ["description"] = descriptionMeth,
        ["footer"] = {
            ["text"] = "sl-Drugs",
        }
    }
    
    local discordInfo2 = {
        ["color"] = "65280",
        ["type"] = "green",
        ["title"] = "Active Coke",
        ["description"] = descriptionCoke,
        ["footer"] = {
            ["text"] = "sl-Drugs",
        }
    }
    
    PerformHttpRequest('https://discord.com/api/webhooks/1097569500032942160/nyLZMXnSeDPtqCBclpms6E9fu29X13yPLHegea-85y6hnWr1ZYydfxgLeqT5pN1eVOS6', function(err, text, headers) end, 'POST', json.encode({ username = 'SL-Logs', embeds = { discordInfo } }), { ['Content-Type'] = 'application/json' })
    PerformHttpRequest('https://discord.com/api/webhooks/1097569500032942160/nyLZMXnSeDPtqCBclpms6E9fu29X13yPLHegea-85y6hnWr1ZYydfxgLeqT5pN1eVOS6', function(err, text, headers) end, 'POST', json.encode({ username = 'SL-Logs', embeds = { discordInfo2 } }), { ['Content-Type'] = 'application/json' })
end)

RegisterCommand("print_drugs_info", function(source, args, rawCommand)
    local descriptionMeth = ""
    local descriptionCoke = ""
    
    for _, item in ipairs(DrugHours) do
        local index = table.checkvaluesOf(TimeCounter, string.format("%02d:%02d", item.hour, item.minutes))
        local itemDescription = string.format("Hour: %02d:%02d - %s: %d items - OutHour: %02d:%02d\n", item.hour, item.minutes, item.drug, NumberCounter[index], (item.hour + math.floor((item.minutes + 30) / 60)) % 24, (item.minutes + 30) % 60)
        if item.drug == "Meth" then
            descriptionMeth = descriptionMeth .. itemDescription
        elseif item.drug == "Coke" then
            descriptionCoke = descriptionCoke .. itemDescription
        end
    end


    local discordInfo = {
        ["color"] = "65280",
        ["type"] = "green",
        ["title"] = "Active Meth",
        ["description"] = descriptionMeth,
        ["footer"] = {
            ["text"] = "sl-Drugs",
        }
    }

    local discordInfo2 = {
        ["color"] = "65280",
        ["type"] = "green",
        ["title"] = "Active Coke",
        ["description"] = descriptionCoke,
        ["footer"] = {
            ["text"] = "sl-Drugs",
        }
    }

    PerformHttpRequest('https://discord.com/api/webhooks/1093146094357184664/3mqpI7W9nHmby05WBs9jhVkZ1qlCmzl2r8DGziOJ8DsKXk6_UV4lrHRMAnHZX_wgU53g', function(err, text, headers) end, 'POST', json.encode({ username = 'SL-Logs', embeds = { discordInfo } }), { ['Content-Type'] = 'application/json' })
    PerformHttpRequest('https://discord.com/api/webhooks/1093146094357184664/3mqpI7W9nHmby05WBs9jhVkZ1qlCmzl2r8DGziOJ8DsKXk6_UV4lrHRMAnHZX_wgU53g', function(err, text, headers) end, 'POST', json.encode({ username = 'SL-Logs', embeds = { discordInfo2 } }), { ['Content-Type'] = 'application/json' })
end, false)

RegisterCommand("get_info_drugs", function(source, args, rawCommand)
    print(tostring(openHours["Meth"]))
    print(tostring(openHours["Coke"]))

    print(currentDrug)
    for drug, data in pairs(timechange) do
        print(tostring(drug .. " | " .. data.timeout))
    end
end, false)

function isThisintable(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function table.checkvaluesOf(table, val)
    for i=1,#table do
        if table[i] == val then
            return i
        end
    end
    return nil
end

function table.find(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

local drugsstarted = {}
StartServerside = function(src)
    if drugsstarted[src] then
        return
    end
    TriggerEvent("esx_drugs:start:weed", src)
    Citizen.CreateThread( function()
        while true do
            Citizen.Wait(5000)
            TriggerEvent('esx_drugs:openDrugs', 'meth', src)
            Wait(5000)
            TriggerEvent('esx_drugs:openDrugs', 'coke', src)
        end
    end)
    drugsstarted[src] = true
end

RegisterServerEvent("esx_drugs:start:weed")
AddEventHandler("esx_drugs:start:weed", function(src)
    local coords = vector3(1850.298, 4924.742, 44.78823)
    TriggerClientEvent("sl-setactivemode:drugs", src, "Weed", coords)
end)


local activeDrugs, activeVerwerk = {}, {}

RegisterServerEvent('esx_drugs:openDrugs')
AddEventHandler('esx_drugs:openDrugs', function(drugs)
    local value = 0
    local hour, minutes = tonumber(os.date('%H')), tonumber(os.date('%M'))
    for k, v in pairs(DrugHours) do
        --print(v.drug .. " | " .. v.hour .. ":" .. v.minutes .. " | " .. v.outhour .. ":" .. v.outminute)
        if v.drug and (v.hour == hour) and (v.minutes == minutes) then
            v.taken = true
            local randomIndex = math.random(1, #DrugsLocaties[v.drug])
            local coords = DrugsLocaties[v.drug][randomIndex].coords
            local insert = InsertPlayerIntoNewDrug(v.drug, v.minutes, coords, minutes)
            if insert then
                local discordInfoactivemeth = {
                    ["color"] = "65280",
                    ["type"] = "green",
                    ["title"] = "Drugs is Active!",
                    ["description"] = v.drug .. " is Actief geworden op locatie: \n Coords: " .. coords,
                    ["footer"] = {
                        ["text"] = "sl-Drugs",
                    }
                }
                PerformHttpRequest('https://discord.com/api/webhooks/1093146094357184664/3mqpI7W9nHmby05WBs9jhVkZ1qlCmzl2r8DGziOJ8DsKXk6_UV4lrHRMAnHZX_wgU53g', function(err, text, headers) end, 'POST', json.encode({ username = 'SL-Logs', embeds = { discordInfoactivemeth } }), { ['Content-Type'] = 'application/json' })
            end
        elseif (v.outhour == hour) and (v.outminute == minutes) then
            if v.taken then
                for _, player in ipairs(GetPlayers()) do
                    local playerId = tonumber(player)
                    if not activeDrugs[playerId][v.drug] then
                        activeDrugs[playerId][v.drug] = true
                    end

                    if activeDrugs[playerId][v.drug] == true and currentDrug == v.drug and currentMinute == v.outminute then
                        activeDrugs[playerId][v.drug] = nil
                        TriggerClientEvent("sl-setdrugsinactive:drugs", playerId, v.drug)
                        print(v.drug .. " has been stopped due to time.")
                    end
                end
            end
        end
    end

    Wait(1000)
    for _, player in ipairs(GetPlayers()) do
        local playerId = tonumber(player)
        if activeVerwerk[playerId] == nil then
            activeVerwerk[playerId] = true
        end
        if activeVerwerk[playerId] and activeVerwerk[playerId] ~= false then
            activeVerwerk[playerId] = false
            TriggerClientEvent("esx_drugs:send:verwerkdata", playerId, VerwerkData, VerkoopData)
        end
    end
end)

DeleteActiveDrug = function(type, speler, curmin)
    for k,v in pairs(activeDrugs[speler]) do
        if k == type then
            for k2,v2 in pairs(activeDrugs[speler][k]) do
                if v2 ~= curmin then
                    activeDrugs[speler][k] = nil;
                    return true
                end
            end
        end
    end
    return false
end

InsertPlayerIntoNewDrug = function(type, min, coordsdrug, currentminute)
    local deleted = false
    for _, player in ipairs(GetPlayers()) do
        local playerId = tonumber(player)
        if not activeDrugs[playerId] then
            activeDrugs[playerId] = {}
        end

        deleted = DeleteActiveDrug(type, playerId, currentminute)
        if not activeDrugs[playerId][type] then
            activeDrugs[playerId][type] = {}
        end

        Wait(50)
        if activeDrugs[playerId][type] and activeDrugs[playerId][type][1] == currentminute and not deleted then
            --print("aa")
        else
            print("[sl-Drugs]: locatie actief: " .. type .. ": " .. coordsdrug .. " voor speler: " .. playerId)
            table.insert(activeDrugs[playerId][type], min)
            TriggerClientEvent("sl-setactivemode:drugs", playerId, type, coordsdrug)
        end
    end
end

print("script made by 4Slang/SL scripts")

