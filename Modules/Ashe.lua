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



local function OnPostAttack()
    if (IsReady(_Q)) then
        Input.Cast(_Q)
    end
end

function OnLoad()
    if Player.CharName == "Ashe" then
        Orb.Load()
        EventManager.RegisterCallback(Events.OnPostAttack, OnPostAttack)
        return true
    end
    return false
end
