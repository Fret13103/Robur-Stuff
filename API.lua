---@alias Pointer integer
---@alias Handle_t integer
---@alias integer number
---@alias bool boolean
---@type fun():nil
inject_process_pe_infect_C = "inject_process_pe_infect_C"

---@type fun():nil
luaconsole_create_C = "luaconsole_create_C"

---@type fun():number
asmcall_pushfloat_fstp_x87_C = "asmcall_pushfloat_fstp_x87_C()"

---@type string
_NAME = "Name Of The Current Module"

---@class ffi
ffi = require("ffi")

---@class utils
utils = require("common.utils")

---@type fun()
Class = "oo.lua class. Supports :new() and :extend()"


---@class nuklear
---@field NK_WINDOW_BORDER number
---@field NK_WINDOW_MINIMIZABLE number
---@field NK_WINDOW_MOVABLE number
---@field NK_WINDOW_TITLE number
---@field add_overlay function
---@field add_widget function
---@field nk_begin function
---@field nk_button_label function
---@field nk_end function
---@field nk_init function
---@field nk_layout_row_dynamic function
---@field nk_option_label function
---@field nk_property_int function
---@field nk_slider_float function
nuklear = require("lol.nuklear")

---@type fun():nil
nk_stroke_line_C = "nk_stroke_line_C" 
---@type fun():nil
nk_draw_text_C = "nk_drawext_C"
---@type fun():nil
nk_stroke_rect_C = "nk_stroke_rect_C" 
---@type fun():nil
nk_fill_rect_C = "nk_fill_rect_C"

---@class winapi
winapi = require("utils.winapi")

---@type fun():nil
reload = "reload"

--[[
     █████  ███████ ███    ███  ██████  █████  ██      ██ 
    ██   ██ ██      ████  ████ ██      ██   ██ ██      ██ 
    ███████ ███████ ██ ████ ██ ██      ███████ ██      ██ 
    ██   ██      ██ ██  ██  ██ ██      ██   ██ ██      ██ 
    ██   ██ ███████ ██      ██  ██████ ██   ██ ███████ ███████ 
]]
---@class asmcall
---@field w64 fun(address: integer, var_args: any):any
---@field cdecl fun(address: integer, var_args: any):any
---@field stdcall fun(address: integer, var_args: any):any
---@field fastcall fun(address: integer, registers: table, var_args: any):any @registers: {eax=1, ecx=0xdeadbeef}
asmcall = "This module provides functions to call any kind of assembler functions"


--[[
    ███████ ██    ██ ███████ ███    ██ ████████ 
    ██      ██    ██ ██      ████   ██    ██    
    █████   ██    ██ █████   ██ ██  ██    ██ 
    ██       ██  ██  ██      ██  ██ ██    ██ 
    ███████   ████   ███████ ██   ████    ██ 
]]
---@class EVENT
---@field eid string @EventID
---@field emsg number @EventMsg
EVENT = "The current event that caused the execution of your code"

---@class event
---@field ONTICK string
---@field CONSOLE string
---@field USERINPUT string
---@field KEYUP string
---@field MOUSE string
---@field KEYBOARD string
---@field MOUSE_WHEEL_UP string
---@field MOUSE_WHEEL_DOWN string
event = "This module deals with the asynchronous operation of your code and fires your code on certain callback conditions"

---@type fun(event_id: string):boolean
isEvent = "Check If Event Exists"
---@type fun(event_id: string):string @returns EventID
createEvent = "Creates a New Event"
---@type fun(event_id: string):nil
deleteEvent = "Removes an Existing Event"
---@type fun(event_id: string, event_msg: string, args: table, no_error: boolean):nil
fire = "Fires an Event"
---@type fun(eid: string | nil, detailed: boolean | nil):nil
debug = "Debugs an Event"
---@type fun(eid: string):nil
debugEvent = "Debugs an Event"
---@type fun(eids: string | string[], callback: function):nil
register = "Registers a Listener"
---@type fun(callback: function):nil
unregister = "Unregisters a Listener"
---@type fun(time_ms: integer, cb: function, var_args: any):nil
delay = "No-Lock Delayed Execution"
---@type fun(time_ms: integer, cb: function, var_args: any):nil
timer = "Periodic Execution"
---@type fun():integer
getCurrentMillis = "Miliseconds since Robur Startup"

--[[
     ██████  █████  ██    ██ ███████ 
    ██      ██   ██ ██    ██ ██      
    ██      ███████ ██    ██ █████ 
    ██      ██   ██  ██  ██  ██    
     ██████ ██   ██   ████   ███████ 
]]
---@class cave
---@field enable fun(cave: number):nil
---@field disable fun(cave: number):nil
---@field eject fun(cave: number):nil
---@field intercept_pre fun(name: string, address: number, hook: function, thread: any, uservalue: any) @call a hook before the original function
---@field intercept_return fun(name: string, address: number, hook: function, thread: any, uservalue: any, args: any) @call a hook after the original function
cave = "This module offers functions to intercept functions with codecaves"

