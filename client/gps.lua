local isOnDuty = false
local vehicleBlips = {} -- [netId] = { blip, netId }
local myTrackedVehicles = {}

RegisterCommand("onduty", function()
    isOnDuty = not isOnDuty
    TriggerServerEvent("vblips:setDuty", isOnDuty)
    if isOnDuty then
        StartVehicleCheckLoop()
    else
        ClearVehicleBlips()
    end
    print("[vblips] On duty:", isOnDuty)
    print("[Handbrake] Access:", isOnDuty)
    Notify(isOnDuty and "10-8 and Restocked" or "10-7. night shift has it from here")
end)

function StartVehicleCheckLoop()
    CreateThread(function()
        while isOnDuty do
            local ped = PlayerPedId()
            local vehicles = GetGamePool("CVehicle")

            for _, veh in ipairs(vehicles) do
                if GetPedInVehicleSeat(veh, -1) == ped then
                    local model = GetEntityModel(veh)
                    if Config.TrackedVehicles[model] then
                        local netId = VehToNet(veh)
                        if not myTrackedVehicles[netId] then
                            myTrackedVehicles[netId] = true
                            TriggerServerEvent("vblips:updateVehicle", netId, model)
                        end
                    end
                end
            end

            Wait(2000)
        end
    end)
end

function ClearVehicleBlips()
    for _, data in pairs(vehicleBlips) do
        if DoesBlipExist(data.blip) then
            RemoveBlip(data.blip)
        end
    end
    vehicleBlips = {}
    myTrackedVehicles = {}
end

RegisterNetEvent("vblips:syncBlips", function(vehicles)
    ClearVehicleBlips()

    for netId, data in pairs(vehicles) do
        local vehicle = NetToVeh(netId)
        if DoesEntityExist(vehicle) then
            local coords = GetEntityCoords(vehicle)
            local blip = AddBlipForCoord(coords)

            local model = GetEntityModel(vehicle)
            local info = Config.TrackedVehicles[model]
            local sprite = Config.VehicleBlipSprites[info and info.type] or 56
            local color = Config.DepartmentColors[info and info.department] or 3

            SetBlipSprite(blip, sprite)
            SetBlipColour(blip, color)
            SetBlipScale(blip, 0.8)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(("%s | %s"):format(data.name or "Unknown", data.department or "Police"))
            EndTextCommandSetBlipName(blip)

            vehicleBlips[netId] = {
                blip = blip,
                netId = netId
            }
        end
    end

    -- Blip update loop
    CreateThread(function()
        while isOnDuty and vehicleBlips[netId] do
            for netId, data in pairs(vehicleBlips) do
                local veh = NetToVeh(netId)
                if DoesEntityExist(veh) then
                    SetBlipCoords(data.blip, GetEntityCoords(veh))
                    print("GPS Updated")
                else
                    -- Remove blip if vehicle no longer exists
                    if DoesBlipExist(vehicleBlips[netId].blip) then
                        RemoveBlip(vehicleBlips[netId].blip)
                        print("Vehicle Better Have Deleted")
                    end
                    vehicleBlips[netId] = nil
                    return
                end
            end
            Wait(math.random(7000, 10000)) -- Realistic GPS lag
        end
    end)
    
end)

if Config.Debug then
    RegisterCommand("vblips_debug", function()
        CreateThread(function()
            while true do
                for netId, data in pairs(vehicleBlips) do
                    local veh = NetToVeh(netId)
                    if DoesEntityExist(veh) then
                        local coords = GetEntityCoords(veh)
                        DrawText2D(("NetId: %s | Coords: %.2f %.2f %.2f"):format(netId, coords.x, coords.y, coords.z), 0.4, 0.95 - (0.02 * netId))
                    end
                end
                Wait(0)
            end
        end)
    end)
end

function DrawText2D(text, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function Notify(msg)
    if Config.NotificationSystem == "mythic" then
        exports["mythic_notify"]:DoHudText("inform", msg)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, true)
    end
end
