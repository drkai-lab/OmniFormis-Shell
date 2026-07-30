-- Plugin is now managed natively by Nix via mkHyprlandPlugin, but since we use hyprland.lua instead of the home-manager hyprland.conf, we must load the nix-profile binary manually!
local function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

local plugin_path = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/lib/libhyprglass.so"
if not file_exists(plugin_path) then
    plugin_path = os.getenv("HOME") .. "/.nix-profile/lib/libhyprglass.so"
end

os.execute("hyprctl plugin load " .. plugin_path .. " &")
local vars = require("modules.variables")
local Utils = require("utils")
local colors = Utils.colors

-- Create a 12% opacity tint from the background color
local bg_hex = colors.background:sub(5) -- Extract RRGGBB from 0xAARRGGBB
local tint_color = tonumber("0x1f" .. bg_hex, 16)

if hl.plugin.hyprglass then
    os.execute("notify-send 'Liquid Glass' 'Plugin API loaded successfully!'")
    local hg = hl.plugin.hyprglass

    hg.preset("glass", {
        blur_strength          = 2.0,
        blur_iterations        = 3,
        chromatic_aberration   = 0.8,
        fresnel_strength       = 0.8,
        edge_thickness         = 0.08,
        tint_color             = tint_color,
        lens_distortion        = 0.9,
        brightness             = 1.0,
        contrast               = 1.7,
        saturation             = 1,
        vibrancy               = 0.8,
        vibrancy_darkness      = 1,
        adaptive_boost         = 0.5,
    })

    hg.preset("apple", {
        blur_strength          = 2.2,
        blur_iterations        = 3,
        refraction_strength    = 0.55,
        chromatic_aberration   = 0.3,
        fresnel_strength       = 0.5,
        specular_strength      = 0.75,
        edge_thickness         = 0.05,
        lens_distortion        = 0.3,
        dark  = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
        light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
    })

    hg.config({
        enabled = vars.liquidGlass,
        default_theme = "dark",
        default_preset = vars.liquidGlassPreset or "glass",
        tint_color = tint_color,

        brightness = 0.9,
        dark = { brightness = 0.82 },
        light = { adaptive_boost = 0.5 },
    })

    -- Layer surfaces: each call whitelists the namespace and configures it
    hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
    hg.layer("swaync")
    -- hg.layer("quickshell", { preset = "apple", mask_threshold = 0.05 })
    -- hg.layer("quickshell:bezel", { preset = "apple", mask_threshold = 0.05 })
    hg.layer("debug-panel", { exclude = true })

    -- Presets
    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.5,
        dark = { brightness = 0.7 },
        light = { brightness = 1.2 },
    })



    hg.preset("contrasted", {
        inherits = "high_contrast",
        contrast = 1.2,
        adaptive_dim = 1.5,
        dark = { tint_color = 0x02142aa9 },
    })
else
    os.execute("notify-send 'Liquid Glass Error' 'Plugin API NOT found in hl.plugin. Script bypassed configuration!'")
end
