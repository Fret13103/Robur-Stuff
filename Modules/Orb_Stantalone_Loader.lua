local Orb = require("lol/Modules/Common/Orb")

function OnLoad()
    Orb.Setting.Drawing.BoundingRadius.EnemyMinion.Active = false
    return true
end