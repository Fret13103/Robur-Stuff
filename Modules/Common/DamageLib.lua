require("common.log")
module("dmgLib", package.seeall, log.setup)

local _Core = _G.CoreEx
local ObjectManager = _Core.ObjectManager
local EventManager = _Core.EventManager
local Renderer = _Core.Renderer
local Game = _Core.Game
local Input = _Core.Input
local Events = _Core.Enums.Events
local ItemSlots = _Core.Enums.ItemSlots
local SpellSlots = _Core.Enums.SpellSlots
local BuffTypes = _Core.Enums.BuffTypes
local DamageTypes = _Core.Enums.DamageTypes
local Player = ObjectManager.Player

local Epsilon = 0.00001 -- does lua have no float comparision ?

local _Q = SpellSlots.Q
local _W = SpellSlots.W
local _E = SpellSlots.E
local _R = SpellSlots.R

local Items ={
    Dorans_Shield = 1054,
}

local DmgLib = {}

---@param str string
---@param ending string
---@return boolean
function string.ends(str, ending)
     return ending == "" or str:sub(-#ending) == ending
end

---@param table table
---@param value string
---@return boolean
function table.contains(table, value)
    return table[value] ~= nil
end


---@param unit AIBaseClient
---@return number
function GetHealthPercent(unit)
    return 100 * unit.Health / unit.MaxHealth
end

---@param unit AIBaseClient
---@return boolean
function IsCritting(unit)
    return math.abs(unit.CritChance - 1) < 0.001
end

---@param unit AIBaseClient
---@param checkCrit boolean
---@return number
function GetCritMultiplier(unit, checkCrit)
    local crit = 1 -- todo Item infinity edge
    checkCrit = checkCrit or false
    if not checkCrit then
        return crit + 1
    end
    if IsCritting(unit) then
        return crit + 1
    end
    return 1
end


---@param name string
---@return AIBaseClient/nil
function GetBuddy(name)
    local buddys = ObjectManager.Get("ally", "heroes")
    for _, obj in pairs(buddys) do
        local buddy = obj.AsHero
        if buddy and buddy.CharName == name then
            return buddy
        end
    end
    return nil
end

---@param unit AIBaseClient
---@param itemId number
---@return number
function GetItemSlot(unit, itemId)
    for i = SpellSlots.Item1, SpellSlots.Trinket do
        -- todo GetItemSlot
    end
    return 0
end

---@param unit AIBaseClient
---@param buffName string
---@return BuffInst/nil
function GetBuffData(unit, buffName)
    for i = 0, unit.BuffCount do
        local buff = unit.GetBuff(i)
        if buff and buff.Name == buffName and buff.Count > 0 then
            return buff
        end
    end
    return nil
end

---@param unit AIBaseClient
---@param buffName string
---@return boolean
function HaveBuff(unit, buffName)
    return GetBuffData(unit, buffName) ~= nil
end

---@param unit AIBaseClient
---@param buffName string
---@return number
function GetBuffCount(unit, buffName)
    local buff = GetBuffData(unit, buffName)
    return buff and buff.Count or 0
end

---@param spellSlot number
---@param spellName string
---@return boolean
function HaveSpell(spellSlot, spellName)
    return Player:GetSpell(spellSlot).Name == spellName
end

---@param unit AIBaseClient
---@param delay number
---@return boolean
---HasPoison wierd 0.141 delay
function IsPoisoned(unit, delay)
    if delay == nil then delay = 0 else delay = delay/1000 end
    local time = Game.GetTime()
    for i = 0, unit.BuffCount do
        local buff = unit.GetBuff(i)
        if buff and buff.BuffType == BuffTypes.Poison and time + delay > buff.EndTime then
            return true
        end
    end
    return false
end

local List_SiegeMinion = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
local List_NormalMinion = {"Red_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Wizard", "Blue_Minion_Basic"}
---@param source AIBaseClient
---@param target AIBaseClient
---@param amount number
---@param damageType Enum_DamageTypes
function PassivePercentMod(source, target, amount, damageType)
    if source.IsTurret then
        if table.contains(List_SiegeMinion, target.CharName) then
            amount = amount * 0.7
        elseif table.contains(List_NormalMinion, target.CharName) then
            amount = amount * 1.14285714285714
        end
    end
    return 1
end


local DamageReductionTable = {
    ["Braum"] =     {buff = "BraumShieldRaise",         amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpell(_E).Level] end},
    ["Urgot"] =     {buff = "urgotswapdef",             amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpell(_R).Level] end},
    ["Alistar"] =   {buff = "Ferocious Howl",           amount = function(target) return ({0.55, 0.65, 0.75})[target:GetSpell(_R).Level] end},
    ["Galio"] =     {buff = "GalioIdolOfDurand",        amount = function(target) return 0.5 end},
    ["Garen"] =     {buff = "GarenW",                   amount = function(target) return 0.3 end},
    ["Gragas"] =    {buff = "GragasWSelf",              amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpell(_W).Level] + 0.04 * target.TotalAP / 100 end},
    ["Annie"] =     {buff = "MoltenShield",             amount = function(target) return 1 - ({0.10,0.13,0.16,0.19,0.22})[target:GetSpell(_E).Level] end},
    ["Malzahar"] =  {buff = "malzaharpassiveshield",    amount = function(target) return 0.9 end}
}
local AttackPassive = {
    ["Aatrox"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "AatroxWPower") and HaveBuff(source, "AatroxWONHPowerBuff") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Akali"] = {
        getDamage = function(source, target)
            local raw = (0.06 + math.abs(source.TotalAP / 100)* 0.16667) * source.TotalAD
            return DmgLib:CalcMagicalDamage(source, target, raw)
        end,
        getDamage = function(source, target)
            if target.HaveBuff(target, "AkaliMota") then
                return DmgLib:GetDamage("Q", target, source, 1)
            end
        end},
    ["Alistar"] = {
        getDamage = function(source, target)
            if HaveBuff(source,"alistartrample") then
                local raw = 40 + source.Level* 10 + 0.1 * source.TotalAP
                return DmgLib:CalcMagicalDamage(source, target, raw)
            end
        end},
    ["Ashe"] = {
        getDamage = function(source, target)
            if HaveBuff(target,"ashepassiveslow") then
                local raw = source.TotalAD * (0.1 + (source.CritChance * (1 + source.CritDamageMultiplier)))
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end,
        getDamage = function(source, target)
            if HaveBuff(source, "asheqattack") then
                return DmgLib:GetDamage("Q",target)
            end
        end},
    ["Bard"] = {
        getDamage = function(source, target)
            if (GetBuffCount(source, "bardpspiritammocount") > 0) then
                local buffCount = GetBuffCount(source, "bardpdisplaychimecount")
                local b = ({30, 55, 80, 110, 140, 175, 210, 245, 280, 315, 345, 375, 400, 425, 445, 465})[math.min(buffCount / 10,15)]
                local raw = b + 0.3 * source.TotalAP
                if buffCount > 150 then
                    raw = raw + math.floor((buffCount - 150) / 5 + 0.5) * 20
                end
                return DmgLib:CalcMagicalDamage(source, target, raw)
            end
        end},
    ["Blitzcrank"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "PowerFist") then
                return DmgLib:GetDamage("E",target)
            end
        end},
    ["Braum"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "braummarkstunreduction") then
                local raw = 6.4 + (1.6 * source.Level)
                return DmgLib:CalcMagicalDamage(source, target, raw)
            end
        end},
    ["Caitlyn"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "caitlynheadshot") then
                local raw = 1.5 * (source.BaseAttackDamage + source.FlatPhysicalDamageMod)
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end},
    ["Camille"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "camiller") then
                return DmgLib:GetDamage("R", target)
            end
        end},
    ["ChoGath"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "VorpalSpikes") then
                return DmgLib:GetDamage("E", target)
            end
        end},
    ["Darius"] = {
        getDamage = function(source, target)
            local raw = ((9 + source.Level + (source.FlatPhysicalDamageMod * 0.3)) * math.min(GetBuffCount(target, "dariushemo") + 1, 5)) * target.IsMinion and 0.25 or 1
            return DmgLib:CalcPhysicalDamage(source, target, raw)
        end,
        getDamage = function(source, target)
            if HaveBuff(source, "DariusNoxianTacticsONH") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Diana"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "dianaarcready") then
                local raw = 15 + source.Level < 6 and 5 or source-Level < 11 and 10 or source.Level < 14 and 15 or source.Level < 16 and 20 or 25 * source.Level + source.TotalAP * 0.8
                DmgLib:CalcMagicalDamage(source, target, raw)
            end
        end},
    ["DrMundo"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "Masochism") then
                return DmgLib:GetDamage("E", target)
            end
        end},
    ["Draven"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "DravenSpinning") then
                local raw = 0.45 * (source.BaseAttackDamage + source.FlatPhysicalDamageMod)
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end},
    ["Ekko"] = {
        getDamage = function(source, target)
            if GetBuffCount(target, "EkkoStacks") == 2 then
                local raw = 10 + source.Level * 10 + source.TotalAP * 0.8
                return DmgLib:CalcMagicalDamage(source, target, raw)
            end
        end,
        getDamage = function(source, target)
            if GetHealthPercent(target) < 30 then
                local raw = (target.MaxHealth - target.Health) * (5 + math.floor(source.TotalAP/100) * 2.2) / 100
                local dmg = DmgLib:CalcMagicalDamage(source, target, raw)
                if not target.IsHero then dmg = math.min(150, dmg) end
                return dmg
            end
        end},
    ["Fizz"] = {
        getDamage = function(source, target)
            if source:GetSpell(_W).Level > 0 then
                 return DmgLib:GetDamage("W", target) / 6
            end
        end,
        getDamage = function(source, target)
            if HaveBuff(source, "FizzSeastonePassive") then
                 return DmgLib:GetDamage("W", target)
            end
        end},
    ["Garen"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "GarenQ") then
                return DmgLib:GetDamage("Q", target)
            end
        end},
    ["Gnar"] = {
        getDamage = function(source, target)
            if GetBuffCount(target, "gnarwproc") == 2 then
                 return DmgLib:GetDamage("W", target)
            end
        end},
    ["Gragas"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "gragaswattackbuff") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Graves"] = {
        getDamage = function(source, target)
            local raw = ((72 + 3* source.Level)/100) *  DmgLib:CalcPhysicalDamage(source, target, source.TotalAD) -  DmgLib:CalcPhysicalDamage(source, target, source.TotalAD)
            return raw
        end},
    ["Hecarim"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "hecarimrampspeed") then
                return DmgLib:GetDamage("E", target)
            end
        end},
    ["Illaoi"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "IllaoiW") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Irelia"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "ireliahitenstylecharged") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Ivern"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "ivernwpassive") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["JarvanIV"] = {
        getDamage = function(source, target)
            if not HaveBuff(target, "jarvanivmartialcadencecheck") then
                local raw = math.min(target.Health * 0.1, 400)
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end},
    ["Jax"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "JaxEmpowerTwo") then
                return DmgLib:GetDamage("W", target)
            end
        end},
    ["Jayce"] = {
        getDamage = function(source, target)
            if IsCritting(source) and not HaveBuff(source, "jaycehypercharge") then
                local raw = GetCritMultiplier(source) * source.TotalAD
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end,
        getDamage = function(source, target)
            if HaveBuff(source, "jaycehypercharge") then
                return DmgLib:GetDamage("W", target, 1)
            end
        end,
        getDamage = function(source, target)
            if HaveBuff(source, "jaycepassivemeleeattack") then
                local dmg = 1.4 * source.TotalAD
                return dmg
            end
        end},
    ["Jhin"] = {
        getDamage = function(source, target)
            if HaveBuff(source, "jhinpassiveattackbuff") then
                local raw = source.TotalAD * 0.5 + (target.MaxHealth - target.Health) * ({0.15, 0.2, 0.25})[math.min(3,source.Level / 5)]
                return DmgLib:CalcPhysicalDamage(source, target, raw)
            end
        end},


    --- Any Champ can Proc it
    ["AnyChampion"] = {getDamage = function(source, target)
            if GetBuffCount(target, "braummark") == 3 then
            -- todo BuffInst.Caster
            local braumLevel = GetBuddy("Braum").Level or 0
            local raw = 32 + (8 * braumLevel)
            return DmgLib:CalcMagicalDamage(source, target, raw)
        end
    end},


    [""] = {
        getDamage = function(source, target)

        end},

    [""] = {
        getDamage = function(source, target)

        end,
        getDamage = function(source, target)

        end},
}

