require("common.log")
module("movpred", package.seeall, log.setup)

local _CoreEx = _G.CoreEx
local EventManager = _CoreEx.EventManager
local Events = _CoreEx.Enums.Events
local Renderer = _CoreEx.Renderer
local Player = _CoreEx.ObjectManager.Player
local Vector = _CoreEx.Geometry.Vector

function OnTick()

end


function OnDraw()
    local rad = Player.Orientation.y
    local X = rad >= 0 and Player.Position.x+math.cos(rad) or Player.Position.x-math.cos(rad)
    local Z = Player.Position.z - math.sin(rad)
    local Vec = Vector(X,Player.Position.y,Z)
    Renderer.DrawCircle3D(Player.Position,Player.BoundingRadius,20,1,0xFFFFFFFF)
    Renderer.DrawCircle3D(Player.Position:Extended(Vec, 100),Player.BoundingRadius + 1,20,1,0xFFF00FFF)
    Renderer.DrawLine3D(Player.Position, Player.Position:Extended(Vec, 100)  ,1,0xFFFFFFFF)
end

function OnLoad()
    EventManager.RegisterCallback(Events.OnDraw, OnDraw)
    EventManager.RegisterCallback(Events.OnTick, OnTick)
    return true
end