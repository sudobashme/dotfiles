-- AeroSpace reference panel. Does not manage windows or execute listed actions.
require('hs.ipc')
hs.autoLaunch(true)
hs.dockIcon(false)

local hud = require('aerospace_hud')
aerospaceHUD = hud -- Console/CLI access for diagnostics and preview.
hud.hotkey = hs.hotkey.bind({'alt'}, 'space', hud.toggle)
