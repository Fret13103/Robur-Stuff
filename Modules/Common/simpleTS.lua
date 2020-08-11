require("common.log")
module("simpleTS", package.seeall, log.setup)

local _Core = _G.CoreEx
local ObjectManager = _Core.ObjectManager
local Player = ObjectManager.Player
local BuffTypes = _Core.Enums.BuffTypes
local Renderer = _Core.Renderer

local ts = {}

ts.Priority = {
    LowestHealth = 1,
    LowestMaxHealth = 2,
    LowestArmor = 3,
    LowestMagicResist = 4,
    Closest = 5,
    CloseToMouse = 6,
    MostAD = 7,
    MostAP = 8
}

local function HasBuffType(unit,buffType)
    local ai = unit.AsAI
    if ai.IsValid then
        for i = 0, ai.BuffCount do
            local buff = ai:GetBuff(i)
            if buff and buff.IsValid and buff.BuffType == buffType then
                return true
            end
        end
    end
    return false
end

function ts:GetTarget(range, mode, filterBuffs)
    if mode == nil then mode = ts.Priority.LowestHealth end
    if filterBuffs == nil then filterBuffs = false end
    local enemies = ObjectManager.Get("enemy", "heroes")
    local tempHero = nil
    for _, obj in pairs(enemies) do
        local hero = obj.AsHero
        if hero and hero.IsVisible and hero.IsAttackableUnit and hero.Health > 0 and Player.Position:Distance(hero.Position) < range + Player.BoundingRadius + hero.BoundingRadius then
            local NEXT = false
            if filterBuffs then
                if HasBuffType(hero,BuffTypes.Invulnerability) or hero.IsDodgingMissiles then
                    NEXT = true
                end
            end
            if not NEXT then
                if mode == ts.Priority.LowestHealth then
                    if tempHero == nil or hero.Health < tempHero.Health then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.LowestMaxHealth then
                    if tempHero == nil or hero.MaxHealth < tempHero.MaxHealth then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.LowestArmor then
                    if tempHero == nil or hero.Armor  < tempHero.Armor  then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.LowestMagicResist then
                    if tempHero == nil or hero.SpellBlock  < tempHero.SpellBlock  then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.Closest then
                    local playerPos = Player.Position
                    if tempHero == nil or playerPos:Distance(hero.Position)  < playerPos:Distance(hero.Position)  then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.CloseToMouse then
                    local mousePos = Renderer:GetMousePos()
                    if tempHero == nil or mousePos:Distance(hero.Position)  < mousePos:Distance(hero.Position)  then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.MostAD then
                    if tempHero == nil or hero.TotalAD  > tempHero.TotalAD  then
                        tempHero = hero
                    end
                elseif mode == ts.Priority.MostAP then
                    if tempHero == nil or hero.TotalAP  > tempHero.TotalAP  then
                        tempHero = hero
                    end
                end
            end
        end
    end
    return tempHero
end

return ts