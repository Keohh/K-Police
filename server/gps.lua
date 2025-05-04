local onDutyPlayers = {} -- [src] = true
local trackedVehicles = {} -- [netId] = { owner = src, model = `police`, name = "Keo", department = "LSPD" }

RegisterNetEvent("vblips:setDuty", function(status)
    local src = source
    onDutyPlayers[src] = status
    if not status then
        for netId, v in pairs(trackedVehicles) do
            if v.owner == src then
                trackedVehicles[netId] = nil
            end
        end
    end
    SyncAllBlips()
end)

RegisterNetEvent("vblips:updateVehicle", function(netId, model)
    local src = source
    local name = GetPlayerName(src)
    local info = Config.TrackedVehicles[model]
    if not info then return end

    trackedVehicles[netId] = {
        owner = src,
        model = model,
        name = name,
        department = info.department
    }

    SyncAllBlips()
end)

AddEventHandler("playerDropped", function()
    local src = source
    onDutyPlayers[src] = nil
    for netId, v in pairs(trackedVehicles) do
        if v.owner == src then
            trackedVehicles[netId] = nil
        end
    end
    SyncAllBlips()
end)

function SyncAllBlips()
    local data = {}
    for netId, v in pairs(trackedVehicles) do
        if onDutyPlayers[v.owner] then
            data[netId] = v
        end
    end

    for _, id in ipairs(GetPlayers()) do
        id = tonumber(id)
        if onDutyPlayers[id] then
            TriggerClientEvent("vblips:syncBlips", id, data)
        end
    end
end

-- Exported on-duty status
exports("IsPlayerOnDuty", function(source)
    return onDutyPlayers[source] == true
end)

RegisterNetEvent("brake:checkDuty", function()
    local src = source
    local isOnDuty = onDutyPlayers[src] == true
    TriggerClientEvent("brake:receiveDutyStatus", src, isOnDuty)
end)
