local cfg = require("bearvim.core.config")

return cfg.regex({
	name = "MakeAllPub",
	match = [[^\s*\zs\%(async\s\+\)\?fn\>]],
	replace = [[pub &]],
	global = true,
	desc = "Make all functions public",
})
