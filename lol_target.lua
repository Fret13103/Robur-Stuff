--[[ LOL BOOTSTRAP MODULES ]]--

local printHelpGlobal = _G.printHelp;
function _G.printHelp()
	printHelpGlobal()
	print 'Some [lol] Commands:                                                 '
	print '----------------------------------------------------------------------'
end

_G.DevMode = false
require("lol\\Modules\\CoreEx\\Loader")
