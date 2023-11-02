ESX = exports.es_extended.getSharedObject()

Client = {}
local PlayerDuty = false
local PojazdWyciagniety = false
local drawZones = Config.Target.Debug
local veh = nil

-- Funkcje

Client.GetCar = function()
    local carData = Config.SpawnCar[1]
    local model = carData.Name
    local x = carData.x
    local y = carData.y
    local z = carData.z
    local heading = carData.h

    ESX.Game.SpawnVehicle(model, vector3(x, y, z), heading, function(vehicle)
        local plateText = string.upper('SAD') .. tostring(math.random(1000, 9999))
        SetVehicleNumberPlateText(vehicle, plateText)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

        ESX.ShowNotification("Pobrałeś pojazd z rejestracją " .. plateText .. "!")
        PojazdWyciagniety = true
        veh = vehicle
    end)
end

Client.DeleteCar = function()
    if PojazdWyciagniety then
        local vehicle2 = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))

        if vehicle2 then
            if vehicle2 == veh then
                TriggerServerEvent('wiadros_sadownik:server:payOutBail')
                PojazdWyciagniety = false
                DeleteVehicle(veh)
                veh = nil
            else
                ESX.ShowNotification("Nie ma tu twojego pojazdu!")
            end
        else
            ESX.ShowNotification("Nie ma tu twojego pojazdu!")
        end
    end
end

Client.GetPedHash = function(name)
    local hash = GetHashKey(name)
    return hash
end

Client.GetDuty = function()
    if PlayerDuty then
        PlayerDuty = false
    else
        PlayerDuty = true
    end

    print(PlayerDuty)
end

Client.ProgressBar = function(text, time)
    local task = lib.progressBar({
        duration = time,
        label = text,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    })

    return task
end

Client.SpawnPeds = function()
    for _, pedData in pairs(Config.Peds) do
        local pedHash = GetHashKey(pedData.Name)
        local isModelValid = IsModelInCdimage(pedHash)

        if isModelValid and not HasModelLoaded(pedHash) then
            RequestModel(pedHash)
            while not HasModelLoaded(pedHash) do
                Wait(0)
            end
        end

        local ped = CreatePed(4, pedHash, pedData.x, pedData.y, pedData.z, pedData.h, false, false)
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
    end
end

-- Target

CreateThread(function()
	for k,conf in pairs(Config.ZbieraniePomidorZone) do
		exports.ox_target:addSphereZone({
			coords = conf.coords,
			radius = 1,
			debug = drawZones,
			options = {
				{
                    name = 'zbieraniepomidoro',
                    icon = 'fa-solid fa-circle',
                    label = 'Zbierz pomidory',
                    onSelect = function()
                        Client.ProgressBar("Zrywasz pomidory", 10000)
                        TriggerServerEvent('wiadros_sadownik:server:getItem', Config.ZbieraniePomidor.Item, math.random(Config.ZbieraniePomidor.MinAmout, Config.ZbieraniePomidor.MaxAmout))
                    end,
                    canInteract = function()
                        return PlayerDuty
                    end
				}
			}
		})
	end

    for k,conf in pairs(Config.ZbieranieOrangeZone) do
		exports.ox_target:addSphereZone({
			coords = conf.coords,
			radius = 1,
			debug = drawZones,
			options = {
				{
                    name = 'zbieraniepomaranczy',
                    icon = 'fa-solid fa-circle',
                    label = 'Zbierz pomarańcze',
                    onSelect = function()
                        Client.ProgressBar("Zrywasz pomarańcze", 10000)
                        TriggerServerEvent('wiadros_sadownik:server:getItem', Config.ZbieranieOrange.Item, math.random(Config.ZbieranieOrange.MinAmout, Config.ZbieranieOrange.MaxAmout))
                    end,
                    canInteract = function()
                        return PlayerDuty
                    end
				}
			}
		})
	end

    exports.qtarget:AddTargetModel({Client.GetPedHash(Config.Peds[1].Name)}, {
        options = {
            {
                icon = "fas fa-circle",
                label = "Wejdź/Wyjdź z służby",
                num = 1,
                action = function()
                    Client.GetDuty()
                end
            },
            {
                icon = "fas fa-circle",
                label = "Weź pojazd",
                num = 2,
                action = function()
                    if not ESX.Game.IsSpawnPointClear(vector3(408.2276, 6492.4038, 28.1233), 2) then
                        ESX.ShowNotification("Miejsce dostarczenia pojazdu jest zajęte!")
                        return
                    end
                    TriggerServerEvent('wiadros_sadownik:server:getMoney')
                end,
                canInteract = function()
                    return PlayerDuty and not PojazdWyciagniety
                end
            },
            {
                icon = "fas fa-circle",
                label = "Zwróć pojazd",
                num = 3,
                action = function()
                    Client.DeleteCar()
                end,
                canInteract = function()
                    return PojazdWyciagniety
                end
            },
        },
        distance = 2
    })

    exports.qtarget:AddTargetModel({Client.GetPedHash(Config.Peds[2].Name)}, {
        options = {
            {
                icon = "fas fa-circle",
                label = "Sprzedaj",
                num = 2,
                action = function()
                    TriggerServerEvent('wiadros_sadownik:server:sellItems')
                end
            },
        },
        distance = 2
    })
end)

Client.Blips = function()
    local blipZbieranie = AddBlipForCoord(Config.ZbieranieOrange.BlipCoord.x, Config.ZbieranieOrange.BlipCoord.y, Config.ZbieranieOrange.BlipCoord.z)

    SetBlipSprite(blipZbieranie, 616)
    SetBlipColour(blipZbieranie, 17)
    SetBlipScale(blipZbieranie, 0.8)
    SetBlipAsShortRange(blipZbieranie, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Zbieranie pomarańczy")
    EndTextCommandSetBlipName(blipZbieranie)

    local blipZbieranie2 = AddBlipForCoord(Config.ZbieraniePomidor.BlipCoord.x, Config.ZbieraniePomidor.BlipCoord.y, Config.ZbieraniePomidor.BlipCoord.z)
    SetBlipSprite(blipZbieranie2, 570)
    SetBlipColour(blipZbieranie2, 1)
    SetBlipScale(blipZbieranie2, 0.8)
    SetBlipAsShortRange(blipZbieranie2, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Zbieranie pomidorów")
    EndTextCommandSetBlipName(blipZbieranie2)

    local blipZbieranie3 = AddBlipForCoord(Config.SprzedawanieItemy.BlipCoord.x, Config.SprzedawanieItemy.BlipCoord.y, Config.SprzedawanieItemy.BlipCoord.z)
    SetBlipSprite(blipZbieranie3, 431)
    SetBlipColour(blipZbieranie3, 5)
    SetBlipScale(blipZbieranie3, 0.8)
    SetBlipAsShortRange(blipZbieranie3, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Sprzedawanie")
    EndTextCommandSetBlipName(blipZbieranie3)
end

RegisterNetEvent('wiadros_sadownik:client:autko', Client.GetCar)
CreateThread(Client.SpawnPeds)
CreateThread(Client.Blips)