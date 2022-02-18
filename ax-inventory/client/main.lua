QBCore = nil

inInventory = false
hotbarOpen = false

local inventoryTest = {}
local currentWeapon = nil
local CurrentWeaponData = {}
local currentOtherInventory = nil

local Drops = {}
local CurrentDrop = 0
local DropsNear = {}

local CurrentVehicle = nil
local CurrentGlovebox = nil
local CurrentStash = nil
local isCrafting = false

local showTrunkPos = false
Citizen.CreateThread(function ()
    Citizen.Wait(2000)
    while true do
            Citizen.Wait(0)
            HideHudComponentThisFrame(19)
            HideHudComponentThisFrame(20)
            BlockWeaponWheelThisFrame()
            DisableControlAction(0, 37,true)
    end
end)
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

RegisterNetEvent('inventory:client:CheckOpenState')
AddEventHandler('inventory:client:CheckOpenState', function(type, id, label)
    local name = QBCore.Shared.SplitStr(label, "-")[2]
    if type == "stash" then
        if name ~= CurrentStash or CurrentStash == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "trunk" then
        if name ~= CurrentVehicle or CurrentVehicle == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "glovebox" then
        if name ~= CurrentGlovebox or CurrentGlovebox == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    end
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon')
AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
end)

function GetClosestVending()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local object = nil
    for _, machine in pairs(Config.VendingObjects) do
        local ClosestObject = GetClosestObjectOfType(pos.x, pos.y, pos.z, 50.0, GetHashKey(machine), 0, 0, 0)
        if ClosestObject ~= 0 and ClosestObject ~= nil then
            if object == nil then
                object = ClosestObject
            end
        end
    end
    return object
end
RegisterNetEvent('randPickupAnim')
AddEventHandler('randPickupAnim', function()
    while not HasAnimDictLoaded("pickup_object") do RequestAnimDict("pickup_object") Wait(100) end
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)

function PlayToggleEmote()
    print('Lauda Sbaka Chota Hai')
end


function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--[[Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)
        local inRange = false
        local VendingMachine = GetClosestVending()

        if VendingMachine ~= nil then
            local VendingPos = GetEntityCoords(VendingMachine)
            local Distance = GetDistanceBetweenCoords(pos, VendingPos.x, VendingPos.y, VendingPos.z, true)
            if Distance < 20 then
                inRange = true
                if Distance < 1.5 then
                    DrawText3Ds(VendingPos.x, VendingPos.y, VendingPos.z, '~g~E~w~ - Buy drinks')
                    if IsControlJustPressed(0, Keys["E"]) then
                        local ShopItems = {}
                        ShopItems.label = "Drankautomaat"
                        ShopItems.items = Config.VendingItem
                        ShopItems.slots = #Config.VendingItem
                        TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_"..math.random(1, 99), ShopItems)
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(1)
    end
end)]]

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if showTrunkPos and not inInventory then
            local vehicle = QBCore.Functions.GetClosestVehicle()
            if vehicle ~= 0 and vehicle ~= nil then
                local pos = GetEntityCoords(GetPlayerPed(-1))
                local vehpos = GetEntityCoords(vehicle)
                if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 5.0) and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                    local drawpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        drawpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                    end
                    QBCore.Functions.DrawText3D(drawpos.x, drawpos.y, drawpos.z, "Trunk")
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, drawpos) < 2.0) and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        CurrentVehicle = GetVehicleNumberPlateText(vehicle)
                        showTrunkPos = false
                    end
                else
                    showTrunkPos = false
                end
            end
        end
    end
