local QBCore = exports['qb-core']:GetCoreObject()

local Active = false
local test = nil
local test1 = nil
local spam = true
local playerPed = PlayerPedId()
local inVehicle = IsPedInAnyVehicle(playerPed, false) 
 


RegisterCommand("EMS", function(source, args, raw)
    local playerData = QBCore.Functions.GetPlayerData()
    local isDead = playerData.metadata["isdead"]
    local inLastStand = playerData.metadata["inlaststand"]
    local spam = true -- You need to define 'spam' appropriately
    local inVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
    
    if (isDead or inLastStand) and spam then
        QBCore.Functions.TriggerCallback('hhfw:docOnline', function(EMSOnline, hasEnoughMoney)
            if EMSOnline <= Config.Doctor and hasEnoughMoney then
                if inVehicle then
                    SpawnVehicle(GetEntityCoords(PlayerPedId()))
                    TriggerServerEvent('hhfw:charge')
                    Notify("Medic is arriving")
                else
					SpawnVehicle(GetEntityCoords(PlayerPedId()))
                    TriggerServerEvent('hhfw:charge')
                    Notify("Medic is arriving")
                end
            else
                if EMSOnline > Config.Doctor then
                    Notify("There are too many medics online", "error")
                elseif not hasEnoughMoney then
                    Notify("Not Enough Money", "error")
                end
            end
        end)
    else
        Notify("This can only be used when dead", "error")
    end
end)




function SpawnVehicle(x, y, z)  
	spam = false
	local vehhash = GetHashKey("ambulance")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	RequestModel('s_m_m_doctor_01')
	while not HasModelLoaded('s_m_m_doctor_01') do
		Wait(1)
	end
	local spawnRadius = 40                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)

	if not DoesEntityExist(vehhash) then
        mechVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(mechVeh)
		SetVehicleNumberPlateText(mechVeh, "HHFW")
		SetEntityAsMissionEntity(mechVeh, true, true)
		SetVehicleEngineOn(mechVeh, true, true, false)
        
        mechPed = CreatePedInsideVehicle(mechVeh, 26, GetHashKey('s_m_m_doctor_01'), -1, true, false)              	
        
        mechBlip = AddBlipForEntity(mechVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)


		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(mechPed, mechVeh, loc.x, loc.y, loc.z, 20.0, 0, GetEntityModel(mechVeh), 524863, 2.0)
		test = mechVeh
		test1 = mechPed
		Active = true
    end
end

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200)
        if Active then
            local loc = GetEntityCoords(GetPlayerPed(-1))
			local lc = GetEntityCoords(test)
			local ld = GetEntityCoords(test1)
            local dist = Vdist(loc.x, loc.y, loc.z, lc.x, lc.y, lc.z)
			local dist1 = Vdist(loc.x, loc.y, loc.z, ld.x, ld.y, ld.z)
			local playerPed = PlayerPedId()
			local inVehicle = IsPedInAnyVehicle(playerPed, false) 
			if dist <= 10 and not inVehicle then
				if Active then
					TaskGoToCoordAnyMeans(test1, loc.x, loc.y, loc.z, 1.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 1 then 
					Active = false
					ClearPedTasksImmediately(test1)
					DoctorNPC()
				end
			elseif dist <= 8 and inVehicle then
				Active = false
				DoctorNPC()
			end
        end
    end
end)


function DoctorNPC()
	RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Citizen.Wait(1000)
	end
	if not inVehicle then
		TaskPlayAnim(test1, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
		QBCore.Functions.Progressbar("revive_doc", "The doctor is giving you medical aid", Config.ReviveTime, false, false, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {}, {}, {}, function() -- Done
			ClearPedTasks(test1)
			Citizen.Wait(500)
			TriggerEvent("hospital:client:Revive")
			StopScreenEffect('DeathFailOut')	
			Notify("Your treatment is done, you were charged: "..Config.Price, "success")
			RemovePedElegantly(test1)
			DeleteEntity(test)
			Wait(5000)
			DeleteEntity(test1)
			spam = true
		end)
	elseif inVehicle then
		QBCore.Functions.Progressbar("revive_doc", "The doctor is giving you medical aid", Config.ReviveTime, false, false, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {}, {}, {}, function() -- Done
			ClearPedTasks(test1)
			Citizen.Wait(500)
			TriggerEvent("hospital:client:Revive")
			StopScreenEffect('DeathFailOut')	
			Notify("Your treatment is done, you were charged: "..Config.Price, "success")
			RemovePedElegantly(test1)
			DeleteEntity(test)
			Wait(5000)
			DeleteEntity(test1)
			spam = true
		end)
	end

end


function Notify(msg, state)
    QBCore.Functions.Notify(msg, state)
end
