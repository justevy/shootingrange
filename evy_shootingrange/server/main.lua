--=====================================================================--
--========================     SERVER EVENT     =======================--
--=====================================================================--

RegisterNetEvent("evy_shootingrange:reserve_sv")
AddEventHandler("evy_shootingrange:reserve_sv", function()
        TriggerClientEvent("evy_shootingrange:reserve_cl", -1)
end)

RegisterNetEvent("evy_shootingrange:unreserve_sv")
AddEventHandler("evy_shootingrange:unreserve_sv", function()
        TriggerClientEvent("evy_shootingrange:unreserve_cl", -1)
end)

--=====================================================================--