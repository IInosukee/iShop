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

--[[local iShop = false

RMenu.Add('iShop_menu', 'main', RageUI.CreateMenu('Supérette', 'Que voulez-vous faire ?'))
RMenu:Get('iShop_menu', 'main').Closed = function()
    iShop = false
end

function OpenMenuShop()
    if iShop then
        iShop = false
    else
        iShop = true
        RageUI.Visible('iShop_menu', RMenu:Get('iShop_menu', 'main'), true)

        Citizen.CreateThread(function()
            while iShop do
                Wait(0)
                RageUI.IsVisible(RMenu:Get('iShop_menu', 'menu'), true, true, true, function()
                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name=='money' then
                            RageUI.Separator("Argent en ~g~liquide~s~ : "..ESX.MathGroupDigits(ESX.PlayerData.accounts[i].money).."$")
                        end
                        if ESX.PlayerData.accounts[i].name=='bank' then
                            RageUI.Separator("Argent en ~b~banque~s~ : "..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$")
                        end
                    end
                    RageUI.List("Payement", {"Liquide", "Banque"}, iShopIndex, nil, {}, true, function(h, a, s, ind)
                        local iShopIndex = ind
                        if iShopIndex == 1 then
                            TriggerServerEvent('liquidepay')
                        elseif iShopIndex == 2 then
                            TriggerServerEvent('bankpay')
                        end
                    end)
                end)
            end
        end)
    end
end]]


Citizen.CreateThread(function()
    local pos = Config.PositionBlanchisseur.pos
    while true do
        local interval = 200
        local playerpos = GetEntityCoords(PlayerPedId())
        
            if #(playerpos-Config.PositionBlanchisseur.pos) < 2 then
                interval = 0
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour parler à ~r~'..Config.Name)
                if IsControlJustPressed(1, 51) then
                    if Config.Dialog then
                        TexteBas('~b~[Vous]~s~ Salut, c\'est toi pour le blanchiment ?', 2500)
                        Citizen.Wait(2500)
                        TexteBas('~r~['..Config.Name..']~s~ Ouais c\'est moi tu veux blanchir combien ?', 2500)
                        Citizen.Wait(2500)
                    end
                    ReloadPlayerData()
                    if iBlanchisseur == false then
                        OpenMenuBlanchisseur()
                    end
                end
            end
        Citizen.Wait(interval)
    end
end)