
Core = _G.CoreEx
EventManager = Core.EventManager
Enums = Core.Enums

local KeysActive = {}

---@param key number
---@param Mode any
function SetKeyMode(key, Mode)
    ---@type Enum_Events
    _G.CoreEx.EventManager.RegisterCallback(Enums.Events.OnKeyDown, function(keycode, _, _)
        if keycode == key then
            KeysActive[Mode] = true
        end
    end)
    _G.CoreEx.EventManager.RegisterCallback(Enums.Events.OnKeyUp,   function(keycode, _, _)
        if keycode == key then
            KeysActive[Mode] = false
        end
    end)
end

---@param Mode any
---@return boolean
function IsModeActive(Mode)
    local active = KeysActive[Mode]
    if active then return true else return false end
end