---@param source AIBaseClient
---@param target AIBaseClient
---@return number
function PassiveFlatMod(source, target)
    --todo
    return 0
end

---@param source AIBaseClient
---@param target AIBaseClient
---@param amount number
---@param damageType Enum_DamageTypes
---@return number
function DamageReductionMod(source, target, amount, damageType)
    if source.IsHero then
        if GetBuffCount(source, "Exhaust") > 0 then
            amount = amount * 0.6
        end
    end
    if target.IsHero then
        local count = GetBuffCount(target, "MasteryWardenOfTheDawn")
        if count > 0 then
            amount = amount * (1 - (0.06 * count))
        end
        local drt = DamageReductionTable
        if drt[target.CharName] then
            if HaveBuff(target, drt[target.CharName].buff) then
                amount = amount * drt[target.CharName].amount(target)
            end
        end
        if target.CharName == "Maokai" and source.IsTurret and HaveBuff(target, "MaokaiDrainDefense") then
            amount = amount * 0.8
        end
        if target.CharName == "MasterYi" and HaveBuff(target, "Meditate") then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpell(_W).Level] / (source.IsTurret and 2 or 1)
        end
    end
    if GetItemSlot(target, Items.Dorans_Shield) > 0 then
        amount = amount - 8
    end
    if target.CharName == "Kassadin" and DamageType == damageType.Magical then
        amount = amount * 0.86
    end
    return amount
