local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
MySQL = module("vrp_mysql", "MySQL")

vRP = Proxy.getInterface("vRP")
vRPbpC = Tunnel.getInterface("vRP_battlepass","vRP_battlepass")
vRPclient = Tunnel.getInterface("vRP","vRP_battlepass")
vRPnc = Proxy.getInterface("vRP_newcoin")

vRPbpS = {}
Tunnel.bindInterface("vRP_battlepass",vRPbpS)
Proxy.addInterface("vRP_battlepass",vRPbpS)

MySQL.createCommand("vRP/bp_columns","ALTER TABLE vrp_users ADD IF NOT EXISTS tier integer NOT NULL DEFAULT '0'")
MySQL.execute("vRP/bp_columns")

MySQL.createCommand("vRP/bp_tier_up", "UPDATE vrp_users SET tier = tier + 1 WHERE id = @user_id")
MySQL.createCommand("vRP/bp_get_tier", "SELECT tier FROM vrp_users WHERE id = @user_id")

local actTier = 0
local tiers = {}

local tiere = {
    [0] = {prize = 350, cost = 500, type = "money"},
    [1] = {prize = 20, cost = 1000, type = "gold"},
    [2] = {prize = 860, cost = 1500, type = "money"},
    [3] = {prize = 3700, cost = 3500, type = "money"},
    [4] = {prize = 3000, cost = 5500, type = "money"},
    [5] = {prize = 150, cost = 6500, type = "gold"},
    [6] = {prize = 10000, cost = 7500, type = "money"},
    [7] = {prize = 15000, cost = 8500, type = "money"},
    [8] = {prize = 8000, cost = 12000, type = "money"},
    [9] = {prize = 10000, cost = 13000, type = "money"},
    [10] = {prize = 30000, cost = 100000, type = "money"},
    [11] = {prize = 200000, cost = 100000, type = "money"},
    [12] = {prize = 140000, cost = 100000, type = "money"},
    [13] = {prize = 2000, cost = 100000, type = "gold"},
    [14] = {prize = 45000, cost = 100000, type = "money"},
    [15] = {prize = 34000, cost = 100000, type = "money"},
    [16] = {prize = 180000, cost = 100000, type = "money"},
    [17] = {prize = 4500, cost = 100000, type = "gold"},
    [18] = {prize = 232000, cost = 100000, type = "money"},
    [19] = {prize = 5500, cost = 100000, type = "money"},
    [20] = {prize = 5500, cost = 100000, type = "money"},
    [21] = {prize = 15, cost = 100000, type = "gold"},
    [22] = {prize = 20000, cost = 100000, type = "money"},
    [23] = {prize = 35000, cost = 100000, type = "money"},
    [24] = {prize = 50000, cost = 110000, type = "money"},
    [25] = {prize = 300000, cost = 120000, type = "money"},
    [26] = {prize = 51000, cost = 130000, type = "money"},
    [27] = {prize = 59000, cost = 140000, type = "money"},
    [28] = {prize = 1200, cost = 150000, type = "gold"},
    [29] = {prize = 65000, cost = 160000, type = "car"},
    [30] = {prize = 320000, cost = 170000, type = "money"},
    [31] = {prize = 230000, cost = 180000, type = "money"},
    [32] = {prize = 100000, cost = 200000, type = "money"},
    [33] = {prize = 160000, cost = 230000, type = "money"},
    [34] = {prize = 360000, cost = 240000, type = "money"},
    [35] = {prize = 260000, cost = 250000, type = "money"}, -- facut vip pe zile, vip ptr 3 zile
    [36] = {prize = 150000, cost = 260000, type = "money"},
    [37] = {prize = 130000, cost = 270000, type = "money"},
    [38] = {prize = 8000, cost = 280000, type = "gold"},
    [39] = {prize = 500000, cost = 300000, type = "money"},
    [40] = {prize = 3600, cost = 5000000, type = "car"},
}

AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
	MySQL.query("vRP/bp_get_tier", {user_id = user_id}, function(rows, affected)
        if tiers[user_id] == nil and actTier == 1 then
            actTier = tonumber(rows[1].tier)
            if actTier > #tiere then
                actTier = #tiere
            end
            local player = vRP.getUserSource({user_id})
            if user_id ~= nil then
                vRPbpC.loadTiers(player, {tiere, actTier})
            end
        end
    end)
end)

function vRPbpS.getPlayerTier(user_id)
    if user_id ~= nil then
        MySQL.query("vRP/bp_get_tier", {user_id = user_id}, function(rows,affected)
            actTier = tonumber(rows[1].tier)
            if actTier > #tiere then
                actTier = #tiere
            end
        end)
    end
    return actTier or 0
end

function vRPbpS.openBpMenu()
    local user_id = vRP.getUserId({source})
    local pTier = vRPbpS.getPlayerTier(user_id)
    local player = vRP.getUserSource({user_id})
    if user_id ~= nil then
        vRPbpC.loadTiers(player, {tiere, pTier})
    end
end

function vRPbpS.buyTier()
    local user_id = vRP.getUserId({source})
    local player = vRP.getUserSource({user_id})
    if user_id ~= nil then
        local pTier = tonumber(vRPbpS.getPlayerTier(user_id))
        pTier = pTier+1
        if (pTier <= #tiere) then
            if vRP.tryPayment({user_id, tiere[pTier].cost}) then
                vRPbpS.tierUp(user_id)
                if tiere[pTier].type == "money" then
                    vRP.giveMoney({user_id, tiere[pTier].prize})
                    vRPclient.notify(player, {"Ai primit ~g~$"..tiere[pTier].prize,"success"})
                elseif tiere[pTier].type == "gold" then
                    vRPnc.giveCoins({user_id, tiere[pTier].prize})                    
                    vRPclient.notify(player, {"Ai primit ~g~"..tiere[pTier].prize.." ~y~gold ca recompensa!","success"})
                elseif tiere[pTier].type == "car" and pTier == 29 then
                    MySQL.query("vRP/add_custom_vehicle", {user_id = user_id, vehicle= "elegy", vehicle_plate="WINNED", veh_type = "car"})
                    vRPclient.notify(player, {"Ai primit o masina cadou! ~g~Model: Elegy","success"})
                elseif tiere[pTier].type == "car" and pTier == 40 then 
                    MySQL.query("vRP/add_custom_vehicle", {user_id = user_id, vehicle= "cobra", vehicle_plate="WINNED", veh_type = "car"})
                    vRPclient.notify(player, {"Ai primit o masina cadou! ~g~Model: Ford Cobra","success"})
                end
            end
        elseif pTier == #tiere then
            vRPclient.notify(player, {"Ai atins maximul!","success"})
            pTier = #tiere
        end
    end
end

function vRPbpS.tierUp(user_id)
    if user_id ~= nil then
        local player = vRP.getUserSource({user_id})
        local tier = vRPbpS.getPlayerTier(user_id)
        tier = tier + 1
        if tier <= #tiere then
            actTier = tier
            MySQL.execute("vRP/bp_tier_up",{user_id = user_id})
        end
        if actTier == tier and tier == #tiere and actTier == #tiere then
            vRPclient.notify(player, {"Ai atins maximul! Felicitari","success"})
        end
    end
end