--[[
    ██       ██████   ██████ 
    ██      ██    ██ ██      
    ██      ██    ██ ██   ███ 
    ██      ██    ██ ██    ██ 
    ███████  ██████   ██████  
]]
--[[
    [Usage]:

    require("common.log")
    module("modname", package.seeall, log.setup, ...)
    clean.module("modname", clean.seeall, log.setup, ...)
]]
---@class log
---@field LOG_DEBUG number
---@field LOG_INFO number
---@field LOG_WARN number
---@field LOG_ERROR number
---@field LOG_FATAL number
---@field setup fun(module_id: string) @helper function to create local logging shortcuts (DEBUG, INFO, ...) passed as Parameter To 'module'.
---@field setLevel fun(level: integer) @level: LOG_DEBUG | LOG_INFO | LOG_WARN | LOG_ERROR | LOG_FATAL
---@field setDebug fun():nil
---@field setInfo fun():nil
---@field setWarn fun():nil
---@field setError fun():nil
---@field setFatal fun():nil
log = "Common logging module. Only Shows Messages Above Current Logging Level."

---@type fun(level: integer, mod: any, format: string, var_args:any)
stacktrace = "Prints the current lua stack trace."

---@type fun(level: integer, module: string, format: string, var_args:any)
LOG = "Logger main function. Any log message has to pass through this function."
---@type fun(format: string, var_args:any)
DEBUG = "Log a Debug Message"
---@type fun(format: string, var_args:any)
INFO = "Log an Information Message"
---@type fun(format: string, var_args:any)
WARN = "Log a Warning Message"
---@type fun(format: string, var_args:any)
ERROR = "Log an Error Message"
---@type fun(format: string, var_args:any)
FATAL = "Log a Fatal Error Message"

--[[
    ██    ██ ████████ ██ ██      ███████ 
    ██    ██    ██    ██ ██      ██      
    ██    ██    ██    ██ ██      ███████ 
    ██    ██    ██    ██ ██           ██ 
     ██████     ██    ██ ███████ ███████        
]]

---@type fun(key: string):any
cfg = "Returns a config value without raising strict errors on non-defined variables"
---@type fun(md5sum: string, expected: string):boolean
checkFileMd5 = "checks the message digest of a file, and displays error prompt on mismatch"
---@type fun(path: string):boolean
io.exists = "Returns if a file exists"
---@type fun(path: string, mode: string, absolute: boolean):string
io.readFile = "reads a whole file and returns the contents as a big string"
---@type fun(path: string, data: any):nil
io.writeFile = "writes a file. Warning: overwrites existing content"

---@type fun(ptr: integer, index: integer | nil):any
readByte = "reads a byte (8 bit unsigned integer) from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeByte = "writes a byte (8 bit unsigned integer) to memory"
---@type fun(ptr: integer, index: integer | nil):any
readUInt16 = "reads a UInt16 from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeUInt16 = "writes a UInt16 to memory"
---@type fun(ptr: integer, index: integer | nil):any
readInt16 = "reads a Int16 from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeInt16 = "writes a Int16 to memory"
---@type fun(ptr: integer, index: integer | nil):any
readUInt32 = "reads a UInt32 from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeUInt32 = "writes a UInt32 to memory"
---@type fun(ptr: integer, index: integer | nil):any
readInt32 = "reads a Int32 from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeInt32 = "writes a Int32 to memory"
---@type fun(ptr: integer, index: integer | nil):any
readFloat32 = "reads a Float32 from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeFloat32 = "writes a Float32 to memory"
---@type fun(ptr: integer, index: integer | nil):any
readDouble = "reads a Double from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writeDouble = "writes a Double to memory"
---@type fun(ptr: integer, index: integer | nil):any
readPointer = "reads a Pointer from memory"
---@type fun(value: integer, ptr: integer, index: integer | nil):any
writePointer = "writes a Pointer to memory"
---@type fun(ptr: integer, index: integer | nil):any
readBool = "reads a Bool from memory"
---@type fun(value: boolean, ptr: integer, index: integer | nil):any
writeBool = "writes a Bool to memory"

---@type fun(ptr: integer):string
str = "reads a string from process memory (num ptr or ctype), like ffi.string"
---@type fun(ptr: integer):string
wstr = "reads a wide char string from memory, converted to a Lua string"
---@type fun(format:string, var_args: any):string
printf = "a shortcut to print(string.format(fmt, ...))"

---@type fun(arg: integer, offset: integer | nil):any
topointer = "converts arg (with optional offset) to cdata<void*>"
---@type fun(ptr: integer):any
isnull = "checks whether a pointer is NULL."
---@type fun(arg: integer, offset: integer | nil):any
ptrtonumber = "converts arg (with optional offset) to number"
---@type fun(arg: integer):any
ptrtostring = "converts pointer to a string, representing the address in hexadecimal format."
---@type fun(arg: integer):any
touserdata = "converts address to a userdata pointer"

---@type fun(var_args: table | number | string | boolean | nil):table
array_concat = "merge arrays (sequentially indexed tables, won't work for associative tables)"
---@type fun(var_args: table):table
array_merge = "merge arrays (associative tables)"

