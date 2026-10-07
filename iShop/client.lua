local ESX

local paymentMethods = {
    { label = '~g~Liquide~s~', account = "money" },
    { label = '~b~Banque~s~', account = "bank" },
}
local paymentLabels = {}
for i, p in ipairs(paymentMethods) do
    paymentLabels[i] = p.label
end

local quantityList = {}
for i = 1, Config.MaxQuantity do
    quantityList[i] = i
end

local menuOpen = false
local paymentIndex = 1
local quantities = {}

local function getAccountMoney(name)
    local accounts = ESX.PlayerData and ESX.PlayerData.accounts or {}
    for _, account in ipairs(accounts) do
        if account.name == name then
            return account.money
        end
    end
    return 0
end

-- Tient le solde à jour (ex : après un achat) sans recharger tout le PlayerData
RegisterNetEvent('esx:setAccountMoney', function(account)
    if not ESX or not ESX.PlayerData or not ESX.PlayerData.accounts then return end
    for i, acc in ipairs(ESX.PlayerData.accounts) do
        if acc.name == account.name then
            ESX.PlayerData.accounts[i] = account
            break
        end
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    if ESX then
        ESX.PlayerData = xPlayer
    end
end)

local function createNPC(pedHash, pos, heading)
    local npc = CreatePed(0, pedHash, pos.x, pos.y, pos.z, heading, false, false)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
end

local function createBlip(pos)
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(blip, 52)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipLabel)
    EndTextCommandSetBlipName(blip)
end

local mainMenu = RageUI.CreateMenu('Supérette', 'Que voulez-vous faire ?')
RMenu.Add('iShop_menu', 'main', mainMenu)
mainMenu.Closed = function()
    menuOpen = false
end

local function openShopMenu()
    if menuOpen then return end
    menuOpen = true

    paymentIndex = 1
    for i = 1, #Config.Shop do
        quantities[i] = 1
    end

    RageUI.Visible(mainMenu, true)

    CreateThread(function()
        while menuOpen do
            Wait(0)
            RageUI.IsVisible(mainMenu, true, true, true, function()
                RageUI.Separator("Argent : ~g~" .. ESX.Math.GroupDigits(getAccountMoney("money")) .. "$~s~")
                RageUI.Separator("Argent en Banque : ~b~" .. ESX.Math.GroupDigits(getAccountMoney("bank")) .. "$~s~")

                RageUI.List("Méthode de paiement", paymentLabels, paymentIndex, nil, {}, true, function(_, _, _, index)
                    paymentIndex = index
                end)

                for i, v in ipairs(Config.Shop) do
                    local total = v.price * quantities[i]
                    RageUI.List(v.label .. " ~g~[" .. total .. "$]~s~ ", quantityList, quantities[i], nil, {}, true, function(_, _, selected, index)
                        quantities[i] = index
                        if selected then
                            TriggerServerEvent("iShop:buy", v.item, quantities[i], paymentMethods[paymentIndex].account)
                        end
                    end)
                end
            end)
        end
    end)
end

CreateThread(function()
    -- Attend qu'ESX soit disponible avant toute utilisation
    pcall(function() ESX = exports['es_extended']:getSharedObject() end)
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(100)
    end
    ESX.PlayerData = ESX.GetPlayerData()

    -- PNJ + blips : le modèle n'est chargé qu'une seule fois
    local pedHash = GetHashKey(Config.NPC)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(10)
    end
    for _, v in ipairs(Config.PositionVendeur) do
        createNPC(pedHash, v.pos, v.heading)
        createBlip(v.pos)
    end
    SetModelAsNoLongerNeeded(pedHash)

    -- Boucle de proximité
    while true do
        local interval = 500
        local playerPos = GetEntityCoords(PlayerPedId())
        for _, v in ipairs(Config.PositionVendeur) do
            local dist = #(playerPos - v.pos)
            if dist < 20.0 then
                interval = 200
            end
            if dist < Config.InteractDistance then
                interval = 0
                if not menuOpen then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour interagir avec le ~g~vendeur~s~')
                    if IsControlJustPressed(0, 51) then
                        ESX.PlayerData = ESX.GetPlayerData()
                        openShopMenu()
                    end
                end
                break
            end
        end
        Wait(interval)
    end
end)
