ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
end)

local taille = 1.0
local four_zero = vec4(0.0, 0.0, 0.0, 0.0)
local hasgloves = false

local Gloves = {}

function GantsOn()
    local ped = PlayerPedId()
    local hash = GetHashKey('prop_boxing_glove_01')
    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end
    local pos = GetEntityCoords(ped)
    local gloveA = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    local gloveB = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    table.insert(Gloves,gloveA)
    table.insert(Gloves,gloveB)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(gloveA,false)
    SetEntityCollision(gloveA,false,true)
    ActivatePhysics(gloveA)
    FreezeEntityPosition(gloveB,false)
    SetEntityCollision(gloveB,false,true)
    ActivatePhysics(gloveB)
    if not ped then ped = PlayerPedId(); end -- gloveA = L, gloveB = R
    AttachEntityToEntity(gloveA, ped, GetPedBoneIndex(ped, 0xEE4F), 0.05, 0.00,  0.04,     00.0, 90.0, -90.0, true, true, false, true, 1, true) -- object is attached to right hand 
    AttachEntityToEntity(gloveB, ped, GetPedBoneIndex(ped, 0xAB22), 0.05, 0.00, -0.04,     00.0, 90.0,  90.0, true, true, false, true, 1, true) -- object is attached to right hand 
end

function GantsOff()
    for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
end

for k,v in pairs(Boxing) do
    local pointname = "Boxing_"..k
    pointname = lib.points.new(vec(v.x,v.y,v.z), v.size+3, {})

    function pointname:nearby()
        DrawMarker(v.type, self.coords.x, self.coords.y, self.coords.z-0.95, four_zero, 180.0, 0.0, v.size, v.size, v.size, v.r, v.g, v.b, 255, false, true, 2, nil, nil, false)
        if self.currentDistance < v.distance then
            ESX.ShowHelpNotification(v.text)
            if IsControlJustReleased(0, 38) then
                if hasgloves == false then
                    hasgloves = true
                    GantsOn()
                else
                    hasgloves = false
                    GantsOff()
                end
            end
        end
    end

    function pointname:onExit()
        GantsOff()
    end
end


RegisterCommand("drawmzone",function()
    while true do
        local tpose = GetEntityCoords(PlayerPedId())
        Citizen.InvokeNative(0x28477EC23D892089,25, tpose.x, tpose.y, tpose.z-0.95, four_zero, 180.0, 0.0, taille,taille,taille, 214, 48, 49,255, false, true, 2, nil, nil, false)
        Citizen.Wait(0)
    end
end)