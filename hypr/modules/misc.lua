----------------
----  MISC  ----
----------------
local vars = require("modules.variables")

hl.config({
  misc = {
    force_default_wallpaper = vars.force_default_wallpaper,
    disable_hyprland_logo = vars.disable_hyprland_logo,
    allow_session_lock_restore = vars.allow_session_lock_restore,
    vrr = vars.vrr
  },

  xwayland = {
    force_zero_scaling = vars.xwayland_force_zero_scaling,
    use_nearest_neighbor = vars.xwayland_use_nearest_neighbor
  },

  experimental = {
    wp_cm_1_2 = true
  },

  render = {
    cm_auto_hdr = true,
    use_shader_blur_blend = true,
    keep_unmodified_copy = true
  }
})