end

---@param source AIBaseClient
---@param target AIBaseClient
---@param amount number
---@return number
function DmgLib:CalcPhysicalDamage(source, target, amount)
    local PercentArmorPen = source.PercentArmorPen
    local FlatArmorPen = source.FlatArmorPen
    local PercentBonusArmorPen = source.PercentBonusArmorPen
    if source.IsMinion then
        PercentArmorPen = 1
        FlatArmorPen = 0
        PercentBonusArmorPen = 1
    elseif source.IsTurret then
        FlatArmorPen = 0
        PercentBonusArmorPen = 1
        if source.CharName:find("3") or source.CharName:find("4") then
            PercentArmorPen = 0.25
        else
            PercentArmorPen = 0.7
        end
        if target.IsMinion then
            amount = amount*1.25
            if string.ends(target.CharName, "MinionSiege") then
                amount = amount*0.7
            end
            return amount
        end
    end
    local armor = target.Armor
    local bonusArmor = target.BonusArmor
    local val = 0
    if armor < 0 then
        val = 2 - 100 / (100 - armor)
    elseif armor * PercentArmorPen - bonusArmor*(1-PercentBonusArmorPen) - FlatArmorPen < 0 then
        val = 1
    else
        val = 100 / (100 + armor*PercentArmorPen - bonusArmor*(1-PercentBonusArmorPen) - FlatArmorPen)
    end
    return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, val) * amount, DamageTypes.Physical)))
