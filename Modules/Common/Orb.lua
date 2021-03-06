require("common.log")
module("Lib_Orb", package.seeall, log.setup)

_G.OrbTarget = nil
_G.OrbActive = true

local DMGLib = require("lol/Modules/Common/DamageLib")

local ts = require("lol/Modules/Common/simpleTS")

local _Core = _G.CoreEx
local ObjectManager = _Core.ObjectManager
local EventManager = _Core.EventManager
local Renderer = _Core.Renderer
local Game = _Core.Game
local Input = _Core.Input
local Events = _Core.Enums.Events
local BuffTypes = _Core.Enums.BuffTypes
local Player = ObjectManager.Player

local Orbwalker = {
    Loaded = false,
    CurrentTarget = nil,
    Setting = {
        Key = {
            Combo = 32, -- Spacebar
            LastHit = 88, -- X
            Harras = 67, -- C
            LaneClear = 86, -- V
        },
        WindUp = 40,
        MinDelay = 50,
        MovementDelay = 100,
        Drawing = {
            Quality = 30,
            AttackRange = {
                Own = true,
                OwnColor = 0xFFFFFFFF,
                Enemy = true,
                Distance = 1000 -- Additional to Enemy AttackRange
            },
            BoundingRadius = {
                Own = true,
                OwnColor = 0xFFFFFFFF,
                EnemyMinion = {
                    Active = true,
                    Color = 0xFF00FFFF,
                },
                EnemyHero = {
                    Active = true,
                    Color = 0xBFBFBFFF,
                }
            }
        }
    },
    Mode = {
        Combo = false,
        LastHit = false,
        Harras = false,
        LaneClear = false,
    },
    LastMove = {
        Tick = 0,
        Pos = nil
    },
    LastAttack = {
        Tick = 0,
        Target = nil,
    },
    Override = {
        ForceMovePos = nil,
        ForceTarget = nil,
    }
}

local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local IgnoreList = Set{"NidaleeSpear", "SRU_CampRespawnMarker", "SRU_Plant_Health", "SRU_Plant_Vision","SRU_Plant_Satchel",
                       "ShenSpirit", "CaitlynTrap", "S5Test_WardCorpse"}

function Orbwalker:GetTick()
    return math.floor(Game.GetTime() * 1000)
end

function Orbwalker:ResetAutoAttack(d)
    d = d or 0
    if d == 0 then
        Orbwalker.LastAttack.Tick = 0
    else
        delay(d, function () Orbwalker.LastAttack.Tick = 0 end)
    end
end

function Orbwalker:ResetLastMove()
        Orbwalker.LastMove.Tick = 0
end

function Orbwalker:GetModDelay()
    local ping = Game.GetLatency()
    local addValue = 0
    if ping >= 100 then
        addValue = ping / 100 * 10
    elseif ping >  Orbwalker.Setting.MinDelay and ping < 100 then
        addValue = ping / 100 * 15
    else
        addValue = ping / 100 * 25 + Orbwalker.Setting.MinDelay
    end
    addValue = addValue + Orbwalker.Setting.WindUp
    return addValue
end

function Orbwalker:GetAttackRange(source, target)
    source = source or Player
    local dist = source.AttackRange + source.BoundingRadius
    if target then
        dist = dist + target.BoundingRadius
        if target.IsHero then
            dist = dist - 25
        end
    end
    return dist
end

function Orbwalker:InAttackRange(target)
    if target and target.IsValid then
        return Player.Position:Distance(target.Position) < Orbwalker:GetAttackRange(Player,target)
    end
end

function Orbwalker:HasBuffType(unit,buffType)
    local ai = unit.AsAI
    if ai and ai.IsValid then
        for i = 0, ai.BuffCount do -- unit.BuffCount returns nil
            local buff = ai:GetBuff(i)
            if buff and buff.IsValid and buff.BuffType == buffType then
                return true
            end
        end
    end
    return false
end

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end


function Orbwalker:IsValidAutoAttackTarget(obj)
    local unit = obj.AsAttackableUnit
    if not obj.IsAlive or not obj.IsTargetable then return false end
    if IgnoreList[obj.CharName] then return false end
    if unit and  not unit.IsDead and unit.Health > 0 then
        if starts_with(tostring(obj.IsAlive),"function: ") then return false end
        local range = Orbwalker:GetAttackRange(Player, unit)
        if Player.Position:Distance(unit.Position) < range then
            if not Orbwalker:HasBuffType(unit, BuffTypes.Invulnerability) or not unit.IsDodgingMissiles then
                return true
            end
        end
    end
    return false
