ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

for k,v in pairs(Config.Shop) do
    RegisterServerEvent("iShop:buy"..v.item)
    AddEventHandler("iShop:buy"..v.item, function(nbr, pay, price)
        local _src = source
        local xPlayer = ESX.GetPlayerFromId(_src)

        if xPlayer.getAccount(pay).money >= price then
            if xPlayer.canCarryItem(v.item, nbr) then
                xPlayer.removeAccountMoney(pay, price)
                xPlayer.addInventoryItem(v.item, nbr)
                TriggerClientEvent("esx:showAdvacedNotification", _src, "informations", "Supérette", "Vous avez acheté"..nbr.."x "..v.label)
            else
                TriggerClientEvent("esx:showAdvancedNotification", _src, "information", "Supérette", "Vous n'avez plus de ~r~place~s~")
            end
        else
            TriggerClientEvent("esx:showAdvancedNotification", _src, "information", "Supérette", "Vous n'avez pas assez d'~g~argent~s~ !")
        end
    end)
end