end)
RegisterNetEvent('khol:hotbar')
AddEventHandler('khol:hotbar', function(itemData, type)
    ToggleHotbar(true)
    Wait(1500)
    ToggleHotbar(false)
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DisableControlAction(0, Keys["K"], true)
        DisableControlAction(0, Keys["1"], true)
        DisableControlAction(0, Keys["2"], true)
        DisableControlAction(0, Keys["3"], true)
        DisableControlAction(0, Keys["4"], true)
        DisableControlAction(0, Keys["5"], true)
        if IsDisabledControlJustPressed(0, Keys["K"]) and not isCrafting then
            PlayToggleEmote()
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    local curVeh = nil
                    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                        CurrentGlovebox = GetVehicleNumberPlateText(vehicle)
                        curVeh = vehicle
                        CurrentVehicle = nil
                    else
                        local vehicle = QBCore.Functions.GetClosestVehicle()
                        if vehicle ~= 0 and vehicle ~= nil then
                            local pos = GetEntityCoords(GetPlayerPed(-1))
                            local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                            if (IsBackEngine(GetEntityModel(vehicle))) then
                                trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                            end
                            if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, trunkpos) < 2.0) and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                                if GetVehicleDoorLockStatus(vehicle) < 2 then
                                    CurrentVehicle = GetVehicleNumberPlateText(vehicle)
                                    curVeh = vehicle
                                    CurrentGlovebox = nil
                                else
                                    QBCore.Functions.Notify("Vehicle is locked..", "error")
                                    return
                                end
                            else
                                CurrentVehicle = nil
                            end
                        else
                            CurrentVehicle = nil
                        end
                    end

                    if CurrentVehicle ~= nil then
                        local maxweight = 0
                        local slots = 0
                        if GetVehicleClass(curVeh) == 0 then
                            maxweight = 38000
                            slots = 30
                        elseif GetVehicleClass(curVeh) == 1 then
                            maxweight = 50000
                            slots = 40
                        elseif GetVehicleClass(curVeh) == 2 then
                            maxweight = 75000
                            slots = 50
                        elseif GetVehicleClass(curVeh) == 3 then
                            maxweight = 42000
                            slots = 35
                        elseif GetVehicleClass(curVeh) == 4 then
                            maxweight = 38000
                            slots = 30
                        elseif GetVehicleClass(curVeh) == 5 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 6 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 7 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 8 then
                            maxweight = 15000
                            slots = 15
                        elseif GetVehicleClass(curVeh) == 9 then
                            maxweight = 60000
                            slots = 35
                        elseif GetVehicleClass(curVeh) == 12 then
                            maxweight = 120000
                            slots = 35
                        else
                            maxweight = 60000
                            slots = 35
                        end
                        local other = {
                            maxweight = maxweight,
                            slots = slots,
                        }
                        TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                        OpenTrunk()
                    elseif CurrentGlovebox ~= nil then
                        TriggerServerEvent("inventory:server:OpenInventory", "glovebox", CurrentGlovebox)
                    elseif CurrentDrop ~= 0 then
                        TriggerServerEvent("inventory:server:OpenInventory", "drop", CurrentDrop)
                    else
                        TriggerServerEvent("inventory:server:OpenInventory")
                    end
                end
            end)
        end
            DisableControlAction(0, 37)
        if IsDisabledControlJustReleased(1, 37) then
           TriggerEvent('khol:hotbar')
        end

        if IsDisabledControlJustReleased(0, Keys["1"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 1)
                end
            end)
        end

        if IsDisabledControlJustReleased(0, Keys["2"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 2)
                end
            end)
        end

        if IsDisabledControlJustReleased(0, Keys["3"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 3)
                end
            end)
        end

        if IsDisabledControlJustReleased(0, Keys["4"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 4)
                end
            end)
        end

        if IsDisabledControlJustReleased(0, Keys["5"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 5)
                end
            end)
        end

       --[[ if IsDisabledControlJustReleased(0, Keys["6"]) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    TriggerServerEvent("inventory:server:UseItemSlot", 41)
                end
            end)
        end]]--
    end
end)

RegisterNetEvent('inventory:client:ItemBox')
AddEventHandler('inventory:client:ItemBox', function(itemData, type)
    SendNUIMessage({
        action = "itemBox",
        item = itemData,
        type = type
    })
end)