---@type fun(level: integer):integer
getCallerPos = "return position within caller."
---@type fun(level: integer):string
getCallerName = "return the name of a calling function."
---@type fun(check: table):nil @checkargs({arg3, "number"}, {arg1, "string,number", "something went wrong!"})
checkargs = "quickly check for and error() on wrong type or missing arguments"

---@type fun(moduleName: string)
printModule = "prints any functions and static vars of a module"

---@type fun(module: string, func: string, noerror: boolean | nil) @local value, err = getProcAddress("user32", "GetMessageA")
getProcAddress = "Returns the address of a given function within a library."
---@type fun(title: string, format:string, var_args: any):string
messageBox  = "shows a modal message box"
---@type fun(title: string, format:string, var_args: any):string
messageBoxError = "shows a modal message box with an error/stop icon"
---@type fun(table: table, mod: any):table
enumHelper = "A function that converts a table to a two-way mapping of keys and values."

--[[
    ██    ██ ███████ ███████ ██████  ██ ███    ██ ██████  ██    ██ ████████ 
    ██    ██ ██      ██      ██   ██ ██ ████   ██ ██   ██ ██    ██    ██    
    ██    ██ ███████ █████   ██████  ██ ██ ██  ██ ██████  ██    ██    ██ 
    ██    ██      ██ ██      ██   ██ ██ ██  ██ ██ ██      ██    ██    ██ 
     ██████  ███████ ███████ ██   ██ ██ ██   ████ ██       ██████     ██ 
]]
---@type fun():nil
startRecord = "Starts a user32 input recording"
---@type fun():nil
stopRecord = "Stops a user32 input recording"
---@type fun(name: string, realime:boolean):nil
saveRecord = "Saves a user32 input recording"
---@type fun(name: string, realime:boolean, cb: function):nil
playRecord = "Plays a user32 input recording"

---@type fun(data: string, emulate_keystrokes: boolean | nil):nil
play = "this function fakes key strokes"
---@type fun(ascii_code: integer, emulate_keystrokes: boolean | nil):nil
sendKey = "this function fakes key strokes"
---@type fun():nil
sendEsc = "sends the ESC key"
---@type fun():nil
sendEnter = "sends the enter key"
---@type fun():boolean
isCtl = "Returns if Ctrl Is Pressed"

_G.CoreEx = {}
_G.CoreEx.Enums = {}
_G.CoreEx.Geometry = {}

--[[
    ██    ██ ███████  ██████ ████████  ██████  ██████ 
    ██    ██ ██      ██         ██    ██    ██ ██   ██ 
    ██    ██ █████   ██         ██    ██    ██ ██████  
     ██  ██  ██      ██         ██    ██    ██ ██   ██ 
      ████   ███████  ██████    ██     ██████  ██   ██   
]]

---@class Vector
---@field x number
---@field y number
---@field z number
---@field AsArray fun(self: Vector):Pointer
---@field SetHeight fun(self: Vector, h: number | nil):nil 
---@field ToScreen fun(self: Vector):Vector
---@field ToMM fun(self: Vector):Vector
---@field Unpack fun(self: Vector):number, number, number
---@field LenSqr fun(self: Vector):number
---@field Len fun(self: Vector):number
---@field DistanceSqr fun(self: Vector, v: Vector|GameObject):number
---@field Distance fun(self: Vector, v:Vector|GameObject):number
---@field LineDistance fun(self: Vector, _segStart: Vector, _segEnd: Vector, onlyIfOnSegment:boolean):number
---@field Normalize fun(self: Vector):Vector
---@field Normalized fun(self: Vector):Vector
---@field Extended fun(self: Vector, to:Vector|GameObject, distance:number):Vector
---@field Center fun(self: Vector, v:Vector|GameObject):Vector
---@field CrossProduct fun(self: Vector, v:Vector|GameObject):Vector
---@field DotProduct fun(self: Vector, v:Vector|GameObject):number
---@field ProjectOn fun(self: Vector, _segStart:Vector|GameObject, _segEnd:Vector|GameObject):Vector
---@field Polar fun(self: Vector):number
---@field AngleBetween fun(self: Vector, _v1:Vector|GameObject, _v2:Vector|GameObject):number
---@field RotateX fun(self: Vector, phi: number):Vector
---@field RotateY fun(self: Vector, phi: number):Vector
---@field RotateZ fun(self: Vector, phi: number):Vector
---@field Rotate fun(self: Vector, phiX:number, phiY:number, phiZ:number):Vector
---@field Rotated fun(self: Vector, phiX:number, phiY:number, phiZ:number):Vector
---@field RotatedAroundPoint fun(self: Vector, p:Vector|GameObject, phiX:number, phiY:number, phiZ:number):Vector
---@field IsValid fun(self: Vector):boolean
---@field Perpendicular fun(self: number):Vector
---@field Perpendicular2 fun(self: number):Vector
---@field Absolute fun(self: number):Vector
---@field Draw fun(self: number, color: integer):void
---@field IsOnScreen fun(self: number):boolean
---@field IsWall fun(self: Vector) @NOT IMPLEMENTED (WIP)
---@field IsGrass fun(self: Vector) @NOT IMPLEMENTED (WIP)
---@field GetCollisionFlags fun(self: Vector) @NOT IMPLEMENTED (WIP)
---@field GetTerrainHeight fun(self: Vector) @NOT IMPLEMENTED (WIP)
local Vector
_G.CoreEx.Geometry.Vector = Vector

