local Orb = require("lol/Modules/Common/Orb")

function OnLoad()
    Orb.Load()
    Orb.Setting.Drawing.BoundingRadius.EnemyMinion.Active = false
    return true
end