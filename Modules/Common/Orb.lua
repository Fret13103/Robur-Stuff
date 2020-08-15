require("common.log")
module("Lib_Orb", package.seeall, log.setup)

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
    Setting = {
        AllowMovement = true,
        AllowAttack = true,
        Key = {
            Combo = 32, -- Spacebar
            LastHit = 88, -- X
            Harras = 67, -- C
            LaneClear = 86, -- V
            LaneFreeze = 89, -- Y
            Flee = 84, -- T
        },
        MovementDelay = 100, -- Lower = Smoother but also unsafe when you click faster then light, tofast clicks can lead to dc
        Drawing = {
            Quality = 30,
            AttackRange = {
                Own = {
                    Active = true,
                    Color = 0xFFFFFFFF,
                },
                Enemy = {
                    Active = true,
                    Color = 0xFF00FFFF,
                    Distance = 500,
                }
            },
            BoundingRadius = {
                Own = {
                    Active = true,
                    Color = 0xFFFFFFFF
                },
                Enemy= {
                    Minion = {
                        Active = false,
                        Color = 0xFF00FFFF,
                        Distance = 1000
                    },
                    Hero = {
                        Active = true,
                        Color = 0xBFBFBFFF,
                        Distance = 500
                    }
                }
            }
        }
    },
    Mode = {
        Combo = false,
        LaneClear = false,
        Harras = false,
        LastHit = false,
        LaneFreeze = false,
    },
    Data = {
        LastMove = {
            Time = 0,
            Position = nil,
        },
        LastAttack = {
            Time = 0,
            Target = nil,
            Confirmed = false,
        }
    },
    Override = {
        Target = nil,
        Position = nil,
    }
}

local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local _MinionList = Set{"SRU_OrderMinionMelee", "SRU_OrderMinionRanged", "SRU_OrderMinionSiege",
                        "SRU_ChaosMinionMelee", "SRU_ChaosMinionRanged", "SRU_ChaosMinionSiege" }

local _AutoAttack_Attacks = Set{"caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc",
                                "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute",
                                "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust",
                                "viktorqbuff", "xenzhaothrust2", "xenzhaothrust3"}

local _AutoAttack_NoAttacks = Set{"jarvanivcataclysmattack", "monkeykingdoubleattack", "shyvanadoubleattack",
                                  "shyvanadoubleattackdragon", "zyragraspingplantattack", "zyragraspingplantattack2",
                                  "zyragraspingplantattackfire", "zyragraspingplantattack2fire"}

local _AutoAttack_AttackReset = Set{"asheq", "dariusnoxiantacticsonh", "fioraflurry", "garenq", "hecarimrapidslash",
                                    "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak",
                                    "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq",
                                    "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow",
                                    "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw",
                                    "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie",
                                    "volibearq", "xenzhaocombotarget", "yorickspectral"}

local function AsTime(value)
    return value / 1000
end

local function AsTick(value)
    return value * 1000
end

local function GetMyHitTime(unit)
    return Player.AttackCastDelay * 1000 - 100 + Game.GetLatency() / 2 + 1000 * Player.Position:Distance(unit.Position) / Orbwalker:MyProjectileSpeed()
end

local function IsAutoAttackReset(name)
    return _AutoAttack_AttackReset[name:lower()]
end

local function IsAutoAttack(name)
    return (string.match(name:lower(), "attack") and not _AutoAttack_NoAttacks[name:lower()]) or
            _AutoAttack_Attacks[name:lower()]
end

local function GetPredictedHealth(unit, delay)
    --todo healthprediction
    return unit.Health
end

local function Custom_Lasthit_Logic()
    -- Custom LastHit Logic for Champions

    return nil
end

local function Basic_Lasthit_Logic()
    -- Basic LastHit Logic for Most Champions
    local minions = ObjectManager.Get("all", "minions")
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and minion.IsVisible and not minion.IsDead and Orbwalker:IsValidMinion(minion) and Orbwalker.IsValidAutoAttackTarget(minion)  then
            local t = GetMyHitTime(minion)
            local pHealth = GetPredictedHealth(minion, t)
            if pHealth > 0 and pHealth <= DMGLib:GetDamage("AA", minion) then
                return minion
            end
        end
    end
    return nil
end

function Orbwalker:MyProjectileSpeed()
    if PLayer.CharName == "Azir" or Player.CharName == "Kayle" or Player.AttackRange <= 325 then
        return Player.AttackData.MissileMaxSpeed
    else
        return Player.AttackData.MissileSpeed
    end
end

