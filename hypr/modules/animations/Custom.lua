local vars = require("modules.variables")

hl.config({
    bezier = {
        "customStandard, " .. vars.CustomStandard,
        "customStandardDecelerate, " .. vars.CustomStandardDecelerate,
        "customStandardAccelerate, " .. vars.CustomStandardAccelerate,
        "customEmphasizedDecelerate, " .. vars.CustomEmphasizedDecelerate,
        "customEmphasizedAccelerate, " .. vars.CustomEmphasizedAccelerate,
        "customExpressiveSpatialFast, " .. vars.CustomExpressiveSpatialFast,
        "customExpressiveSpatialSlow, " .. vars.CustomExpressiveSpatialSlow
    }
})

hl.animation({ leaf = "global",        enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5,  bezier = "customExpressiveSpatialSlow" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4,  bezier = "customStandard" }) 
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,  bezier = "customEmphasizedDecelerate", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,  bezier = "customEmphasizedAccelerate", style = "popin 80%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,  bezier = "customStandardDecelerate" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,  bezier = "customStandardAccelerate" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,  bezier = "customStandard" })
hl.animation({ leaf = "layers",        enabled = true, speed = 4,  bezier = "customStandard" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,  bezier = "customEmphasizedDecelerate", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 3,  bezier = "customEmphasizedAccelerate", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 3,  bezier = "customStandardDecelerate" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3,  bezier = "customStandardAccelerate" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4,  bezier = "customExpressiveSpatialSlow", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4,  bezier = "customExpressiveSpatialFast", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4,  bezier = "customExpressiveSpatialSlow", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 5,  bezier = "customStandard" })
