local Bezig = false
VerwerkTable, VerkoopTable = {}, {}
RegisterNetEvent("esx_drugs:send:verwerkdata")
AddEventHandler("esx_drugs:send:verwerkdata", function(infotable, cb)
    local blip = nil
    VerwerkTable = infotable
    VerkoopTable = cb

    while VerwerkTable == nil do
        Wait(50)
    end

    StartVerwerkThread()
    print("['esx_drugs']: Fully loaded succesfully.")
end)




StartVerwerkThread = function() 
    
    for k,v in pairs(VerwerkTable) do
        if v.type == "Weed" then
            blip = AddBlipForCoord(v.location.x, v.location.y, v.location.z)
            SetBlipSprite (blip, 496)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, 1.1)
            SetBlipColour (blip, 25)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Wiet Verwerk")
            EndTextCommandSetBlipName(blip)	
        end
    end

    for k,v in pairs(VerkoopTable) do
        if v.type == "Weed" then
            blip = AddBlipForCoord(v.location.x, v.location.y, v.location.z)
            SetBlipSprite (blip, 496)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, 1.1)
            SetBlipColour (blip, 25)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Wiet Verkoop")
            EndTextCommandSetBlipName(blip)	
        end
    end
    
    while true do
        Wait(1)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local distance = nil
        local minDistance = 10000
        for k,v in pairs(VerwerkTable) do
            if v.type == 'Meth' or v.type == 'Coke' or v.type == 'Weed' then
                distance = #(coords - v.location)
                if distance < 20 then
                    DrawMarker(1, v.location, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 4 * 1.5, 4 * 1.5, 4 * 0.5, 80, 199, 80, 100, false, true, 2, false, false, false, false)
                    if distance < 3.85 and not Bezig then
                        ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om zakjes te verpakken")
                        if IsControlJustPressed(0, 38) then 
                            Bezig = true
                            TriggerServerEvent("esx_drugs:request:verwerking", VerwerkTable, v.type)
                        end
                    elseif distance > 3.90 and Bezig then
                        ESX.ShowNotification("Je bent uit de cirkel gelopen dus is de verwerk gestopt.")
                        TriggerServerEvent("esx_drugs:leave:drugstype")
                        ESX.UI.Menu.CloseAll()
                        Bezig = false
                    end

                    if distance < minDistance then
                        minDistance = distance
                    end
                end
            end
        end

        for k,v in pairs(VerkoopTable) do
            if v.type == 'Meth' or v.type == 'Coke' or v.type == 'Weed' then
                distance = #(coords - v.location)
                if distance < 20 then
                    DrawMarker(1, v.location, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 4 * 1.5, 4 * 1.5, 4 * 0.5, 80, 199, 80, 100, false, true, 2, false, false, false, false)
                    if distance < 3.85 and not Bezig then
                        ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om zakjes te verkopen")
                        if IsControlJustPressed(0, 38) then 
                            Bezig = true
                            TriggerServerEvent("esx_drugs:request:verkopen", VerkoopTable, v.type)
                        end
                    elseif distance > 3.90 and Bezig then
                        ESX.ShowNotification("Je bent uit de cirkel gelopen dus is de quicksell gestopt.")
                        TriggerServerEvent("esx_drugs:leave:drugstype_1")
                        ESX.UI.Menu.CloseAll()
                        Bezig = false
                    end
    
                    if distance < minDistance then
                        minDistance = distance
                    end
                end
            end
        end
    end
end