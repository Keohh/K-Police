local isMenuOpen = false
local isOnDuty = false
local isInZone = false

local ox = exports.ox_lib

-- Create polyzone with enter/exit callbacks
local spawnZone = lib.zones.poly({
    name = "pdpark",
    points = {
        vec3(-448.66201782227, 7129.3354492188, 21.5932),
        vec3(-450.71133422852, 7142.9033203125, 21.5932),
        vec3(-459.62289428711, 7140.1484375, 21.5932),
        vec3(-453.60540771484, 7123.4907226562, 21.5932)
    },
    debug = false,
    onEnter = function()
        isInZone = true
        lib.showTextUI("Open Garage", {
            position = 'bottom-center',
            icon = 'car',
        })
        TriggerServerEvent("brake:checkDuty")
    end,
    onExit = function()
        isInZone = false
        lib.hideTextUI()
    end
})

-- Listen for duty status from server
RegisterNetEvent("brake:receiveDutyStatus", function(status)
    isOnDuty = status
end)

-- Garage open command
RegisterCommand("garage", function()
    if not isOnDuty then
        --exports["mythic_notify"]:DoHudText('error', 'You must be on duty to open the garage.')
        lib.notify({
            title = 'Not On Duty!',
            description = 'You must be on duty to open the garage.',
            type = 'error'
        })
        return
    end

    if not isInZone then
        --exports["mythic_notify"]:DoHudText('error', 'You are not in a valid area to spawn a vehicle.')
        lib.notify({
            title = 'Wrong Area!',
            description = 'You are not in a valid area to spawn a vehicle.',
            type = 'error'
        })
        return
    end

    SetNuiFocus(true, true)
    isMenuOpen = true
    local playerName = GetPlayerName(PlayerId())

    SendNUIMessage({
        action = "showGarage",
        player = playerName,
        vehicles = GarageConfig.Vehicles
    })
end, false)

-- NUI callbacks
RegisterNUICallback("closeGarage", function(_, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb("ok")
end)

RegisterNUICallback("spawnVehicle", function(data, cb)
    TriggerServerEvent("garage:spawnVehicle", data)
    cb("ok")
end)

RegisterNUICallback("storeVehicle", function(data, cb)
    TriggerServerEvent("garage:storeVehicle", data)
    cb("ok")
end)

-- Server-triggered vehicle spawn
RegisterNetEvent("garage:client:spawnVehicle")
AddEventHandler("garage:client:spawnVehicle", function(data)
    local model = GetHashKey(data.model)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)

    SetVehicleNumberPlateText(vehicle, data.plate)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
end)

-- Clean up UI on resource stop
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        lib.hideTextUI()
    end
end)