end

---@param source AIBaseClient
---@param target AIBaseClient
---@param amount number
---@return number
function DmgLib:CalcMagicalDamage(source, target, amount)
    local magicResist = target.SpellBlock
    local val = 0
    if magicResist < 0 then
        val = 2 - 100 / (100 -magicResist)
    elseif magicResist * source.PercentMagicPen - source.FlatMagicPen < 0 then
        val = 1
    else
        val = 100 / (100 + magicResist * source.PercentMagicPen - source.FlatMagicPen)
    end
    return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, val) * amount, damageType.Magical)))
end

---@param source AIBaseClient
---@param target AIBaseClient
---@param amountMagical number
---@param amountMagical number
---@param magic number
---@param physical number
---@param trueDmg number
---@return number
function DmgLib:CalcMixedDamage(source, target, amountPhysical, amountMagical, magic, physical, trueDmg)
    magic = magic or 50
    physical = physical or 50
    trueDmg = trueDmg or 0
    local m = DmgLib:CalcMagicalDamage(source, target, (amountMagical * magic) / 100)
    local p = DmgLib:CalcMagicalDamage(source, target, (amountPhysical * physical) / 100)
    local pfm = PassiveFlatMod(source, target)
    local t = (amountMagical * trueDmg) / 100
    return m + p + pfm + t
end

---@param spell string
---@param target AIBaseClient
---@param source AIBaseClient
---@param stage number
---@param level number
---@param includePassive boolean
---@return number
function DmgLib:GetDamage(spell, target, source, stage, level, includePassive)
    source = source or Player
    stage = stage or 1
    stage = math.min(stage, 4)
    includePassive = includePassive and includePassive or true
    onHit = onHit or false
    local result = source.TotalAD
    local k = 1
    if spell == "AA" then
        if source.CharName == "Kalista" then k = 0.9 end
        -- if kled and SpellSlot.Q Name == "KledRiderQ" k = 0.8
        if not includePassive then
            return DmgLib:CalcPhysicalDamage(source, target, result*k)
        end
        local reduction = 0
        if source.IsHero then
            --SupportItems
            --Relic Shield
            --Targon's Brace
             --Face of the Mountain
        end
        --ChampionPassiveDamage
        local name = source.CharName
        if AttackPassive[name] then
            for i, f in ipairs(AttackPassive[name]) do
                result = result + f.getDamage(source, target) or 0
            end
        end

        if source.IsHero and source.CharName == "Corki" then
            return DmgLib:CalcMixedDamage(source, target, (result-reduction)*k, result*k)
        end
        return DmgLib:CalcPhysicalDamage(source, target, (result - reduction)*k + PassiveFlatMod(source, target));
    end
    return 0
end

return DmgLib