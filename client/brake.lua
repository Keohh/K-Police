-- Vehicle brake states tracked by vehicle network ID
local brakeStates = {}
local ox = exports.ox_lib
local isOnDuty = false

-- Request duty status when needed
RegisterNetEvent("brake:receiveDutyStatus", function(status)
    isOnDuty = status
end)

-- Periodically request duty status from the server
CreateThread(function()
    while true do
        Wait(2000)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            TriggerServerEvent("brake:checkDuty")
        end
    end
end)

-- Helper: check if vehicle is in config
local function isTrackedVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local class = GetVehicleClass(vehicle)
    return class == 18
end

-- Helper: notify player using Mythic Notify
local function notify(text)
    exports["mythic_notify"]:DoHudText("inform", text)
end

-- Apply brake state
local function applyBrakeState(vehicle, state)
    local netId = VehToNet(vehicle)
    brakeStates[netId] = state

    SetVehicleHandbrake(vehicle, state)

    if state then
        -- Engaging the brake
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5.0, "shift", 1.0)
        print("[Handbrake State]: Engaged")
    else
        -- Releasing the brake
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5.0, "unshift", 1.0)
        print("[Handbrake State]: Disengaged")
    end
end

-- Toggle brake via keybind
RegisterCommand(Config.HandbrakeCommand, function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
    if not isTrackedVehicle(vehicle) then return end

    if not isOnDuty then
        --exports["mythic_notify"]:DoHudText("error", "You don't know how to shift the car.")
        lib.notify({
            title = 'Uh-Oh!',
            description = 'You don\'t know how to shift the car.',
            type = 'error'
        })
        return
    end

    local netId = VehToNet(vehicle)
    local newState = not brakeStates[netId]
    applyBrakeState(vehicle, newState)

    --notify(newState and Config.NotifyOn or Config.NotifyOff)
end, false)

-- Bind key
RegisterKeyMapping(Config.HandbrakeCommand, 'Toggle Parking Brake', 'keyboard', Config.HandbrakeKey)

-- Main thread: manage control based on brake state
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) ~= ped then goto continue end
            if not isTrackedVehicle(vehicle) then goto continue end

            local netId = VehToNet(vehicle)

            -- Initialize brake state on first entry
            if brakeStates[netId] == nil then
                applyBrakeState(vehicle, true)
            end

            local engaged = brakeStates[netId]

            if engaged then
                DisableControlAction(0, 71, true) -- accelerate
                DisableControlAction(0, 72, true) -- brake
                DisableControlAction(0, 59, true) -- steering
            else
                DisableControlAction(0, Config.ExitControl, true)
            end
        else
            Wait(300)
        end

        ::continue::
    end
end)

-- Prevent exit when brake not engaged
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) ~= ped then goto skip end
            if not isTrackedVehicle(vehicle) then goto skip end

            local netId = VehToNet(vehicle)
            if brakeStates[netId] == false then
                DisableControlAction(0, Config.ExitControl, true)
                if IsControlJustPressed(0, Config.ExitControl) then
                    notify(Config.NotifyExit)
                end
            end
        end

        ::skip::
    end
end)
