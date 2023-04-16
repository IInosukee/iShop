ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    ESX.PlayerData = ESX.GetPlayerData()
end)

function ReloadPlayerData()
    ESX.PlayerData = ESX.GetPlayerData()
end

Citizen.CreateThread(function(source, args, rawCommand)
    for k,v in pairs(Config.PositionVendeur) do
        createNPC(GetHashKey(Config.NPC), v.pos, v.heading)
        createBlip(v.pos)
    end
end)

function createNPC(pedHash, pos, pedHeading) 
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end
    local npc = CreatePed(0, pedHash, pos, pedHeading, false, false)
    SetEntityInvincible(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc,true)
    FreezeEntityPosition(npc, true)
end

function createBlip(pos)
    local blip = AddBlipForCoord(pos)
    SetBlipSprite(blip, 52)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Magasin")
    EndTextCommandSetBlipName(blip)
end

local iShop = false
local iShopIndex = 1
iShopCountIndex = 1
local iPay = "money"
local count = 0

RMenu.Add('iShop_menu', 'main', RageUI.CreateMenu('Supérette', 'Que voulez-vous faire ?'))
RMenu:Get('iShop_menu', 'main').Closed = function()
    iShop = false
end

function OpenMenuShop()
    if iShop then
        iShop = false
    else
        iShop = true 
        RageUI.Visible(RMenu:Get('iShop_menu', 'main'), true)

        Citizen.CreateThread(function()
            while iShop do
                Wait(0)
                RageUI.IsVisible(RMenu:Get('iShop_menu', 'main'), true, true, true, function(h, a, s)
                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == "money" then
                            RageUI.Separator("Argent : ~g~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$~s~")
                        end
                    end
                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == "bank" then
                            RageUI.Separator("Argent en Banque : ~b~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$~s~")
                        end
                    end
                    RageUI.List("Méthode de payement", {'~g~Liquide~s~', '~b~Banque~s~'}, iShopIndex, nil, {}, true, function(h, a, s, ind)
                        iShopIndex = ind
                        if a then
                            if iShopIndex == 1 then
                                iPay = "money"
                            elseif iShopIndex == 2 then
                                iPay = "bank"
                            end
                        end
                    end)
                    for k,v in pairs (Config.Shop) do
                        RageUI.List(v.label.." ~g~["..v.price.."$]~s~ ", Config.ItemCount, iShopCountIndex, nil, {}, true, function(h, a, s, ind)
                            iShopCountIndex = ind
                            local prix = v.price*iShopCountIndex
                            if s then 
                                TriggerServerEvent("iShop:buy"..v.item, iShopCountIndex, iPay, prix)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do 
        local interval = 200
        local playerpos = GetEntityCoords(PlayerPedId())
        for k,v in pairs(Config.PositionVendeur) do
            if #(playerpos-v.pos) < 2 then
                interval = 0
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour intéragir avec le ~g~vendeur~s~')
                if IsControlJustPressed(1,51) then
                    ReloadPlayerData()
                    if iShop == false then
                        iShopCountIndex = 1
                        OpenMenuShop()
                    end
                end
            end
        end
        Citizen.Wait(interval)
    end
end)