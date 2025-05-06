-- Static Blip Configurations
local StaticBlips = {
    {
        title = "Sheriffs Station",
        colour = 31,
        id = 60,
        coords = vec3(-470.5855, 7096.9741, 22.3837)
    },
    {
        title = "Fire Department",
        colour = 49,
        id = 60,
        coords = vec3(-429.2061, 7082.6812, 21.6757)
    },
    {
        title = "Hospital",
        colour = 2,
        id = 61,
        coords = vector3(-3526.7947, 6420.7793, 43.0090)
    },
    {
        title = "Hospital",
        colour = 2,
        id = 61,
        coords = vector3(-535.0728, 7378.1387, 12.8352)
    },
}

-- Function to create static blips
function CreateStaticBlips()
    for _, blipInfo in pairs(StaticBlips) do
        local blip = AddBlipForCoord(blipInfo.coords.x, blipInfo.coords.y, blipInfo.coords.z)
        SetBlipSprite(blip, blipInfo.id)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.85)
        SetBlipColour(blip, blipInfo.colour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipInfo.title)
        EndTextCommandSetBlipName(blip)
    end
end

-- Call the function when the client loads
CreateThread(function()
    CreateStaticBlips()
end)

local noPedRadius = 50.0

-- Start blocking on resource start
CreateThread(function()
    BlockPedsAtStaticBlips(StaticBlips, noPedRadius)
end)

function BlockPedsAtStaticBlips(blipList, radius)
    CreateThread(function()
        while true do
            Wait(0)
            for _, blip in pairs(blipList) do
                ClearAreaOfPeds(blip.coords.x, blip.coords.y, blip.coords.z, radius, 1)
            end
        end
    end)
end