local vehicleHistory = {}
local jsonFilePath = "data/vehicle_history.json"

-- Utility: Save history to file
local function saveHistory()
    local file = io.open(jsonFilePath, "w+")
    if file then
        file:write(json.encode(vehicleHistory, { indent = true }))
        file:close()
    end
end

-- Utility: Clear JSON on stop
local function wipeHistory()
    local file = io.open(jsonFilePath, "w+")
    if file then
        file:write("{}")
        file:close()
    end
end

-- Register command for spawning vehicle
RegisterNetEvent("garage:spawnVehicle")
AddEventHandler("garage:spawnVehicle", function(data)
    local src = source  -- Get the player source (the one who triggered the event)
    local name = GetPlayerName(src) or "Unknown"  -- Get player name (default to "Unknown" if not found)
    local plate = data.plate or "UNKNOWN"  -- Use provided plate or default to "UNKNOWN"
    local model = data.model or "UNKNOWN"  -- Use provided model or default to "UNKNOWN"
    local vehName = data.name or "Unmarked"  -- Use provided vehicle name or default to "Unmarked"

    -- Add action to the player's vehicle history
    vehicleHistory[src] = vehicleHistory[src] or {}
    table.insert(vehicleHistory[src], {
        action = "Spawned",
        vehicle = vehName,
        plate = plate,
        model = model,
        officer = name,
        time = os.date("%m/%d %I:%M %p")  -- Get the current time in a readable format
    })

    -- Save the updated history
    saveHistory()

    -- Trigger client event to actually spawn the vehicle on the player's game client
    local src = source
    print("Server is attempting to spawn vehicle for player:", src, data)  -- Debugging line
    TriggerClientEvent("garage:client:spawnVehicle", src, data)
end)

-- Register command for storing vehicle
RegisterNetEvent("garage:storeVehicle")
AddEventHandler("garage:storeVehicle", function(data)
    local src = source  -- Get the player source
    local name = GetPlayerName(src) or "Unknown"  -- Get player name
    local vehName = data.name or "Unmarked"  -- Use provided vehicle name
    local plate = data.plate or "UNKNOWN"  -- Use provided plate

    -- Add action to the player's vehicle history for storing
    vehicleHistory[src] = vehicleHistory[src] or {}
    table.insert(vehicleHistory[src], {
        action = "Stored",
        vehicle = vehName,
        plate = plate,
        model = data.model or "UNKNOWN",  -- Use model or default to "UNKNOWN"
        officer = name,
        time = os.date("%m/%d %I:%M %p")  -- Get the current time in a readable format
    })

    -- Save the updated history
    saveHistory()
end)

-- Clean up history on resource stop
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        wipeHistory()  -- Clear the history when the resource stops
    end
end)

-- Export function to get vehicle history for a specific player
exports("GetVehicleHistory", function(playerId)
    return vehicleHistory[playerId] or {}  -- Return the player's history or an empty table if not found
end)