end

local function TempGetLastHitMinion()
    local minions = ObjectManager.Get("enemy", "minions")
    local tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and Orbwalker:IsValidAutoAttackTarget(minion) and DMGLib:GetDamage("AA", minion) > minion.Health then
            if tempMinion == nil or minion.Health < tempMinion.Health then
                tempMinion = minion
            end
        end
    end
    if tempMinion ~= nil then return tempMinion end
end

local function TempGetLaneClearTarget()
    local turrets = ObjectManager.Get("enemy","turrets")
    for _, obj in pairs(turrets) do
        local turret = obj.AsTurret
        if turret and Orbwalker:IsValidAutoAttackTarget(turret) then
            return turret
        end
    end

    local inhibs = ObjectManager.Get("enemy","inhibitors")
    for _, obj in pairs(inhibs) do
        local inhib = obj.AsAttackableUnit
        if inhib and Orbwalker:IsValidAutoAttackTarget(inhib) then
            return inhib
        end
    end

    local hqs = ObjectManager.Get("enemy","hqs")
    for _, obj in pairs(hqs) do
        local hq = obj.AsAttackableUnit
        if hq and Orbwalker:IsValidAutoAttackTarget(hq) then
            return hq
        end
    end

    local enemies = ObjectManager.Get("enemy", "heroes")
    local tempHero = nil
    for _, obj in pairs(enemies) do
        local hero = obj.AsHero
        if hero and Orbwalker:IsValidAutoAttackTarget(hero) then
            if tempHero == nil or hero.Health < tempHero.Health then
                tempHero = hero
            end
        end
    end
    if tempHero ~= nil then return tempHero end

    local minions = ObjectManager.Get("enemy", "minions")
    local tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and Orbwalker:IsValidAutoAttackTarget(minion) then
            if tempMinion == nil or minion.Health < tempMinion.Health then
                tempMinion = minion
            end
        end
    end
    if tempMinion ~= nil then return tempMinion end

    local wards = ObjectManager.Get("enemy", "wards")
    local tempWard = nil
    for _, obj in pairs(wards) do
        local ward = obj.AsAttackableUnit
        if ward and Orbwalker:IsValidAutoAttackTarget(ward) then
            if tempWard == nil or ward.Health < tempWard.Health then
                tempWard = ward
            end
        end
    end
    if tempWard ~= nil then return tempWard end

    minions = ObjectManager.Get("neutral", "minions")
    tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and Orbwalker:IsValidAutoAttackTarget(minion) then
            if tempMinion == nil or minion.Health < tempMinion.Health then
                tempMinion = minion
            end
        end
    end
    if tempMinion ~= nil then return tempMinion end
    return nil
end

function Orbwalker:CanAttack()
    local tick = Orbwalker:GetTick()
    return Orbwalker.LastAttack.Tick + Player.AttackDelay*1000 + Orbwalker:GetModDelay() <= tick
end

function Orbwalker:CanWalk()
    local tick = Orbwalker:GetTick()
    if Orbwalker.LastMove.Tick + Orbwalker.Setting.MovementDelay <= tick then
        return tick + Game.GetLatency() / 2 >= Orbwalker.LastAttack.Tick + Player.AttackCastDelay*1000 + Orbwalker:GetModDelay()
    end
    return false
end

function Orbwalker:GetMovePos()
    if Orbwalker.Override.ForceMovePos ~= nil then
        return Orbwalker.Override.ForceMovePos
    end
    return Renderer.GetMousePos()
end