--[[
    ███████ ██████  ███████ ██      ██      
    ██      ██   ██ ██      ██      ██      
    ███████ ██████  █████   ██      ██      
         ██ ██      ██      ██      ██      
    ███████ ██      ███████ ███████ ███████                                         
]]
---@class SpellData
---@field IsValid boolean
---@field SpellFlags integer
---@field SpellAffectFlags integer
---@field SpellAffectFlags2 integer
---@field Name string
---@field AlternateName string
---@field MissileName string
---@field Level integer
---@field IsLearned boolean
---@field ToggleState integer
---@field Ammo number
---@field MaxAmmo number
---@field CooldownExpireTime number
---@field TotalCooldown number
---@field RemainingCooldown number
---@field NextAmmoRechargeTime number
---@field TotalAmmoRechargeTime number
---@field RemainingAmmoRechargeTime number
---@field ManaCost number
---@field DisplayRange number
---@field CastRange number
---@field CastRadius number
---@field CastRadius2 number
---@field LineWidth number
---@field LineDragLenght number
---@field ConeAngle number
---@field ConeRadius number
---@field MissileSpeed number
---@field MissileMinSpeed number
---@field MissileMaxSpeed number
---@field MissileAcceleration number
---@field IsInstant boolean
---@field IsDispellable boolean
local SpellData

---@class SpellCast
---@field Slot integer
---@field SpellData SpellData
---@field CastDelay number
---@field TotalDelay number
---@field StartPos Vector
---@field EndPos Vector
---@field Caster AIBaseClient
---@field Source AIBaseClient
---@field Target AttackableUnit
---@field StartTime number
---@field EndTime number
---@field CastEndTime number
---@field IsBasicAttack boolean
---@field IsBeingCast boolean
---@field IsBeingCharged boolean
---@field StoppedBeingCharged boolean
---@field SpellWasCast boolean

local SpellCast

--[[
    ██████  ██    ██ ███████ ███████     ██ ███    ██ ███████ ████████ 
    ██   ██ ██    ██ ██      ██          ██ ████   ██ ██         ██    
    ██████  ██    ██ █████   █████       ██ ██ ██  ██ ███████    ██    
    ██   ██ ██    ██ ██      ██          ██ ██  ██ ██      ██    ██    
    ██████   ██████  ██      ██          ██ ██   ████ ███████    ██    
]]
---@class BuffInst
---@field IsValid bool
---@field Name string
---@field Source AIBaseClient
---@field BuffType Enum_BuffTypes
---@field Count integer
---@field StartTime number
---@field EndTime number
---@field Duration number
---@field DurationLeft number
---@field IsCC bool
---@field IsNotDebuff bool
---@field IsFear bool
---@field IsRoot bool
---@field IsSilence bool
---@field IsSlow bool
---@field IsDisarm bool
local BuffInst

---@class Pathing
---@field Velocity Vector
---@field StartPos Vector
---@field EndPos Vector
---@field IsMoving boolean
---@field IsDashing boolean
---@field DashGravity number
---@field DashSpeed number
---@field CurrentWaypoint integer
---@field Waypoints Vector[]
local Pathing

--[[
     ██████   █████  ███    ███ ███████      ██████  ██████       ██ ███████  ██████ ████████ 
    ██       ██   ██ ████  ████ ██          ██    ██ ██   ██      ██ ██      ██         ██    
    ██   ███ ███████ ██ ████ ██ █████       ██    ██ ██████       ██ █████   ██         ██ 
    ██    ██ ██   ██ ██  ██  ██ ██          ██    ██ ██   ██ ██   ██ ██      ██         ██ 
     ██████  ██   ██ ██      ██ ███████      ██████  ██████   █████  ███████  ██████    ██ 
]]

---@class GameObject
---@field IsValid boolean
---@field Ptr Pointer
---@field Handle Handle_t
---@field IsMe boolean
---@field IsNeutral boolean
---@field IsAlly boolean
---@field IsEnemy boolean
---@field IsMonster boolean
---@field TeamId integer
---@field Name string
---@field IsOnScreen boolean
---@field IsDead boolean
---@field IsZombie boolean
---@field TypeFlags integer
---@field ClassData Pointer
---@field IsParticle boolean
---@field IsMissile boolean
---@field IsAttackableUnit boolean
---@field IsAI boolean
---@field IsMinion boolean
---@field IsHero boolean
---@field IsTurret boolean
---@field IsNexus boolean
---@field IsInhibitor boolean
---@field IsBarracks boolean
---@field IsStructure boolean
---@field IsShop boolean
---@field IsWard boolean
---@field AsAI AIBaseClient
---@field AsHero AIHeroClient
---@field AsTurret AITurretClient
---@field AsMinion AIMinionClient
---@field AsMissile MissileClient
---@field AsAttackableUnit AttackableUnit
---@field IsVisible boolean
---@field BoundingRadius number
---@field Distance fun(self: number, p2: Vector):number
---@field EdgeDistance fun(self: number, p2: Vector):number
---@field BBoxMin Vector
---@field BBoxMax Vector
---@field Position Vector
---@field Orientation Vector
---@field Orientation Vector
local GameObject