RegisterNetEvent('inventory:client:requiredItems')
AddEventHandler('inventory:client:requiredItems', function(items, bool)
    local itemTable = {}
    if bool then
        for k, v in pairs(items) do
            table.insert(itemTable, {
                item = items[k].name,
                label = QBCore.Shared.Items[items[k].name]["label"],
                image = items[k].image,
            })
        end
    end
    
    SendNUIMessage({
        action = "requiredItem",
        items = itemTable,
        toggle = bool
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if DropsNear ~= nil then
            for k, v in pairs(DropsNear) do
                if DropsNear[k] ~= nil then
                    DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 120, 10, 20, 155, false, false, false, 1, false, false, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if Drops ~= nil and next(Drops) ~= nil then
            local pos = GetEntityCoords(GetPlayerPed(-1), true)
            for k, v in pairs(Drops) do
                if Drops[k] ~= nil then 
                    if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.coords.x, v.coords.y, v.coords.z, true) < 7.5 then
                        DropsNear[k] = v
                        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.coords.x, v.coords.y, v.coords.z, true) < 2 then
                            CurrentDrop = k
                        else
                            CurrentDrop = nil
                        end
                    else
                        DropsNear[k] = nil
                    end
                end
            end
        else
            DropsNear = {}
        end
        Citizen.Wait(500)
    end
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    --TriggerServerEvent("inventory:server:LoadDrops")
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent('inventory:server:RobPlayer')
AddEventHandler('inventory:server:RobPlayer', function(TargetId)
    SendNUIMessage({
        action = "RobMoney",
        TargetId = TargetId,
    })
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback('RobMoney', function(data, cb)
    TriggerServerEvent("police:server:RobPlayer", data.TargetId)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback('Notify', function(data, cb)
    QBCore.Functions.Notify(data.message, data.type)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:OpenInventory")
AddEventHandler("inventory:client:OpenInventory", function(PlayerAmmo, inventory, other)
    if not IsEntityDead(GetPlayerPed(-1)) then
        ToggleHotbar(false)
        SetNuiFocus(true, true)
        if other ~= nil then
            currentOtherInventory = other.name
        end
        SendNUIMessage({
            action = "open",
            inventory = inventory,
            slots = MaxInventorySlots,
            other = other,
            maxweight = QBCore.Config.Player.MaxWeight,
            Ammo = PlayerAmmo,
            maxammo = Config.MaximumAmmoValues,
        })
        inInventory = true
    end
end)
RegisterNUICallback("GiveItem", function(data, cb)
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerPed = GetPlayerPed(player)
        local playerId = GetPlayerServerId(player)
        local plyCoords = GetEntityCoords(playerPed)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, plyCoords.x, plyCoords.y, plyCoords.z, true)
        if dist < 2.5 then
            if data.inventory == 'player' then
                SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED',true)
                TriggerServerEvent("inventory:server:GiveItem", playerId, data.inventory, data.item, data.amount)
            end
        else
            QBCore.Functions.Notify("No one nearby!", "error")
        end
    else--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
        fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
        QBCore.Functions.Notify("No one nearby!", "error")
    end
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end
RegisterNetEvent("inventory:client:ShowTrunkPos")
AddEventHandler("inventory:client:ShowTrunkPos", function()
    showTrunkPos = true
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:UpdatePlayerInventory")
AddEventHandler("inventory:client:UpdatePlayerInventory", function(isError)
    SendNUIMessage({
        action = "update",
        inventory = QBCore.Functions.GetPlayerData().items,
        maxweight = QBCore.Config.Player.MaxWeight,
        slots = MaxInventorySlots,
        error = isError,
    })
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:CraftItems")
AddEventHandler("inventory:client:CraftItems", function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(GetPlayerPed(-1), "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftItems", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(GetPlayerPed(-1), "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed!", "error")
        isCrafting = false
	end)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent('inventory:client:CraftAttachment')
AddEventHandler('inventory:client:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(GetPlayerPed(-1), "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftAttachment", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(GetPlayerPed(-1), "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed!", "error")
        isCrafting = false
	end)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:PickupSnowballs")
AddEventHandler("inventory:client:PickupSnowballs", function()
    LoadAnimDict('anim@mp_snowball')
    TaskPlayAnim(GetPlayerPed(-1), 'anim@mp_snowball', 'pickup_snowball', 3.0, 3.0, -1, 0, 1, 0, 0, 0)
    QBCore.Functions.Progressbar("pickupsnowball", "Sneeuwballen oprapen..", 1500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(GetPlayerPed(-1))
        TriggerServerEvent('QBCore:Server:AddItem', "snowball", 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["snowball"], "add")
    end, function() -- Cancel
        ClearPedTasks(GetPlayerPed(-1))
        QBCore.Functions.Notify("Canceled..", "error")
    end)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:UseSnowball")
AddEventHandler("inventory:client:UseSnowball", function(amount)
    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("weapon_snowball"), amount, false, false)
    SetPedAmmo(GetPlayerPed(-1), GetHashKey("weapon_snowball"), amount)
    SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("weapon_snowball"), true)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:UseWeapon")
AddEventHandler("inventory:client:UseWeapon", function(weaponData, shootbool)
    local weaponName = tostring(weaponData.name)
    if currentWeapon == weaponName then
        SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
        RemoveAllPedWeapons(GetPlayerPed(-1), true)
        TriggerEvent('weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif weaponName == "weapon_stickybomb" then
        GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weaponName), ammo, false, false)
        SetPedAmmo(GetPlayerPed(-1), GetHashKey(weaponName), 1)
        SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey(weaponName), true)
        TriggerServerEvent('QBCore:Server:RemoveItem', weaponName, 1)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    elseif weaponName == "weapon_snowball" then
        GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weaponName), ammo, false, false)
        SetPedAmmo(GetPlayerPed(-1), GetHashKey(weaponName), 10)
        SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey(weaponName), true)
        TriggerServerEvent('QBCore:Server:RemoveItem', weaponName, 1)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    else
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        QBCore.Functions.TriggerCallback("weapon:server:GetWeaponAmmo", function(result)
            local ammo = tonumber(result)
            if weaponName == "weapon_petrolcan" or weaponName == "weapon_fireextinguisher" then 
                ammo = 4000 
            end
            GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weaponName), ammo, false, false)
            SetPedAmmo(GetPlayerPed(-1), GetHashKey(weaponName), ammo)
            SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey(weaponName), true)
            if weaponData.info.attachments ~= nil then
                for _, attachment in pairs(weaponData.info.attachments) do
                    GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(weaponName), GetHashKey(attachment.component))
                end
            end
            currentWeapon = weaponName
        end, CurrentWeaponData)
    end
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
WeaponAttachments = {
    ["WEAPON_SNSPISTOL"] = {
        ["extendedclip"] = {
            component = "COMPONENT_SNSPISTOL_CLIP_02",
            label = "Extended Clip",
            item = "pistol_extendedclip",
        },
    },
    ["WEAPON_VINTAGEPISTOL"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_PI_SUPP",
            label = "Suppressor",
            item = "pistol_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_VINTAGEPISTOL_CLIP_02",
            label = "Extended Clip",
            item = "pistol_extendedclip",
        },
    },
    ["WEAPON_MICROSMG"] = {
        ["suppressor"] = {
            component = "COMPONENT_AT_AR_SUPP_02",
            label = "Suppressor",
            item = "smg_suppressor",
        },
        ["extendedclip"] = {
            component = "COMPONENT_MICROSMG_CLIP_02",
            label = "Extended Clip",
            item = "smg_extendedclip",
        },
        ["flashlight"] = {
            component = "COMPONENT_AT_PI_FLSH",
            label = "Flashlight",
            item = "smg_flashlight",
        },
        ["scope"] = {
            component = "COMPONENT_AT_SCOPE_MACRO",
            label = "Scope",
            item = "smg_scope",
        },
    },
    ["WEAPON_MINISMG"] = {
        ["extendedclip"] = {
            component = "COMPONENT_MINISMG_CLIP_02",
            label = "Extended Clip",
            item = "smg_extendedclip",
        },
    },
    ["WEAPON_COMPACTRIFLE"] = {
        ["extendedclip"] = {
            component = "COMPONENT_COMPACTRIFLE_CLIP_02",
            label = "Extended Clip",
            item = "rifle_extendedclip",
        },
        ["drummag"] = {
            component = "COMPONENT_COMPACTRIFLE_CLIP_03",
            label = "Drum Mag",
            item = "rifle_drummag",
        },
    },
}
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function FormatWeaponAttachments(itemdata)
    local attachments = {}
    itemdata.name = itemdata.name:upper()
    if itemdata.info.attachments ~= nil and next(itemdata.info.attachments) ~= nil then
        for k, v in pairs(itemdata.info.attachments) do
            if WeaponAttachments[itemdata.name] ~= nil then
                for key, value in pairs(WeaponAttachments[itemdata.name]) do
                    if value.component == v.component then
                        table.insert(attachments, {
                            attachment = key,
                            label = value.label
                        })
                    end
                end
            end
        end
    end
    return attachments
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback('GetWeaponData', function(data, cb)
    local data = {
        WeaponData = QBCore.Shared.Items[data.weapon],
        AttachmentData = FormatWeaponAttachments(data.ItemData)
    }
    cb(data)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback('RemoveAttachment', function(data, cb)
    local WeaponData = QBCore.Shared.Items[data.WeaponData.name]
    local Attachment = WeaponAttachments[WeaponData.name:upper()][data.AttachmentData.attachment]
    
    QBCore.Functions.TriggerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
        if NewAttachments ~= false then
            local Attachies = {}
            RemoveWeaponComponentFromPed(GetPlayerPed(-1), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            for k, v in pairs(NewAttachments) do
                for wep, pew in pairs(WeaponAttachments[WeaponData.name:upper()]) do
                    if v.component == pew.component then
                        table.insert(Attachies, {
                            attachment = pew.item,
                            label = pew.label,
                        })
                    end
                end
            end
            local DJATA = {
                Attachments = Attachies,
                WeaponData = WeaponData,
            }
            cb(DJATA)
        else
            RemoveWeaponComponentFromPed(GetPlayerPed(-1), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            cb({})
        end
    end, data.AttachmentData, data.WeaponData)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:CheckWeapon")
AddEventHandler("inventory:client:CheckWeapon", function(weaponName)
    if currentWeapon == weaponName then 
        TriggerEvent('weapons:ResetHolster')
        SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
        RemoveAllPedWeapons(GetPlayerPed(-1), true)
        currentWeapon = nil
    end
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:AddDropItem")
AddEventHandler("inventory:client:AddDropItem", function(dropId, player)
    local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
    local forward = GetEntityForwardVector(GetPlayerPed(GetPlayerFromServerId(player)))
	local x, y, z = table.unpack(coords + forward * 0.5)
    Drops[dropId] = {
        id = dropId,
        coords = {
            x = x,
            y = y,
            z = z - 0.3,
        },
    }
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNetEvent("inventory:client:RemoveDropItem")
AddEventHandler("inventory:client:RemoveDropItem", function(dropId)
    Drops[dropId] = nil
end)

RegisterNetEvent("inventory:client:DropItemAnim")
AddEventHandler("inventory:client:DropItemAnim", function()
    SendNUIMessage({
        action = "close",
    })
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Citizen.Wait(7)
    end
    TaskPlayAnim(GetPlayerPed(-1), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Citizen.Wait(2000)
    ClearPedTasks(GetPlayerPed(-1))
end)

--[[RegisterNetEvent("inventory:client:ShowId")
AddEventHandler("inventory:client:ShowId", function(sourceId, citizenid, character)
    local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(sourceId)), false)
    local pos = GetEntityCoords(GetPlayerPed(-1), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 2.0) then
        local gender = "Man"
        if character.gender == 1 then
            gender = "Vrouw"
        end
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>CSN:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>Birth Date:</strong> {4} <br><strong>Sex:</strong> {5} <br><strong>Nationality:</strong> {6}<br><strong>Job: </strong>{7}</div></div>',
            args = {'ID-Card', character.citizenid, character.firstname, character.lastname, character.birthdate, gender, character.nationality,character.job}
        })
    end
end)

RegisterNetEvent("inventory:client:ShowDriverLicense")
AddEventHandler("inventory:client:ShowDriverLicense", function(sourceId, citizenid, character)
    local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(sourceId)), false)
    local pos = GetEntityCoords(GetPlayerPed(-1), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 2.0) then
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
            args = {'Drivers license', character.firstname, character.lastname, character.birthdate, character.type}
        })
    end
end)]]

