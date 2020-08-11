return

require("common.log")
module("Simple Orbwalker", package.seeall, log.setup)

local _SDK = _G.CoreEx
local Console, ObjManager, EventManager, Geometry, Input, Renderer, Enums, Game = _SDK.Console, _SDK.ObjectManager, _SDK.EventManager, _SDK.Geometry, _SDK.Input, _SDK.Renderer, _SDK.Enums, _SDK.Game
local Player = ObjManager.Player

_G.OrbActive = false
_G.OrbTarget = nil
local CurrentTarget, LastAttack, LastMove = nil, 0, 0

local function GetTarget()
    local myPos, myRange = Player.Position, (Player.AttackRange + Player.BoundingRadius)

    local enemies = ObjManager.Get("enemy", "heroes")
    for handle, obj in pairs(enemies) do        
        local hero = obj.AsHero        
        if hero and myPos:Distance(hero.Position) < myRange and hero.IsTargetable then
            return hero               
        end
    end
end

local function OnTick()
    CurrentTarget = GetTarget()
    _G.OrbTarget = CurrentTarget
    if not _G.OrbActive then return end

    local time, ping = Game.GetTime(), Game.GetLatency()
    local timeSinceLastAttack = time - LastAttack
    local timeSinceLastMove = time - LastMove

    
    if CurrentTarget and (timeSinceLastAttack + ping/2000) > (Player.AttackDelay + 0.035) then
        Input.Attack(CurrentTarget)
        LastAttack = time
    elseif timeSinceLastMove > 0.1 and timeSinceLastAttack > (Player.AttackCastDelay + ping/1000 + 0.035) then
        Input.MoveTo(Renderer.GetMousePos())
        LastMove = time
    end
end

local function OnDraw()       
    if CurrentTarget then 
        Renderer.DrawCircle3D(CurrentTarget.Position, CurrentTarget.BoundingRadius, 6, 2, 0xFF0000FF)
    end        
end

function OnLoad()  
    EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw) 
    EventManager.RegisterCallback(Enums.Events.OnTick, OnTick)   
    EventManager.RegisterCallback(Enums.Events.OnKeyDown, function(keycode, char, lparam) if keycode == 32 then _G.OrbActive = true  end end)  
    EventManager.RegisterCallback(Enums.Events.OnKeyUp,   function(keycode, char, lparam) if keycode == 32 then _G.OrbActive = false end end)    
    return true
end