--[[
     █████  ████████ ████████  █████   ██████ ██   ██  █████  ██████  ██      ███████ 
    ██   ██    ██       ██    ██   ██ ██      ██  ██  ██   ██ ██   ██ ██      ██      
    ███████    ██       ██    ███████ ██      █████   ███████ ██████  ██      █████   
    ██   ██    ██       ██    ██   ██ ██      ██  ██  ██   ██ ██   ██ ██      ██      
    ██   ██    ██       ██    ██   ██  ██████ ██   ██ ██   ██ ██████  ███████ ███████
]]
---@class AttackableUnit : GameObject
---@field Health number
---@field MaxHealth number
---@field Mana number
---@field MaxMana number
---@field ShieldAll number
---@field ShieldAD number
---@field ShieldAP number
---@field FirstResource number
---@field FirstResourceMax number
---@field SecondResource number
---@field SecondResourceMax number
---@field IsTargetable boolean
---@field IsAlive boolean
local AttackableUnit

--[[
     █████  ██ ██████   █████  ███████ ███████ 
    ██   ██ ██ ██   ██ ██   ██ ██      ██      
    ███████ ██ ██████  ███████ ███████ █████   
    ██   ██ ██ ██   ██ ██   ██      ██ ██      
    ██   ██ ██ ██████  ██   ██ ███████ ███████  
]]
---@class AIBaseClient  : AttackableUnit
---@field CanMove boolean
---@field CanAttack boolean
---@field CanCast boolean
---@field IsImmovable boolean
---@field IsStealthed boolean
---@field IsTaunted boolean
---@field IsFeared boolean
---@field IsFleeing boolean
---@field IsSurpressed boolean
---@field IsAsleep boolean
---@field IsNearSighted boolean
---@field IsGhosted boolean
---@field IsCharmed boolean
---@field IsSlowed boolean
---@field IsGrounded boolean
---@field IsDodgingMissiles boolean
---@field PercentCooldownMod number
---@field PercentCooldownCapMod number
---@field FlatPhysicalDamageMod number
---@field PercentPhysicalDamageMod number
---@field PercentBonusPhysicalDamageMod number
---@field PercentBasePhysicalDamageMod number
---@field FlatMagicalDamageMod number
---@field PercentMagicalDamageMod number
---@field FlatMagicReduction number
---@field PercentMagicReduction number
---@field FlatCastRangeMod number
---@field BaseAttackDamage number
---@field FlatBaseAttackDamageMod number
---@field PercentBaseAttackDamageMod number
---@field BaseAbilityDamage number
---@field CritDamageMultiplier number
---@field DodgeChance number
---@field CritChance number
---@field Armor number
---@field BonusArmor number
---@field SpellBlock number
---@field BonusSpellBlock number
---@field HealthRegen number
---@field BaseHealthRegen number
---@field MoveSpeed number
---@field MoveSpeedBaseIncrease number
---@field AttackRange number
---@field FlatArmorPen number
---@field PhysicalLethality number
---@field PercentArmorPen number
---@field PercentBonusArmorPen number
---@field PercentCritBonusArmorPen number
---@field PercentCritTotalArmorPen number
---@field FlatMagicPen number
---@field MagicalLethality number
---@field PercentMagicPen number
---@field PercentBonusMagicPen number
---@field PercentLifeStealMod number
---@field PercentSpellVampMod number
---@field PercentCCReduction number
---@field PercentEXPBonus number
---@field ManaRegen number
---@field PrimaryResourceRegen number
---@field PrimaryResourceBaseRegen number
---@field SecondaryResourceRegen number
---@field SecondaryResourceBaseRegen number
---@field IsCasting boolean
---@field IsChanneling boolean @Not Implemented
---@field SkinId integer @Not Implemented
---@field AttackData Pointer
---@field AttackData2 Pointer
---@field BaseAD number
---@field BonusAD number
---@field TotalAD number
---@field BaseAP number
---@field BonusAP number
---@field TotalAP number
---@field IsBaron boolean
---@field IsDragon boolean
---@field CharName string
---@field BaseHealth number
---@field BonusHealth number
---@field AttackDelay number
---@field AttackCastDelay number
---@field ActiveSpell SpellCast
---@field Pathing Pathing
---@field HealthBarScreenPos Vector
---@field BuffCount integer
---@field Direction Vector
---@field FastPrediction fun(self: number, delay_ms: number):Vector
---@field GetSpell fun(self: number, slot: integer):SpellData|nil
---@field GetSpellState fun(self: number, slot: integer):number
---@field GetBuff fun(self: number, index: integer):BuffInst|nil
local AIBaseClient

