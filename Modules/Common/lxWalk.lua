require("common.log")
module("lxWalk", package.seeall, log.setup)

local _Core = _G.CoreEx
local Console, ObjManager, EventManager, Input, Renderer, Enums, Game = _Core.Console, _Core.ObjectManager, _Core.EventManager, _Core.Input, _Core.Renderer, _Core.Enums, _Core.Game
local Events, SpellSlots, SpellStates = Enums.Events, Enums.SpellSlots, Enums.SpellStates
local Player = ObjManager.Player

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local IgnorList = Set{"WardCorpse", "hiu", "Noxious Trap", "PlantVision", "Cupcake Trap", "PlantHealthPack", "PlantVision",
                   "PlantHealth", "PlantHealthMirrored", "PlantSatchel", "CampRespawn","ShenArrowVfxHostMinion", "seed",
                   "PlagueBlock", "ShenSpiritUnit", "k", "PlantMasterMinion", "MarkerMinion", "RobotBuddy", "AzirSoldier"}
Orbwalker = {}

Orbwalker.Setting = {
    MovementDelay = 100,
    WindUp = 40,
    PingMin = 30
}
Orbwalker.Mode = {
    Combo = false
}
Orbwalker.LastMove = {
    Tick = 0,
    Pos = nil
}

Orbwalker.LastAttack = {
    Tick = 0,
    Target = nil
}

local function GetTick()
    return math.floor(Game.GetTime() * 1000)
end

local function GetModDelay()
    local ping = math.max(Game.GetLatency()/2, Orbwalker.Setting.PingMin)
    return math.floor(ping + Orbwalker.Setting.WindUp)
end

local function AfterAttack(unit)
    if (unit.IsHero or unit.IsTurret or unit.IsNexus or unit.IsInhibitor or unit.IsMonster) then
        if Player:GetSpellState(SpellSlots.Q) == SpellStates.Ready then
            Input.Cast(SpellSlots.Q)
            Orbwalker.LastAttack.Tick = 0
        end
    end
end

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function ValidTarget(unit)
    if not unit.IsValid then return false end
    if not unit.IsVisible then return false end
    local name = unit.Name
    if starts_with(name, "Minion_") then return true end
    if starts_with(name, "SRU_") then return true end
    if starts_with(name, "Turret_") then return true end
    if starts_with(name, "Barracks_") then return true end
    if starts_with(name, "HQ_") then return true end
    if starts_with(name, "Sru_") then return true end
    if starts_with(name, "MiniKrug") then return true end

    if IgnorList[name] then return false end

    if not unit.IsHero then INFO(name) end
    return true
end

local function InAutoAttackRange(attackableUnit)
    local attackRange = Player.AttackRange + Player.BoundingRadius + attackableUnit.BoundingRadius
    return Player.Position:Distance(attackableUnit.Position) < attackRange
end

local function CanAttack()
    local tick = GetTick()
    if Orbwalker.LastAttack.Tick + Player.AttackDelay*1000 + GetModDelay() <= tick then
        return true
    end
    return false
end

local function CanMove(pos)
    local tick = GetTick()
    if Orbwalker.LastAttack.Tick <= tick then
        if Orbwalker.LastMove.Tick + Orbwalker.Setting.MovementDelay <= tick then --todo Optional Delay
            if Orbwalker.LastMove.Pos ~= pos then -- todo Check if Interrupted
                if Orbwalker.LastAttack.Tick + Player.AttackCastDelay*1000 + GetModDelay()  <= tick then
                    return true
                end
            end
        end
    end
    return false
end

local function CommandMove(pos)
    if CanMove(pos) then
        Input.MoveTo(pos)
        Orbwalker.LastMove.Tick = GetTick()
        Orbwalker.LastMove.Pos = pos
    end
end

