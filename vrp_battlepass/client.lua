vRPbpC = {}
Tunnel.bindInterface("vRP_battlepass",vRPbpC)
Proxy.addInterface("vRP_battlepass",vRPbpC)
vRPbpS = Tunnel.getInterface("vRP_battlepass","vRP_battlepass")
vRP = Proxy.getInterface("vRP")


local fontId

Citizen.CreateThread(function()
	RegisterFontFile('lemonmilk')
	fontId = RegisterFontId('Lemon Milk')
end)

local showBPmenu = false
local startN = 1
local actTier = 0
local tiers = {}

function vRPbpC.loadTiers(tiere, pTier)
    actTier = pTier
    tiers = tiere
    -- print(actTier, tiers[1].prize)
end

function vRPbpC.isBpOpened()
    return showBPmenu or false
end

function vRPbpC.openBp()
    showBPmenu = true
end

function Draw3DText(x,y,z, text,scl) 

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(1)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString("~h~"..text)
        DrawText(_x,_y)
    end
end

function drawtxt(text,font,centre,x,y,scale,r,g,b,a)
    y = y - 0.010
    scale = scale/2
    y = y + 0.002
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextFont(font)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function showToolTip(text, font, size)
    local sx, sy = GetActiveScreenResolution()
    local cx, cy = GetNuiCursorPosition()
    local cx, cy = ( cx / sx ) + 0.008, ( cy / sy ) + 0.027

    SetTextScale(size, size)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(0, 0, 0, 0, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(cx, cy + 0.007)
end

function isCursorInPosition(x,y,width,height)
    local sx, sy = GetActiveScreenResolution()
    local cx, cy = GetNuiCursorPosition()
    local cx, cy = (cx / sx), (cy / sy)
  
    local width = width / 2
    local height = height / 2
  
    if (cx >= (x - width) and cx <= (x + width)) and (cy >= (y - height) and cy <= (y + height)) then
        return true
    else
        return false
    end
end

-- x = true
-- Citizen.CreateThread(function()
--     while x do
--         Wait(6000)
--         vRPbpS.openBpMenu({})
--     end
-- end)

Citizen.CreateThread(function()
    colors = {}
    vRPbpS.openBpMenu({})
    while true do
        Citizen.Wait(0)
        if(showBPmenu) then
            ShowCursorThisFrame()
            DisableControlAction(0,24,true)
            DisableControlAction(0,47,true)
            DisableControlAction(0,58,true)
            DisableControlAction(0,263,true)
            DisableControlAction(0,264,true)
            DisableControlAction(0,257,true)
            DisableControlAction(0,140,true)
            DisableControlAction(0,141,true)
            DisableControlAction(0,142,true)
            DisableControlAction(0,143,true)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)

            DrawRect(0.500, 0.500, 0.600, 0.45, 0, 0, 0, 180)
            drawtxt("~y~BATTLE~w~PASS",7,1,0.274, 0.245,1,255,255,255,255)

            DrawRect(0.275, 0.25, 0.150, 0.05, 0, 0, 0, 180)
            DrawRect(0.5, 0.275, 0.6, 0.001, 180, 0, 220, 200)

            DrawRect(0.275, 0.75, 0.150, 0.05, 0, 0, 0, 180)
            drawtxt("~y~Tier: ~w~"..actTier,7,1,0.27, 0.75,1,255,255,255,255)
            
            DrawRect(0.575, 0.75, 0.23, 0.05, 5, 97, 0, 180)
            drawtxt("CUMPARA Tier",fontId,1,0.575, 0.745,0.60,255,255,255,255)

            DrawRect(0.785, 0.31, 0.03, 0.03, 132,0,0, 180)
            drawtxt("X",0,1,0.785, 0.3,1,255,255,255,255)

            DrawRect(0.405, 0.75, 0.11, 0.05, 175,175,25, 200) -- stanga 
            drawtxt("stanga",fontId,1,0.405, 0.745,0.60,255,255,255,255)
            DrawRect(0.745, 0.75, 0.11, 0.05, 175,175,25, 200)  -- dreapta
            drawtxt("dreapta",fontId,1,0.745, 0.745,0.60,255,255,255,255)
            
            drawtxt("Preview: "..startN,fontId,1,0.5, 0.35,0.60,255,255,255,255)
            
            if startN < actTier then
                colors = {r=255,g=255,b=255,a=255}
            elseif startN > actTier then
                colors = {r=0,g=0,b=0,a=180}
            end
            
            if tiers[startN].type == "money" then
                DrawSprite("moneyIcn", "moneyIcn", 0.5,0.55, 0.13,0.18, 0, colors.r,colors.g, colors.b,colors.a)
            elseif tiers[startN].type == "gold" then
                DrawSprite("gold", "gold", 0.5,0.55, 0.13,0.18, 0, colors.r,colors.g, colors.b,colors.a)
            elseif tiers[startN].type == "car" then
                DrawSprite("car", "car", 0.5,0.55, 0.13,0.18, 0, colors.r,colors.g, colors.b,colors.a)
            end

            if isCursorInPosition(0.745, 0.75, 0.1, 0.03) then
                SetCursorSprite(5)
                if(IsDisabledControlJustPressed(0, 24))then -- inainte
                    startN = startN + 1
                    if startN > #tiers then
                        startN = 40
                    end
                end
            elseif isCursorInPosition(0.405, 0.75, 0.1, 0.03) then -- inapoi
                SetCursorSprite(5)
                if(IsDisabledControlJustPressed(0, 24))then
                    startN = startN - 1
                    if startN < 1 then
                        startN = 1
                    end
                end
            elseif isCursorInPosition(0.785, 0.31, 0.04, 0.03) then
                SetCursorSprite(5)
                if(IsDisabledControlJustPressed(0, 24))then
                    showBPmenu = false
                end
            elseif isCursorInPosition(0.575, 0.75, 0.225, 0.037) then
                SetCursorSprite(5)
                showToolTip("~g~$"..tiers[actTier].cost, 7, 0.40)
                if(IsDisabledControlJustPressed(0, 24))then
                    vRPbpS.buyTier({})
                end
            else
                SetCursorSprite(1)
            end
        end
    end
end)




-- DrawSprite("battlepass", "battlepass", 0.28,0.45, 0.10,0.15, 0, 255,255,255,255)
-- DrawSprite("battlepass", "battlepass", 0.39,0.45, 0.10,0.15, 0, 255,255,255,255)
-- DrawSprite("battlepass", "battlepass", 0.5,0.45, 0.10,0.15, 0, 255,255,255,255)
-- DrawSprite("battlepass", "battlepass", 0.61,0.45, 0.10,0.15, 0, 255,255,255,255)
-- DrawSprite("battlepass", "battlepass", 0.72,0.45, 0.10,0.15, 0, 255,255,255,255)