--[[
     █████  ██ ██   ██ ███████ ██████   ██████  
    ██   ██ ██ ██   ██ ██      ██   ██ ██    ██ 
    ███████ ██ ███████ █████   ██████  ██    ██ 
    ██   ██ ██ ██   ██ ██      ██   ██ ██    ██ 
    ██   ██ ██ ██   ██ ███████ ██   ██  ██████   
]]
---@class AIHeroClient  : AIBaseClient
---@field RespawnTime number
---@field Experience number
---@field Level number
---@field Gold number
---@field TotalGold number
---@field VisionScore number
local AIHeroClient

--[[
     █████  ██ ███    ███ ██ ███    ██ ██  ██████  ███    ██ 
    ██   ██ ██ ████  ████ ██ ████   ██ ██ ██    ██ ████   ██ 
    ███████ ██ ██ ████ ██ ██ ██ ██  ██ ██ ██    ██ ██ ██  ██ 
    ██   ██ ██ ██  ██  ██ ██ ██  ██ ██ ██ ██    ██ ██  ██ ██ 
    ██   ██ ██ ██      ██ ██ ██   ████ ██  ██████  ██   ████ 
]]
---@class AIMinionClient  : AIBaseClient
---@field IsPet boolean
---@field IsLaneMinion boolean
---@field IsEpicMinion boolean
---@field IsEliteMinion boolean
local AIMinionClient

--[[
     █████  ██ ████████ ██    ██ ██████  ██████  ███████ ████████ 
    ██   ██ ██    ██    ██    ██ ██   ██ ██   ██ ██         ██    
    ███████ ██    ██    ██    ██ ██████  ██████  █████      ██    
    ██   ██ ██    ██    ██    ██ ██   ██ ██   ██ ██         ██    
    ██   ██ ██    ██     ██████  ██   ██ ██   ██ ███████    ██   
]]
---@class AITurretClient  : AIBaseClient
local AITurretClient

--[[
    ███    ███ ██ ███████ ███████ ██ ██      ███████ 
    ████  ████ ██ ██      ██      ██ ██      ██      
    ██ ████ ██ ██ ███████ ███████ ██ ██      █████   
    ██  ██  ██ ██      ██      ██ ██ ██      ██      
    ██      ██ ██ ███████ ███████ ██ ███████ ███████    
]]
---@class MissileClient  : GameObject
---@field StartPos Vector
---@field EndPos Vector
---@field StartTime number
---@field CastEndTime number
---@field EndTime number
---@field IsBasicAttack boolean
---@field IsSpecialAttack boolean
---@field Caster AIBaseClient
---@field Source AIBaseClient
---@field Target AttackableUnit
---@field Width number
---@field Speed number
---@field Accel number
---@field MaxSpeed number
---@field MinSpeed number
---@field FixedTravelTime number
local MissileClient

---_G.CoreEx.ObjectManager
---@class ObjectManager
---@field Player AIHeroClient
---@field Get fun(_team: string , _type:string):table<Handle_t, GameObject> @_team: {all, ally, enemy, neutral, no_team}, _type:{heroes, minions, turrets, inhibitors, hqs, wards, particles, missiles, others}
---@field GetObjectByHandle fun(handle: Handle_t):GameObject
local ObjectManager
_G.CoreEx.ObjectManager = ObjectManager

--[[
    ██ ███    ██ ██████  ██    ██ ████████ 
    ██ ████   ██ ██   ██ ██    ██    ██    
    ██ ██ ██  ██ ██████  ██    ██    ██    
    ██ ██  ██ ██ ██      ██    ██    ██    
    ██ ██   ████ ██       ██████     ██    
]]
---_G.CoreEx.Input
local Input = {}
---@overload fun(slot: integer, Target:AttackableUnit):boolean
---@overload fun(slot: integer, TargetPos:Vector):boolean
---@overload fun(slot: integer, TargetPos:Vector, StartPos:Vector):boolean
---@param slot integer
---@return boolean
function Input.Cast(slot) end
---@param target AttackableUnit
---@return boolean
function Input.Attack(target) end
---@param pos Vector
---@return boolean
function Input.MoveTo(pos) end
_G.CoreEx.Input = Input

--[[
    ██████  ███████ ███    ██ ██████  ███████ ██████  ███████ ██████  
    ██   ██ ██      ████   ██ ██   ██ ██      ██   ██ ██      ██   ██ 
    ██████  █████   ██ ██  ██ ██   ██ █████   ██████  █████   ██████  
    ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██ ██      ██   ██ 
    ██   ██ ███████ ██   ████ ██████  ███████ ██   ██ ███████ ██   ██ 
]]