RegisterNetEvent("inventory:client:SetCurrentStash")
AddEventHandler("inventory:client:SetCurrentStash", function(stash)
    CurrentStash = stash
end)

RegisterNUICallback('getCombineItem', function(data, cb)
    cb(QBCore.Shared.Items[data.item])
end)

RegisterNUICallback("CloseInventory", function(data, cb)
    if currentOtherInventory == "none-inv" then
        CurrentDrop = 0
        CurrentVehicle = nil
        CurrentGlovebox = nil
        CurrentStash = nil
        SetNuiFocus(false, false)
        inInventory = false
        ClearPedTasks(GetPlayerPed(-1))
        return
    end
    if CurrentVehicle ~= nil then
        CloseTrunk()
        TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
        CurrentVehicle = nil
    elseif CurrentGlovebox ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
        CurrentGlovebox = nil
    elseif CurrentStash ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
        CurrentStash = nil
    else
        TriggerServerEvent("inventory:server:SaveInventory", "drop", CurrentDrop)
        CurrentDrop = 0
    end
    SetNuiFocus(false, false)
    inInventory = false
    TriggerEvent('randPickupAnim')
end)
RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("inventory:server:UseItem", data.inventory, data.item)
end)

RegisterNUICallback("combineItem", function(data)
    Citizen.Wait(150)
    TriggerServerEvent('inventory:server:combineItem', data.reward, data.fromItem, data.toItem)
    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[data.reward], 'add')
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback('combineWithAnim', function(data)
    local combineData = data.combineData
    local aDict = combineData.anim.dict
    local aLib = combineData.anim.lib
    local animText = combineData.anim.text
    local animTimeout = combineData.anim.timeOut

    QBCore.Functions.Progressbar("combine_anim", animText, animTimeout, false, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = aDict,
        anim = aLib,
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(GetPlayerPed(-1), aDict, aLib, 1.0)
    end, function() -- Cancel
        StopAnimTask(GetPlayerPed(-1), aDict, aLib, 1.0)
        QBCore.Functions.Notify("Mislukt!", "error")
    end)
    TriggerServerEvent('inventory:server:combineItem', combineData.reward, data.requiredItem, data.usedItem)
    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[combineData.reward], 'add')
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback("SetInventoryData", function(data, cb)
    TriggerServerEvent("inventory:server:SetInventoryData", data.fromInventory, data.toInventory, data.fromSlot, data.toSlot, data.fromAmount, data.toAmount)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
RegisterNUICallback("PlayDropSound", function(data, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback("PlayDropFail", function(data, cb)
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
end)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function OpenTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(GetPlayerPed(-1), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function CloseTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(GetPlayerPed(-1), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorShut(vehicle, 5, false)
    end
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function IsBackEngine(vehModel)
    for _, model in pairs(BackEngineVehicles) do
        if GetHashKey(model) == vehModel then
            return true
        end
    end
    return false
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function ToggleHotbar(toggle)
    local HotbarItems = {
        [1] = QBCore.Functions.GetPlayerData().items[1],
        [2] = QBCore.Functions.GetPlayerData().items[2],
        [3] = QBCore.Functions.GetPlayerData().items[3],
        [4] = QBCore.Functions.GetPlayerData().items[4],
        [5] = QBCore.Functions.GetPlayerData().items[5],
        [41] = QBCore.Functions.GetPlayerData().items[41],
    } 

    if toggle then
        SendNUIMessage({
            action = "toggleHotbar",
            open = true,
            items = HotbarItems
        })
    else
        SendNUIMessage({
            action = "toggleHotbar",
            open = false,
        })
    end
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function LoadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
function closeInventory()
    isInInventory = false
    ClearPedSecondaryTask(PlayerPedId())
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close",
    })
    TriggerScreenblurFadeOut(0)
    ClearPedTasks(PlayerPedId())
end
RegisterCommand('closeinv', function()
    closeInventory()
end, false)
--[[MADE BY Ax is bro ther made by axis brother dream life roleplay ax is brother Axis#1672
fuck Indian Empire RolePlay Fuk You All Halka gorib you too!]]