function Orbwalker:GetAttackRange(target, source)
    source = source or Player
    local range = source.AttackRange + source.BoundingRadius
    if target then
        range = range + target.BoundingRadius
        if target.IsHero then
            range = range - 25
        end
    end
    return range
end

function Orbwalker:IsValidAutoAttackTarget(unit)
    if unit == nil then return false end
    if unit.IsDead then return false end
    if not unit.IsVisible then return false end
    if not Orbwalker:IsInAutoAttackRange(unit, Player) then return false end
    return true
end

function Orbwalker:IsValidMinion(unit)
    if unit == nil then return false end
    if _MinionList[unit.CharName] then return true end
    return false
end

function Orbwalker:IsInAutoAttackRange(target, source)
    source = source or Player
    return source.Position:Distance(target.Position) <= Orbwalker:GetAttackRange(target, source)
end

function Orbwalker:GetMovePos()
    if Orbwalker.Override.Position ~= nil then
        return Orbwalker.Override.Position
    end
    local mousePos = Renderer.GetMousePos()
    return mousePos
end

function Orbwalker:GetBestPossibleTarget()
    -- Custom Set Target by Script, Highest Priority
    local TempTarget = Orbwalker.Override.Target
    if TempTarget then
        if Orbwalker:IsValidAutoAttackTarget(TempTarget) then
            return TempTarget
        end
        TempTarget = nil
    end

    if (Orbwalker.Mode.Harras or Orbwalker.Mode.LastHit or Orbwalker.Mode.LaneClear  or Orbwalker.Mode.LaneFreeze) then
        TempTarget = Custom_Lasthit_Logic() or Basic_Lasthit_Logic()
        if TempTarget then return TempTarget end
    end
end

function Orbwalker:MinPingCalc()

    local minPing = 40
    local value = 0
    if Game.GetLatency() > 100 then
        value = minPing + Game.GetLatency() * 0.1
    elseif Game.GetLatency() > 50 then
        value = minPing + Game.GetLatency() * 0.5
    else
        value = minPing + Game.GetLatency() * 1.5
    end
    return AsTime(value)
end

function Orbwalker:AttackDelay()
    -- For Champ Specific use Later
    return 0
end

function Orbwalker:WalkDelay()
    -- For Champ Specific use Later
    return Orbwalker:MinPingCalc()
end


function Orbwalker:CanAttack()
    if Orbwalker.Setting.AllowAttack and Orbwalker.Data.LastAttack.Time + Player.AttackDelay - AsTime(Game:GetLatency() / 2) <= Game.GetTime()  then
        return true
    end
    return false
end

function Orbwalker:Attack()
    if Orbwalker:CanAttack() then
        local Args = { Process = true}
        Args.Target = Orbwalker.Override.Target or ts:GetTarget(Player.AttackRange - 25, ts.Priority.LowestHealth)
        EventManager.FireEvent(Events.OnPreAttack, Args)
        if Args.Target ~= nil and Args.Process and Orbwalker:IsValidAutoAttackTarget(Args.Target) then
            Orbwalker.Data.LastAttack.Confirmed = false
            Input.Attack(Args.Target)
            Orbwalker.Data.LastAttack.Time = Game.GetTime()
            Orbwalker.Data.LastAttack.Target = Args.Target
            Orbwalker.Override.Target = nil
        end
    end
end

function Orbwalker:CanWalk()
    if  Orbwalker.Setting.AllowMovement and  Orbwalker.Data.LastMove.Time + AsTime(Orbwalker.Setting.MovementDelay) <= Game.GetTime() then
        return Orbwalker.Data.LastAttack.Confirmed or Orbwalker.Data.LastAttack.Time + Player.AttackCastDelay + Orbwalker:WalkDelay() <= Game.GetTime()
    end
    return false
end

function Orbwalker:Walk()
    if Orbwalker:CanWalk() then
        pos = Orbwalker:GetMovePos()
        Args = {Process = true, Position = pos}
        EventManager.FireEvent(Events.OnPostMove, Args)
        if Args.Process then
            Input.MoveTo(Args.Position)
            Orbwalker.Data.LastMove.Time = Game.GetTime()
            Orbwalker.Data.LastMove.Position = Args.Position
            Orbwalker.Override.Position = nil
            delay(Game.GetLatency() / 2 + 5, function ()
                EventManager.FireEvent(Events.OnPostMove, Args.Position)
            end)
        end
    end
end

function Orbwalker:Orbwalk()
    Orbwalker:Attack()
    Orbwalker:Walk()
end

