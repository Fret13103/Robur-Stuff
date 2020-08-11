return

require("common.log")
module("MTrist", package.seeall, log.setup)

local _SDK = _G.CoreEx
local ObjManager, EventManager, Input, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Input, _SDK.Enums, _SDK.Game
local SpellSlots, SpellStates = Enums.SpellSlots, Enums.SpellStates 
local Player = ObjManager.Player

local function getRdmg(target)
	local tristR = {300, 400, 500}
	local dmgR = tristR[Player:GetSpell(SpellSlots.R).Level]
	return (dmgR + Player.TotalAP) * (100.0 / (100 + Player.FlatMagicReduction ) )
end

local function UseItems(target)	
	for i=SpellSlots.Item1, SpellSlots.Item6 do
		local _item = Player:GetSpell(i)
		if _item ~= nil then
			local itemInfo = _item.Name

			if itemInfo == "ItemSwordOfFeastAndFamine" or itemInfo == "BilgewaterCutlass" then
				if Player:GetSpellState(i) == SpellStates.Ready then
					Input.Cast(i, target)
				end
				break
			end
		end
	end
end

local function Combo(target)
	if Player:GetSpellState(SpellSlots.Q) == SpellStates.Ready then
		Input.Cast(SpellSlots.Q)
	elseif Player:GetSpellState(SpellSlots.E) == SpellStates.Ready then
		Input.Cast(SpellSlots.E, target)
	end
end

local function AutoR()
	local enemies = ObjManager.Get("enemy", "heroes")
	local myPos, myRange = Player.Position, (Player.AttackRange + Player.BoundingRadius)	
	if Player:GetSpellState(SpellSlots.R) ~= SpellStates.Ready then return end

	for handle, obj in pairs(enemies) do        
		local hero = obj.AsHero        
		if hero and hero.IsTargetable then
			local dist = myPos:Distance(hero.Position)
			if dist <= myRange and getRdmg(hero) > (hero.Health) then				
				Input.Cast(SpellSlots.R, hero) -- R KS        
			elseif dist <= 200 then				
				Input.Cast(SpellSlots.R, hero) -- Anti-Gap Closer
			end
		end		
	end	
end 

local function OnTick()			
	local target = _G.OrbActive and _G.OrbTarget

	AutoR()
	if target then 
		Combo(target)
		UseItems(target)
	end
end

function OnLoad() 
	if Player.CharName == "Tristana" then
		EventManager.RegisterCallback(Enums.Events.OnTick, OnTick)
		Game.PrintChat("MTristana Loaded !")
		return true
	end
end

