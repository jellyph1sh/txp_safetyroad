local function LoadModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then
        return 0
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(250)
    end
    return hash
end

local function spawnPropFromEntity(entity, model, isFreeze)
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.5, 0.5))
    local w = GetEntityHeading(ped)
    local hash = LoadModel(model)
    local prop = CreateObject(hash, x, y, z, true, true, false)
    SetEntityAsMissionEntity(prop, true, true)
    SetEntityHeading(prop, w)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, isFreeze)
    SetModelAsNoLongerNeeded(hash)
end

local function removePropFromEntity(entity, propsModelsList)
    local x, y, z = table.unpack(GetEntityCoords(entity))
    for i, model in pairs(propsModelsList) do
        local hash = GetHashKey(model)
        local prop = GetClosestObjectOfType(x, y, z, 5.0, hash, true, false, false)
        if prop ~= nil then
            DeleteEntity(prop)
        end
    end
end

local function CreateSafetyRoadMenu(propsModelsList)
    menuPool = NativeUI.CreatePool()
    safetyRoadMenu = NativeUI.CreateMenu("Safety Road", "~b~It should be useful for you to be safe. ;)")
    menuPool:Add(safetyRoadMenu)

    local isFreeze = false
    local roadPropsList = NativeUI.CreateListItem("Road Props", propsModelsList, 1)
    local freezeCheckBox = NativeUI.CreateCheckboxItem("Freeze Road Prop", isFreeze, "Strong protection if you activate this!")
    local deleteRoadProp = NativeUI.CreateItem("Delete Closest Road Prop", "~b~It's better when there's nothing in the way.")
    
    safetyRoadMenu:AddItem(roadPropsList)
    safetyRoadMenu:AddItem(freezeCheckBox)
    safetyRoadMenu:AddItem(deleteRoadProp)
    safetyRoadMenu.OnListSelect = function(sender, item, index)
        if item == roadPropsList then
            local ped = GetPlayerPed(-1)
            spawnPropFromEntity(ped, propsModelsList[index], isFreeze)
        end
    end
    safetyRoadMenu.OnCheckboxChange = function(sender, item, checked)
        if item == freezeCheckBox then
            isFreeze = checked
        end
    end
    safetyRoadMenu.OnItemSelect = function(sender, item, index)
        if item == deleteRoadProp then
            local ped = GetPlayerPed(-1)
            removePropFromEntity(ped, propsModelsList)
        end
    end
    
    menuPool:RefreshIndex()
end

local function ShowSafetyRoadMenu()
    Citizen.CreateThread(function()
        safetyRoadMenu:Visible(true)
        menuPool:MouseControlsEnabled(false)
        menuPool:MouseEdgeEnabled(false)
        menuPool:ControlDisablingEnabled(false)

        while safetyRoadMenu:Visible() do
            menuPool:ProcessMenus()
            Citizen.Wait(0)
        end
    end)
end

RegisterNetEvent("txp_safetyroad:openmenu")
AddEventHandler("txp_safetyroad:openmenu", function()
    CreateSafetyRoadMenu(Config.RoadPropsModels)
    ShowSafetyRoadMenu()
end)