local function PrintIfSuspect(unit)
    if unit.IsHero then return end
    local name = unit.Name
    if starts_with(name, "Minion_") then return end
    if starts_with(name, "SRU_") then return end
    if starts_with(name, "Turret_") then return end
    if starts_with(name, "Barracks_") then return end
    if starts_with(name, "HQ_") then return end
    if starts_with(name, "Sru_") then return end
    if starts_with(name, "MiniKrug") then return end
    INFO("Attacked: ".. string.lower(name))
    if unit.CharName ~= nil then
        INFO("CharName: ".. tostring(unit.CharName))
    end
    if unit.IsDead ~= nil then
        INFO("IsDead: ".. tostring(unit.IsDead))
    end
    if unit.IsZombie ~= nil then
        INFO("IsZombie: ".. tostring(unit.IsZombie))
    end
    if unit.TypeFlags ~= nil then
        INFO("TypeFlags: ".. tostring(unit.TypeFlags))
    end
    if unit.IsWard ~= nil then
        INFO("IsWard: ".. tostring(unit.IsWard))
    end
    if unit.IsParticle ~= nil then
        INFO("IsParticle: ".. tostring(unit.IsParticle))
    end
    if unit.IsAttackableUnit ~= nil then
        INFO("IsAttackableUnit: ".. tostring(unit.IsAttackableUnit))
    end
    if unit.IsAI ~= nil then
        INFO("IsAI: ".. tostring(unit.IsAI))
    end
    if unit.IsMinion ~= nil then
        INFO("IsMinion: ".. tostring(unit.IsMinion))
    end
      if unit.IsTurret ~= nil then
        INFO("IsTurret: ".. tostring(unit.IsTurret))
    end
      if unit.IsNexus ~= nil then
        INFO("IsNexus: ".. tostring(unit.IsNexus))
    end
      if unit.IsInhibitor ~= nil then
        INFO("IsInhibitor: ".. tostring(unit.IsInhibitor))
    end
      if unit.IsBarracks ~= nil then
        INFO("IsBarracks: ".. tostring(unit.IsBarracks))
    end
      if unit.IsStructure ~= nil then
        INFO("IsStructure: ".. tostring(unit.IsStructure))
    end
      if unit.IsShop ~= nil then
        INFO("IsShop: ".. tostring(unit.IsShop))
    end
    if unit.IsWard ~= nil then
        INFO("IsWard: ".. tostring(unit.IsWard))
    end
    if unit.IsShop ~= nil then
        INFO("IsShop: ".. tostring(unit.IsShop))
    end
    if unit.BoundingRadius ~= nil then
        INFO("BoundingRadius: ".. tostring(unit.BoundingRadius))
    end
    if unit.BBoxMin ~= nil then
        INFO("BBoxMin: ".. tostring(unit.BBoxMin))
    end
    if unit.BBoxMax ~= nil then
        INFO("BBoxMax: ".. tostring(unit.BBoxMax))
    end
    if unit.Health ~= nil then
        INFO("Health: ".. tostring(unit.Health))
    end
     if unit.MaxHealth ~= nil then
        INFO("MaxHealth: ".. tostring(unit.MaxHealth))
    end
     if unit.MaxMana ~= nil then
        INFO("MaxMana: ".. tostring(unit.MaxMana))
    end
     if unit.Mana ~= nil then
        INFO("Mana: ".. tostring(unit.Mana))
    end
     if unit.IsAlive ~= nil then
        INFO("IsAlive: ".. tostring(unit.IsAlive))
    end
     if unit.IsStealthed ~= nil then
        INFO("IsStealthed: ".. tostring(unit.IsStealthed))
    end
     if unit.IsDodgingMissiles ~= nil then
        INFO("IsDodgingMissiles: ".. tostring(unit.IsDodgingMissiles))
    end
 if unit.CanAttack ~= nil then
        INFO("CanAttack: ".. tostring(unit.CanAttack))
    end

    INFO("--------")
end

function Orbwalker:Attack()
    if Orbwalker:CanAttack() then
        if _G.OrbTarget ~= nil then Orbwalker.Override.ForceTarget = _G.OrbTarget end
        local target = Orbwalker.Override.ForceTarget
        if target == nil then
            if Orbwalker.Mode.Combo then
                target = ts:GetTarget(Player.AttackRange, ts.Priority.LowestHealth)
                Orbwalker.CurrentTarget = target
            elseif Orbwalker.Mode.LaneClear then
                target = TempGetLaneClearTarget()
            elseif Orbwalker.Mode.LastHit then
                target = TempGetLastHitMinion()
            end
        end
        if target ~= nil then
            local args = {Target=target,Process=true}
            EventManager.FireEvent(Events.OnPreAttack, args)
            if args.Process then
                Input.Attack(args.Target)
                PrintIfSuspect(args.Target)
                Orbwalker:ResetLastMove()
                Orbwalker.LastAttack.Tick = Orbwalker:GetTick()
                Orbwalker.LastAttack.Target = args.Target
                delay(250, function () EventManager.FireEvent(Events.OnPostAttack, args.Target) end)
            end
        end
        Orbwalker.Override.ForceTarget = nil
        _G.OrbTarget = nil
    end
end

