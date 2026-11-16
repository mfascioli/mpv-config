-- Audio profiles for mpv, built on FFmpeg's loudnorm, acompressor and
-- alimiter. The key bindings live in input.conf:
--
--   1  off        no processing; the original mix
--   2  soft       -22 LUFS, dynamic loudness normalization only
--   3  balanced   -20 LUFS, dynamic loudness normalization only
--   4  night      -18 LUFS, strong compression plus limiting
--
-- Playback starts in Off, so a file plays untouched until a profile is chosen.
-- The processed profiles use loudnorm in single-pass dynamic mode
-- (linear=false); alimiter is the final sample-peak safety stage.

local mp = require 'mp'
local msg = require 'mp.msg'

local profiles = {
    off = {
        name = 'Off',
        af = '',
    },
    soft = {
        name = 'Soft',
        af = 'loudnorm=I=-22:TP=-1.5:LRA=18:linear=false,'
            .. 'alimiter=limit=0.8414:level=0',
    },
    balanced = {
        name = 'Balanced',
        af = 'loudnorm=I=-20:TP=-2:LRA=14:linear=false,'
            .. 'alimiter=limit=0.7943:level=0',
    },
    night = {
        name = 'Night',
        af = 'acompressor=threshold=0.125:ratio=4:attack=20:release=250'
            .. ':knee=2.5:makeup=1,'
            .. 'loudnorm=I=-18:TP=-3:LRA=7:linear=false,'
            .. 'alimiter=limit=0.7079:level=0',
    },
}

local default_profile = 'off'
local current

local function apply(key, silent)
    local profile = profiles[key]
    if not profile then return end

    -- mp.set_property('af', ...) accepts invalid filter strings without
    -- reporting anything; the af/set command returns an error instead.
    -- pcall returns (ok, result, error), so the error is the third value.
    local ok, _, err = pcall(mp.command_native, { 'af', 'set', profile.af })
    if not ok or err then
        msg.error(('could not apply %s: %s'):format(key, tostring(err or 'error')))
        mp.osd_message('Audio: could not apply ' .. profile.name, 3)
        return
    end

    current = key
    if not silent then
        mp.osd_message('Audio: ' .. profile.name, 1.5)
    end
end

for key in pairs(profiles) do
    local profile_key = key
    mp.add_key_binding(nil, profile_key, function() apply(profile_key) end)
end

-- Reassert the selected profile whenever a file loads. Watch-later files,
-- per-file af options or another script can otherwise replace the chain.
mp.register_event('file-loaded', function()
    apply(current or default_profile, true)
end)

-- Scripts load after mpv.conf, so the default chain can be installed
-- immediately. Do not show an OSD message on startup.
mp.add_timeout(0, function()
    if not current then apply(default_profile, true) end
end)
