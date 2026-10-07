local ESX
-- ESX Legacy (export), avec repli sur l'ancien event pour les vieilles versions
pcall(function() ESX = exports['es_extended']:getSharedObject() end)
if not ESX then
    TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
end

-- Seuls ces comptes peuvent être utilisés pour payer
local allowedAccounts = { money = true, bank = true }

-- Table de recherche nom d'item -> article de la config
local shopItems = {}
for _, v in ipairs(Config.Shop) do
    shopItems[v.item] = v
end

local function notify(src, msg)
    TriggerClientEvent("esx:showAdvancedNotification", src, "Information", "Supérette", msg)
end

-- Sans OneSync, le serveur ne connaît pas la position des joueurs : on saute ce contrôle
local oneSyncEnabled = GetConvar('onesync', 'off') ~= 'off'

local function isNearShop(src)
    if not oneSyncEnabled then return true end
    local coords = GetEntityCoords(GetPlayerPed(src))
    for _, v in ipairs(Config.PositionVendeur) do
        if #(coords - v.pos) <= Config.MaxBuyDistance then
            return true
        end
    end
    return false
end

RegisterNetEvent("iShop:buy", function(itemName, nbr, pay)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local article = shopItems[itemName]
    nbr = tonumber(nbr)
    if not article or not nbr or nbr ~= math.floor(nbr) or nbr < 1 or nbr > Config.MaxQuantity or not allowedAccounts[pay] then
        print(("[iShop] Achat invalide refusé (joueur %s) : item=%s nbr=%s pay=%s"):format(src, tostring(itemName), tostring(nbr), tostring(pay)))
        return
    end

    if not isNearShop(src) then
        print(("[iShop] Achat refusé : joueur %s trop loin d'un magasin"):format(src))
        return
    end

    -- Le prix est toujours calculé côté serveur, jamais fourni par le client
    local price = article.price * nbr
    local account = xPlayer.getAccount(pay)

    if not account or account.money < price then
        notify(src, "Vous n'avez pas assez d'~g~argent~s~ !")
        return
    end

    if not xPlayer.canCarryItem(article.item, nbr) then
        notify(src, "Vous n'avez plus de ~r~place~s~")
        return
    end

    xPlayer.removeAccountMoney(pay, price)
    xPlayer.addInventoryItem(article.item, nbr)
    notify(src, ("Vous avez acheté %dx %s pour ~g~%d$~s~"):format(nbr, article.label, price))
end)