local function OnUpdate()
    if Game.IsChatOpen() then return end
    if Game.IsMinimized() then return end
    if Player.IsDead then return end

    if Orbwalker.Mode.Combo or Orbwalker.Mode.LaneClear or Orbwalker.Mode.LastHit or
            Orbwalker.Mode.Harras or Orbwalker.Mode.Flee or Orbwalker.Mode.LaneFreeze then
        Orbwalker.Orbwalk()
    end
end

local function OnDraw()
    local drawing = Orbwalker.Setting.Drawing
    if (drawing.AttackRange.Own.Active) then
         Renderer.DrawCircle3D(Player.Position, Orbwalker:GetAttackRange(), drawing.Quality,1, drawing.AttackRange.Own.Color)
    end
    if (drawing.BoundingRadius.Own.Active) then
         Renderer.DrawCircle3D(Player.Position, Player.BoundingRadius, drawing.Quality,1, drawing.BoundingRadius.Own.Color)
    end
    if (drawing.BoundingRadius.Enemy.Minion.Active) then
         local minions = ObjectManager.Get("enemy", "minions")
         for _, obj in pairs(minions) do
             local minion = obj.AsMinion
             if minion and minion.IsVisible and not minion.IsDead and Player.Position:Distance(minion.Position) <= Orbwalker:GetAttackRange(minion) + drawing.BoundingRadius.Enemy.Minion.Distance then
                 Renderer.DrawCircle3D(minion.Position, minion.BoundingRadius, drawing.Quality,1, drawing.BoundingRadius.Enemy.Minion.Color)
             end
        end
    end
    if (drawing.BoundingRadius.Enemy.Hero.Active or drawing.AttackRange.Enemy.Active) then
         local heroes = ObjectManager.Get("enemy", "heroes")
         for _, obj in pairs(heroes) do
             local hero = obj.AsHero
             if hero  and hero.IsVisible and not hero.IsDead and Player.Position:Distance(hero.Position) <= Orbwalker:GetAttackRange() + drawing.BoundingRadius.Enemy.Hero.Distance then
                 if drawing.BoundingRadius.Enemy.Hero.Active then
                     Renderer.DrawCircle3D(hero.Position, hero.BoundingRadius, drawing.Quality,1, drawing.BoundingRadius.Enemy.Hero.Color)
                 end
                 if drawing.AttackRange.Enemy.Active then
                     Renderer.DrawCircle3D(hero.Position, Orbwalker:GetAttackRange(hero), drawing.Quality,1, drawing.AttackRange.Enemy.Color)
                 end
             end
        end
    end
end

local function OnCreateObject(obj)
    if obj then
        local missile = obj.AsMissile
        if missile and missile.Source and missile.Target and missile.Source.Ptr == Player.Ptr then
            if IsAutoAttack(missile.Name) then
                Orbwalker.Data.LastAttack.Confirmed = true
                EventManager.FireEvent(Events.OnPostAttack, missile.Target)
            end
        end
    end
end

local function OnProcessSpell(obj, spell)
    if obj then
        if obj.Ptr == Player.Ptr then
            if IsAutoAttack(spell.Name) then
                Orbwalker.Data.LastAttack.Time = Game.GetTime()
            end
            if IsAutoAttackReset(spell.Name) then
                delay(100, function() Orbwalker.Data.LastAttack.Time = 0 end)
            end
        end
    end

end

function Orbwalker.Load()
    if not Orbwalker.Loaded then
        Orbwalker.Loaded = true
        EventManager.RegisterCallback(Events.OnDraw, OnDraw)
        EventManager.RegisterCallback(Events.OnUpdate, OnUpdate)
        EventManager.RegisterCallback(Events.OnCreateObject, OnCreateObject)
        EventManager.RegisterCallback(Events.OnProcessSpell, OnProcessSpell)

        local Key = Orbwalker.Setting.Key
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.Combo then Orbwalker.Mode.Combo = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.Combo then Orbwalker.Mode.Combo = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.LastHit then Orbwalker.Mode.LastHit = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.LastHit then Orbwalker.Mode.LastHit = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.Harras then Orbwalker.Mode.Harras = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.Harras then Orbwalker.Mode.Harras = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.LaneClear then Orbwalker.Mode.LaneClear = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.LaneClear then Orbwalker.Mode.LaneClear = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.LaneFreeze then Orbwalker.Mode.LaneFreeze = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.LaneFreeze then Orbwalker.Mode.LaneFreeze = false end end)
        EventManager.RegisterCallback(Events.OnKeyDown, function(keycode, _, _) if keycode == Key.Flee then Orbwalker.Mode.Flee = true  end end)
        EventManager.RegisterCallback(Events.OnKeyUp,   function(keycode, _, _) if keycode == Key.Flee then Orbwalker.Mode.Flee = false end end)
    end
end

return Orbwalker