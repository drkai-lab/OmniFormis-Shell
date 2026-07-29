-- Standard Animation Style
hl.config({
    animations = {
        enabled = true,
    },
})

-- Animation curves
hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

-- Animation configs
hl.animation({ leaf = "global",        enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 6,  bezier = "standard" })
hl.animation({ leaf = "windows",       enabled = true, speed = 5,  bezier = "standard" }) 
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 5,  bezier = "emphasizedDecel", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,  bezier = "emphasizedAccel", style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 5,  bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 5,  bezier = "emphasizedAccel" })
hl.animation({ leaf = "fade",          enabled = true, speed = 6,  bezier = "standard" })
hl.animation({ leaf = "layers",        enabled = true, speed = 5,  bezier = "standard" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 5,  bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 4,  bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 5,  bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 5,  bezier = "emphasizedAccel" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,  bezier = "standard", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5,  bezier = "standard", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5,  bezier = "standard", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 6,  bezier = "standard" })
