ESX = exports.es_extended.getSharedObject()

RegisterServerEvent('wiadros_sadownik:server:getMoney')
AddEventHandler('wiadros_sadownik:server:getMoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        if xPlayer.getMoney() >= Config.SpawnCar.Kaucja then
            xPlayer.removeMoney(Config.SpawnCar.Kaucja)
            TriggerClientEvent('esx:showNotification', source, 'Zabrano Ci ' .. (Config.SpawnCar.Kaucja or "Nie znaleziono") .. '$ kaucji.')
            TriggerClientEvent('wiadros_sadownik:client:autko', source)
        else
            TriggerClientEvent('esx:showNotification', source, 'Potrzebujesz mieć ' .. (Config.SpawnCar.Kaucja or "Nie znaleziono") .. '$ aby zapłacić kaucję za pojazd!')
        end
    end
end)

RegisterServerEvent('wiadros_sadownik:server:getItem')
AddEventHandler('wiadros_sadownik:server:getItem', function(item, count)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        if item == "pomidor" then
            xPlayer.addInventoryItem(item, count)
            TriggerClientEvent('esx:showNotification', source, 'Zebrałeś/aś ' .. (count or "Nie znaleziono") .. ' '..(item or "Nie znaleziono"))
        elseif item == "orange" then
            xPlayer.addInventoryItem(item, count)
            TriggerClientEvent('esx:showNotification', source, 'Zebrałeś/aś ' .. (count or "Nie znaleziono") .. ' '..(item or "Nie znaleziono"))
        else
            -- export ban
        end
    end
end)

RegisterServerEvent('wiadros_sadownik:server:payOutBail')
AddEventHandler('wiadros_sadownik:server:payOutBail', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        xPlayer.addMoney(Config.SpawnCar.Kaucja)
        TriggerClientEvent('esx:showNotification', source, 'Oddano ci ' .. (Config.SpawnCar.Kaucja or "Nie znaleziono") .. '$ kaucji.')
    end
end)

RegisterServerEvent('wiadros_sadownik:server:sellItems')
AddEventHandler('wiadros_sadownik:server:sellItems', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local earnings = 0

    for _, item in pairs(Config.SprzedawanieItemy) do
        local itemCount = xPlayer.getInventoryItem(item.name).count
        if itemCount > 0 then
            local itemEarnings = itemCount * item.price
            earnings = earnings + itemEarnings
            xPlayer.removeInventoryItem(item.name, itemCount)
        end
    end

    if earnings > 0 then
        xPlayer.addMoney(earnings)
        TriggerClientEvent('esx:showNotification', source, 'Sprzedałeś swoje produkty i zarobiłeś $' .. earnings)
    else
        TriggerClientEvent('esx:showNotification', source, 'Nie masz żadnych produktów do sprzedania')
    end
end)