---@class Renderer
---@field DrawCircle3D fun(center:Vector, radius: number, quality:integer, thickness:integer, color:integer):nil
---@field DrawLine fun(pos1:Vector, pos2:Vector, thickness:integer, color:integer):nil
---@field DrawLine3D fun(pos1:Vector, pos2:Vector, thickness:integer, color:integer):nil
---@field DrawText fun(pos:Vector, size:Vector, text:string, color:integer):nil
---@field DrawRectOutline fun(pos:Vector, size:Vector, rounding:integer, thickness:integer, color:integer):nil
---@field DrawFilledRect fun(pos:Vector, size:Vector, rounding:integer, color:integer):nil
---@field IsOnScreen fun(pos: Vector):boolean
---@field IsOnScreen2D fun(pos: Vector):boolean
---@field WorldToScreen fun(pos: Vector):Vector
---@field WorldToMinimap fun(pos: Vector):Vector @Not Implemented
---@field GetResolution fun():Vector
---@field GetMousePos fun():Vector
local Renderer 
_G.CoreEx.Renderer = Renderer

---@class Game
---@field GetTime       fun():number
---@field GetLatency    fun():integer
---@field IsMinimized   fun():boolean
---@field IsChatOpen    fun():boolean
---@field PrintChat     fun(msg:string):nil
---@field SendChat      fun(msg:string):nil
local Game = {}
_G.CoreEx.Game = Game

--[[
    ███████ ██    ██ ███████ ███    ██ ████████ ███    ███  █████  ███    ██  █████   ██████  ███████ ██████  
    ██      ██    ██ ██      ████   ██    ██    ████  ████ ██   ██ ████   ██ ██   ██ ██       ██      ██   ██ 
    █████   ██    ██ █████   ██ ██  ██    ██    ██ ████ ██ ███████ ██ ██  ██ ███████ ██   ███ █████   ██████  
    ██       ██  ██  ██      ██  ██ ██    ██    ██  ██  ██ ██   ██ ██  ██ ██ ██   ██ ██    ██ ██      ██   ██ 
    ███████   ████   ███████ ██   ████    ██    ██      ██ ██   ██ ██   ████ ██   ██  ██████  ███████ ██   ██ 
]]
---@class EventManager 
---@field EventExists fun(event: string):nil           
---@field RegisterEvent fun(event: string):nil         
---@field RemoveEvent fun(event: string):nil  
---@field FireEvent fun(event: string, var_args:any):nil         
---@field RegisterCallback fun(event: string, func: function):nil @see Enums.Events
---@field RemoveCallback fun(event: string, func: function):nil   @see Enums.Events
local EventManager
_G.CoreEx.EventManager = EventManager

--[[
    ███████ ███    ██ ██    ██ ███    ███ ███████ 
    ██      ████   ██ ██    ██ ████  ████ ██      
    █████   ██ ██  ██ ██    ██ ██ ████ ██ ███████ 
    ██      ██  ██ ██ ██    ██ ██  ██  ██      ██ 
    ███████ ██   ████  ██████  ██      ██ ███████
]]
---@class Enum_AbilityResourceTypes
---@field Mana integer
---@field Energy integer
---@field Shield integer
---@field Battlefury integer
---@field Dragonfury integer
---@field Rage integer
---@field Heat integer
---@field Gnarfury integer
---@field Ferocity integer
---@field BloodWell integer
---@field Wind integer
---@field Ammo integer
---@field Other integer
local AbilityResourceTypes
_G.CoreEx.Enums.AbilityResourceTypes = AbilityResourceTypes

---@class Enum_DamageTypes
---@field Physical integer
---@field Magical integer
---@field Mixed integer
---@field True integer
local DamageTypes 
_G.CoreEx.Enums.DamageTypes = DamageTypes

---@class Enum_BuffTypes
---@field Internal integer
---@field Aura integer
---@field CombatEnchancer integer
---@field CombatDehancer integer
---@field SpellShield integer
---@field Stun integer
---@field Invisibility integer
---@field Silence integer
---@field Taunt integer
---@field Polymorph integer
---@field Slow integer
---@field Snare integer
---@field Damage integer
---@field Heal integer
---@field Haste integer
---@field SpellImmunity integer
---@field PhysicalImmunity integer
---@field Invulnerability integer
---@field AttackSpeedSlow integer
---@field NearSight integer
---@field Currency integer
---@field Fear integer
---@field Charm integer
---@field Poison integer
---@field Suppression integer
---@field Blind integer
---@field Counter integer
---@field Shred integer
---@field Flee integer
---@field Knockup integer
---@field Knockback integer
---@field Disarm integer
---@field Grounded integer
---@field Drowsy integer
---@field Asleep integer
---@field Obscured integer
---@field ClickproofToEnemies integer
---@field Unkillable integer
local BuffTypes
_G.CoreEx.Enums.BuffTypes = BuffTypes

---@class Enum_ObjectTypeFlags
---@field GameObject integer
---@field NeutralCamp integer
---@field DeadObject integer
---@field InvalidObject integer
---@field AIBaseCommon integer
---@field AI integer
---@field Minion integer
---@field Hero integer
---@field Turret integer
---@field Missile integer
---@field Building integer
---@field AttackableUnit integer
local ObjectTypeFlags
_G.CoreEx.Enums.ObjectTypeFlags = ObjectTypeFlags

