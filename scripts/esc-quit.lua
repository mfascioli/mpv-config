-- ESC leaves fullscreen first; pressing it again quits without saving.
-- Shift+ESC is bound directly to quit-watch-later in input.conf, so it always
-- saves the position.
--
-- When a uosc menu is open, uosc installs a temporary forced ESC binding that
-- closes the menu before this script runs.

local mp = require 'mp'

local function on_esc()
    if mp.get_property_bool('fullscreen') then
        mp.set_property_bool('fullscreen', false)
        return
    end

    -- save-position-on-quit stays on for the window close button and for
    -- quit-watch-later; the plain ESC quit deliberately does not save.
    pcall(mp.set_property_bool, 'save-position-on-quit', false)
    mp.command('quit')
end

mp.add_key_binding(nil, 'escape', on_esc)
