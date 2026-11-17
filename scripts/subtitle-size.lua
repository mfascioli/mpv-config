-- Remember the subtitle font size between runs, so the size chosen with
-- the numpad + / - keys survives closing mpv.
--
-- The value lives in subtitle-size.txt next to this config, which is
-- gitignored. A missing or malformed file is ignored and mpv.conf's
-- sub-font-size applies.

local mp = require 'mp'

local PATH = mp.command_native({ 'expand-path', '~~/subtitle-size.txt' })

local function save()
    local size = mp.get_property_number('sub-font-size')
    if not size then return end

    local file = io.open(PATH, 'w')
    if not file then return end
    file:write(('%.2f\n'):format(size))
    file:close()
end

local file = io.open(PATH, 'r')
if file then
    local size = tonumber(file:read('*l'))
    file:close()
    if size then mp.set_property_number('sub-font-size', size) end
end

mp.observe_property('sub-font-size', 'number', function(_, size)
    if size then save() end
end)