---@class Enum_GameObjectOrders
---@field HoldPosition integer
---@field MoveTo integer
---@field AttackUnit integer
---@field AutoAttackPet integer
---@field AutoAttack integer
---@field MovePet integer
---@field AttackTo integer
---@field Stop integer
---@field StopPet integer
local GameObjectOrders
_G.CoreEx.Enums.GameObjectOrders = GameObjectOrders

---@class Enum_Teams
---@field None integer
---@field Order integer
---@field Chaos integer
---@field Neutral integer
local Teams
_G.CoreEx.Enums.Teams = Teams

---@class Enum_SpellSlots
---@field Unknown integer
---@field Q integer
---@field W integer
---@field E integer
---@field R integer
---@field Summoner1 integer
---@field Summoner2 integer
---@field Item1 integer
---@field Item2 integer
---@field Item3 integer
---@field Item4 integer
---@field Item5 integer
---@field Item6 integer
---@field Trinket integer
---@field Recall integer
---@field BasicAttack integer
---@field SecondaryAttack integer
local SpellSlots
_G.CoreEx.Enums.SpellSlots = SpellSlots

---@class Enum_ItemSlots
---@field Unknown integer
---@field Item1 integer
---@field Item2 integer
---@field Item3 integer
---@field Item4 integer
---@field Item5 integer
---@field Item6 integer
---@field Trinket integer
local ItemSlots
_G.CoreEx.Enums.ItemSlots = ItemSlots

---@class Enum_SpellStates
---@field Ready integer
---@field Unknown integer
---@field Invalid integer
---@field NotLearned integer
---@field Disabled integer
---@field CrowdControlled integer
---@field Cooldown integer
---@field NoMana integer
---@field Locked integer
---@field Cooldown2 integer
local SpellStates
_G.CoreEx.Enums.SpellStates = SpellStates

---@class Enum_Events
---@field OnTick string                @[[30FPS]] void OnTick()
---@field OnUpdate string              @[[60FPS]] void OnUpdate()
---@field OnDraw string                @[[Screen Refresh Rate]] void OnDraw()
---@field OnDrawHUD string             @[[Screen Refresh Rate]] void OnDrawHUD()
---@field OnKey string                 @[[KeyPress]] void OnKey(e, message, wparam, lparam)
---@field OnMouseEvent string          @[[KeyPress]] void OnMouseEvent(e, message, wparam, lparam)
---@field OnKeyDown string             @[[KeyPress]] void OnKeyDown(keycode, char, lparam)
---@field OnKeyUp string               @[[KeyPress]] void OnKeyUp(keycode, char, lparam)
---@field OnCreateObject string        @[[After Creation]] void OnCreateObject(obj)
---@field OnDeleteObject string        @[[Before Deletion]] void OnDeleteObject(obj)
---@field OnCastSpell string           @[[Change/Block Player Casts]] void OnIssueOrder(Args) --Args={Process, Slot, StartPosition, TargetPosition, Target}
---@field OnProcessSpell string        @[[Animation Start]] void OnProcessSpell(obj, spellcast)
---@field OnSpellCast string           @[[Animation End]] NOT IMPLEMENTED [WIP]
---@field OnCastStop string            @[[Animation Interrupted]] NOT IMPLEMENTED [WIP]
---@field OnBasicAttack string         @[[Animation Start]] void OnBasicAttack(obj, spellcast)
---@field OnNewPath string             @[[Animation Start]] void OnNewPath(obj, pathing)
---@field OnIssueOrder string          @[[Change/Block Player Orders]] void OnIssueOrder(Args) --Args={Process, Order, Position, Target}
---@field OnBuffUpdate string          @[[After Update]] void OnBuffUpdate(obj, buffInst)
---@field OnBuffGain string            @[[After Creation]] void OnBuffGain(obj, buffInst)
---@field OnBuffLost string            @[[Before Deletion]] void OnBuffLost(obj, buffInst)
---@field OnVisionGain string          @[[Hero Leaves FOG]] NOT IMPLEMENTED [WIP]
---@field OnVisionLost string          @[[Hero Enters FOG]] NOT IMPLEMENTED [WIP]
---@field OnTeleport string            @[[Works in FOG]]  NOT IMPLEMENTED [WIP]
---@field OnPreAttack string           @[[Orbwalker Wants To Attack]] NOT IMPLEMENTED [WIP]
---@field OnPostAttack string          @[[Orbwalker Finished Attacking]] NOT IMPLEMENTED [WIP]
---@field OnPreMove string             @[[Orbwalker Wants To Move]] NOT IMPLEMENTED [WIP]
---@field OnPostMove string            @[[Orbwalker Started Moving]] NOT IMPLEMENTED [WIP]
---@field OnUnkillableMinion string    @[[Orbwalker Cant Kill a Minion]] NOT IMPLEMENTED [WIP]
local Events
_G.CoreEx.Enums.Events = Events