function Orbwalker:Walk()
    if Orbwalker:CanWalk() then
        local pos = Orbwalker.GetMovePos()
        -- todo OnPreMove
        local args = {Position=pos,Process=true}
        EventManager.FireEvent(Events.OnPreMove, args)
        if args.Process then
            Input.MoveTo(args.Position)
            Orbwalker.LastMove.Tick = Orbwalker:GetTick()
            Orbwalker.LastMove.Pos = args.Position
            delay(25, function () EventManager.FireEvent(Events.OnPostMove, args.Position) end)
        end
    end
end

function Orbwalker:Orbwalk()
    Orbwalker:Attack()
    Orbwalker:Walk()
end

local function OnPreMove(pos)
    --INFO("OnPreMove: x:"..pos.x.." y:"..pos.y.."z:"..pos.z)
end

local function OnPostMove(pos)
     --INFO("OnPostMove: x:"..pos.x.." y:"..pos.y.."z:"..pos.z)
end

local function OnPreAttack(target)
     --INFO("OnPreAttack:"..target.CharName)
end

local function OnPostAttack(target)
     --INFO("OnPostAttack:"..target.CharName)
end

local function OnBasicAttack(obj, spellCast)
    if obj then
        --INFO(obj.CharName)
    end
end

local function OnTick()
    if Game.IsChatOpen() then return end
    if Player.IsDead then return end

    if Orbwalker.Mode.Combo or Orbwalker.Mode.LaneClear or Orbwalker.Mode.LastHit then
        Orbwalker.Orbwalk()
    end
end

local function OnDraw()
    local drawing = Orbwalker.Setting.Drawing
    if (drawing.AttackRange.Own) then
         Renderer.DrawCircle3D(Player.Position, Orbwalker:GetAttackRange(), drawing.Quality,1, drawing.AttackRange.OwnColor)
    end
    if (drawing.BoundingRadius.Own) then
         Renderer.DrawCircle3D(Player.Position, Player.BoundingRadius, drawing.Quality,1, drawing.AttackRange.OwnColor)
    end
    if (drawing.BoundingRadius.EnemyMinion.Active) then
         local minions = ObjectManager.Get("enemy", "minions")
         for _, obj in pairs(minions) do
             local minion = obj.AsMinion
             if minion and minion.IsVisible and minion.Health > 0 and Player.Position:Distance(minion.Position) <= Orbwalker:GetAttackRange() then
                 Renderer.DrawCircle3D(minion.Position, minion.BoundingRadius, drawing.Quality,1, drawing.BoundingRadius.EnemyMinion.Color)
             end
        end
    end
    if (drawing.BoundingRadius.EnemyHero.Active or drawing.AttackRange.Enemy) then
         local heroes = ObjectManager.Get("enemy", "heroes")
         for _, obj in pairs(heroes) do
             local hero = obj.AsHero
             if hero  and hero.IsVisible and hero.Health > 0  and Player.Position:Distance(hero.Position) <= Orbwalker:GetAttackRange() + drawing.AttackRange.Distance then
                 if drawing.BoundingRadius.EnemyHero.Active then
                     Renderer.DrawCircle3D(hero.Position, hero.BoundingRadius, drawing.Quality,1, drawing.BoundingRadius.EnemyHero.Color)
                 end
                 if drawing.AttackRange.Enemy then
                     Renderer.DrawCircle3D(hero.Position, Orbwalker:GetAttackRange(hero), drawing.Quality,1, drawing.BoundingRadius.EnemyHero.Color)
                 end
             end
        end
    end
end

function Orbwalker.Load()
    if not Orbwalker.Loaded then
        Orbwalker.Loaded = true
        EventManager.RegisterCallback(Events.OnDraw, OnDraw)
        EventManager.RegisterCallback(Events.OnTick, OnTick)
        EventManager.RegisterCallback(Events.OnBasicAttack, OnBasicAttack)

        EventManager.RegisterCallback(Events.OnPreMove, OnPreMove)
        EventManager.RegisterCallback(Events.OnPostMove, OnPostMove)
        EventManager.RegisterCallback(Events.OnPreAttack, OnPreAttack)
        EventManager.RegisterCallback(Events.OnPostAttack, OnPostAttack)

        local Key = Orbwalker.Setting.Key
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.Combo then Orbwalker.Mode.Combo = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.Combo then Orbwalker.Mode.Combo = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.LastHit then Orbwalker.Mode.LastHit = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.LastHit then Orbwalker.Mode.LastHit = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.Harras then Orbwalker.Mode.Harras = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.Harras then Orbwalker.Mode.Harras = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.LaneClear then Orbwalker.Mode.LaneClear = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.LaneClear then Orbwalker.Mode.LaneClear = false end end)
        _G.OrbActive = true
    end
end

return Orbwalker