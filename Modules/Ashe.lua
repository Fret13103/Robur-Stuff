require("common.log")
module("sAshe", package.seeall, log.setup)

local Orb = require("lol/Modules/Common/Orb")

local _Core = _G.CoreEx
local ObjectManager = _Core.ObjectManager
local EventManager = _Core.EventManager
local Input = _Core.Input
local Events = _Core.Enums.Events
local Player = ObjectManager.Player
local SpellSlots = _Core.Enums.SpellSlots
local SpellStates = _Core.Enums.SpellStates
local Game = _Core.Game
local _Q = SpellSlots.Q

local function IsReady(spellslot)
    return Player:GetSpellState(spellslot) == SpellStates.Ready
end

local Q_Blocked_Until = 0
local function Q_Logic()
    if IsReady(_Q) then
        local tick = Game:GetTime() * 1000
        if Q_Blocked_Until > tick then return end
        local timeSinceLastAttack = tick - Orb.Data.LastAttack.Time * 1000
        if (timeSinceLastAttack < 250) then
            local attackedUnit = Orb.Data.LastAttack.Target
            if Orb:IsValidAutoAttackTarget(attackedUnit) then
                Q_Blocked_Until = tick + 250
                delay(250 - timeSinceLastAttack + Player.AttackCastDelay*1000 + 50, function ()
                    Input.Cast(_Q)
                    Orb.LastAttack.Tick = 0
                end)
            end
        end
    end
end

local function OnTick()
    if (Orb.Mode.Combo) then
        Q_Logic()
    end
end

function OnLoad()
    if Player.CharName == "Ashe" then
        Orb.Load()
        EventManager.RegisterCallback(Events.OnTick, OnTick)
        return true
    end
    return false
end