local function CommandAttack(attackableUnit)
    Input.Attack(attackableUnit)
    Orbwalker.LastMove.Pos = nil
    Orbwalker.LastAttack.Tick = GetTick()
    Orbwalker.LastAttack.Target = attackableUnit
    --_G.delay(GetModDelay() + 250, function () AfterAttack(attackableUnit) end)
end

local function GetBestAATarget(mode)
    if (mode == Orbwalker.Mode.Combo) then
        if CanAttack() then

            local turrets = ObjManager.Get("enemy","turrets")
            for _, obj in pairs(turrets) do
                local turret = obj.AsTurret
                if turret and turret.Health > 0 and turret.IsTargetable and InAutoAttackRange(turret) and ValidTarget(turret) then
                    return turret
                end
            end

            local inhibs = ObjManager.Get("enemy","inhibitors")
            for _, obj in pairs(inhibs) do
                local inhib = obj.AsAttackableUnit
                if inhib and inhib.Health > 0 and inhib.IsTargetable and InAutoAttackRange(inhib) and ValidTarget(inhib) then
                    return inhib
                end
            end

            local hqs = ObjManager.Get("enemy","hqs")
            for _, obj in pairs(hqs) do
                local hq = obj.AsAttackableUnit
                if hq and hq.Health > 0 and hq.IsTargetable and InAutoAttackRange(hq) and ValidTarget(hq) then
                    return hq
                end
            end

            local enemies = ObjManager.Get("enemy", "heroes")
            local tempHero = nil
            for _, obj in pairs(enemies) do
                local hero = obj.AsHero
                if hero and hero.IsTargetable and hero.Health > 0 and InAutoAttackRange(hero) and ValidTarget(hero) then
                    if tempHero == nil or hero.Health < tempHero.Health then
                        tempHero = hero
                    end
                end
            end
            if tempHero ~= nil then return tempHero end

            local minions = ObjManager.Get("enemy", "minions")
            local tempMinion = nil
            for _, obj in pairs(minions) do
                local minion = obj.AsMinion
                if minion and minion.IsTargetable and minion.Health > 0 and InAutoAttackRange(minion) and ValidTarget(minion) then
                    if tempMinion == nil or minion.Health < tempMinion.Health then
                        tempMinion = minion
                    end
                end
            end
            if tempMinion ~= nil then return tempMinion end

            local wards = ObjManager.Get("enemy", "wards")
            local tempWard = nil
            for _, obj in pairs(wards) do
                local ward = obj.AsAttackableUnit
                if ward and ward.IsTargetable and ward.Health > 0 and InAutoAttackRange(ward) and ValidTarget(ward) then
                    if tempWard == nil or ward.Health < tempWard.Health then
                        tempWard = ward
                    end
                end
            end
            if tempWard ~= nil then return tempWard end

            local minions = ObjManager.Get("neutral", "minions")
            local tempMinion = nil
            for _, obj in pairs(minions) do
                local minion = obj.AsMinion
                if minion and minion.IsTargetable and minion.Health > 0 and InAutoAttackRange(minion) and ValidTarget(minion) then
                    if tempMinion == nil or minion.Health < tempMinion.Health then
                        tempMinion = minion
                    end
                end
            end
            if tempMinion ~= nil then return tempMinion end
        end
    end
    return nil
end

local function OnTick()
    if Orbwalker.Mode.Combo then
        local target = GetBestAATarget(Orbwalker.Mode.Combo)
        if target ~= nil then
            CommandAttack(target)
        else
            movePos = Renderer.GetMousePos()
            CommandMove(movePos)
        end
    end
end

local function OnDraw()

end

function OnLoad()
    INFO("Loading LX-Walk")
    EventManager.RegisterCallback(Events.OnTick, OnTick)
    EventManager.RegisterCallback(Events.OnDraw, OnDraw)
    EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, char, lparam) if keycode == 32 then Orbwalker.Mode.Combo = true  end end)
    EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, char, lparam) if keycode == 32 then Orbwalker.Mode.Combo = false end end)
    INFO("LX-Walk Loaded")
    return true
end
