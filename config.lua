Config = {}

-- Enable or disable debug draw text
Config.Debug = true

-- Vehicles with department and type
Config.TrackedVehicles = {
    [`police`] = { department = "LSPD", type = "sedan", },
    [`police2`] = { department = "LSPD", type = "suv" },
    [`sheriff`] = { department = "BCSO", type = "truck" },
    [`sheriff2`] = { department = "BCSO", type = "suv" },
    [`fhp16stfpiu`] = { department = "FHP", type = "suv"},
    
}

GarageConfig = {
    Vehicles = {
        {
            name = "FHP Explorer",
            model = "fhp16stfpiu",
            plate = "FHP007",
            rank = "Officer I"
        },
    }
}


-- Vehicle type to blip sprite
Config.VehicleBlipSprites = {
    sedan = 56,
    suv = 67,
    truck = 477
}

-- Department to blip color
Config.DepartmentColors = {
    LSPD = 3,   -- blue
    BCSO = 21   -- brown/gold
}


-- Notification system ("default" or "mythic" or "ox")
Config.NotificationSystem = "ox"

-- Command to toggle handbrake (bindable)
Config.HandbrakeCommand = 'togglebrake'
Config.HandbrakeKey = 'SPACE' -- default key

-- Exit key to block
Config.ExitControl = 75

Config.ParkingSpots = {
    { location = vector4(-458.6504, 7122.8276, 21.6554, 11.0199), isOccupied = false },
    { location = vector4(-463.1946, 7121.8540, 21.6526, 17.8689), isOccupied = false },
    { location = vector4(-467.7867, 7119.8540, 21.6572, 19.6179), isOccupied = false },
    { location = vector4(-472.5283, 7118.2373, 21.6566, 22.0369), isOccupied = false },
    { location = vector4(-477.6648, 7117.1011, 21.6558, 16.6004), isOccupied = false }
}

Config.SpawnZone = {
    min = vector3(-451.3, 7129.2, 20.68),
    max = vector3(-451.3, 7129.2, 24.68)
}
