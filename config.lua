Config = {}

-- Enable or disable debug draw text
Config.Debug = true

-- Vehicles with department and type
Config.TrackedVehicles = {
    [`police`] = { department = "LSPD", type = "sedan", },
    [`police2`] = { department = "LSPD", type = "suv" },
    [`sheriff`] = { department = "BCSO", type = "truck" },
    [`sheriff2`] = { department = "BCSO", type = "suv" }
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


-- Notification system ("default" or "mythic")
Config.NotificationSystem = "mythic"


Config.Cars = {
    'POLICE', 'POLICE2', 'POLICE3', 'POLICE4', 'POLICEB', 'POLICEOLD1', 'POLICEOLD2',
}

-- Command to toggle handbrake (bindable)
Config.HandbrakeCommand = 'togglebrake'
Config.HandbrakeKey = 'SPACE' -- default key

-- Exit key to block
Config.ExitControl = 75