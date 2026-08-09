.pragma library

var radiusAmount = 0.5;
var radiusSmall = 8;
var radiusMedium = 16;
var radiusLarge = 24;
var radiusExtraLarge = 38;
var cornerPower = 2.0;

var spacingSmall = 11;
var spacingMedium = 16;
var spacingLarge = 24;

var paddingSmall = 8;
var paddingMedium = 16;
var paddingLarge = 24;

var fontFamily = "Google Sans Flex";
var fontWeight = 600;
var fontItalic = false;
var fontRounding = 100;
var fontGrading = 0;
var fontBaselineEnabled = true;
var animationDuration = 240;
var flickDeceleration = 1500;
var maximumFlickVelocity = 3000;
var _translucent = false;
var _liquidGlass = true;
var blurAmount = 8;
var panelOpacity = 0.7;
var componentOpacity = 0.4;
var currentBrightness = 1.0;

var overviewGridRows = 2;
var overviewGridColumns = 5;
var overviewScale = 0.7;

var gameLibraryRows = 2;
var gameLibraryColumns = 4;
var gameLibraryScale = 1.0;

var wallpaperMaskEnabled = true;
var wallpaperMaskScale = 1;
var wallpaperMaskShape = "6SidedCookie";
var wallpaperMaskColor = "secondary";
var wallpaperMaskOffsetX = 0;
var wallpaperMaskOffsetY = 0;

var clockShape = "9SidedCookie";
var clockShowTicks = true;
var clockShowCenterDot = true;

var mediaPlayerShape = "12SidedCookie";
var mediaPlayerArtScale = 1.25;
var mediaPlayerWaveThickness = 2.5;

var panelStyle = "Attached";
var pillPosition = "Bottom";
var gameMode = false;

var desktopClockEnabled = true;
var desktopClockAnchorEnabled = true;
var desktopClockAnchorPoint = "Center";
var desktopClockAnchorCurve = 1;

var desktopCalenderEnabled = false;
var desktopCalenderAnchorEnabled = false;
var desktopCalenderAnchorPoint = "Center";
var desktopCalenderAnchorCurve = 0;

var desktopMediaPlayerEnabled = true;
var desktopMediaPlayerAnchorEnabled = true;
var desktopMediaPlayerAnchorPoint = "Center";
var desktopMediaPlayerAnchorCurve = 2;

var m3Standard = [0.2, 0.0, 0.0, 1.0];
var m3StandardDecelerate = [0.0, 0.0, 0.0, 1.0];
var m3StandardAccelerate = [0.3, 0.0, 1.0, 1.0];
var m3EmphasizedDecelerate = [0.05, 0.7, 0.1, 1.0];
var m3EmphasizedAccelerate = [0.3, 0.0, 0.8, 0.15];
var m3ExpressiveSpatialFast = [0.42, 1.67, 0.21, 0.9];
var m3ExpressiveSpatialSlow = [0.39, 1.29, 0.35, 0.98];

var customStandard = [0.2, 0.0, 0.0, 1.0];
var customStandardDecelerate = [0.0, 0.0, 0.0, 1.0];
var customStandardAccelerate = [0.3, 0.0, 1.0, 1.0];
var customEmphasizedDecelerate = [0.05, 0.7, 0.1, 1.0];
var customEmphasizedAccelerate = [0.3, 0.0, 0.8, 0.15];
var customExpressiveSpatialFast = [0.42, 1.67, 0.21, 0.9];
var customExpressiveSpatialSlow = [0.39, 1.29, 0.35, 0.98];

function getTopLeftRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Attached" && (pos === "Top" || pos === "Left")) return 0;
    if (style === "Framed") return 0;
    return rad;
}

function getTopRightRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Attached" && (pos === "Top" || pos === "Right")) return 0;
    if (style === "Framed") return 0;
    return rad;
}

function getBottomLeftRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Attached" && (pos === "Bottom" || pos === "Left")) return 0;
    if (style === "Framed") return 0;
    return rad;
}

function getBottomRightRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Attached" && (pos === "Bottom" || pos === "Right")) return 0;
    if (style === "Framed") return 0;
    return rad;
}

function fuzzyMatch(pattern, str) {
    if (!pattern) return true;
    if (!str) return false;
    pattern = pattern.toLowerCase();
    str = str.toLowerCase();
    
    var words = pattern.split(/\s+/);
    for (var w = 0; w < words.length; w++) {
        var word = words[w];
        if (!word) continue;
        
        var patternIdx = 0;
        var found = false;
        for (var i = 0; i < str.length; i++) {
            if (str[i] === word[patternIdx]) {
                patternIdx++;
                if (patternIdx === word.length) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) return false;
    }
    
    return true;
}

function fuzzyMatchScore(pattern, str) {
    if (!pattern) return 1;
    if (!str) return 0;
    pattern = pattern.toLowerCase();
    str = str.toLowerCase();
    
    if (str === pattern) return 1000;
    if (str.startsWith(pattern)) return 500;
    
    var words = pattern.split(/\s+/);
    var totalScore = 0;
    
    for (var w = 0; w < words.length; w++) {
        var word = words[w];
        if (!word) continue;
        
        var patternIdx = 0;
        var score = 0;
        var consecutive = 0;
        var found = false;
        
        for (var i = 0; i < str.length; i++) {
            if (str[i] === word[patternIdx]) {
                score += 10 + (consecutive * 5);
                if (i === 0) score += 50;
                consecutive++;
                patternIdx++;
                if (patternIdx === word.length) {
                    found = true;
                    totalScore += score;
                    break;
                }
            } else {
                consecutive = 0;
            }
        }
        
        if (!found) return 0;
    }
    
    return totalScore;
}

// --- Centralized translucency helpers (replaces 120+ inline checks) ---

function isTranslucent() {
    return _translucent && !gameMode;
}

function tColor(baseColor, alpha) {
    if (!isTranslucent()) return baseColor;
    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha);
}

function tColorActive(isActive, baseColor, alpha) {
    if (!isActive) return "transparent";
    return tColor(baseColor, alpha);
}

var notificationHistory = [];
var historyUpdated = 0;

function pushNotification(modelData) {
    if (!modelData) return;
    
    var uniqueId = modelData.seqId !== undefined ? modelData.seqId : (modelData.id !== undefined ? modelData.id : Math.random());

    for (var i = 0; i < notificationHistory.length; i++) {
        if (notificationHistory[i].seqId === uniqueId) {
            return;
        }
    }
    
    var actionsArray = [];
    if (modelData.actions) {
        for (var j = 0; j < modelData.actions.length; j++) {
            actionsArray.push({
                identifier: modelData.actions[j].identifier,
                text: modelData.actions[j].text
            });
        }
    }
    
    var n = {
        seqId: uniqueId,
        appName: modelData.appName,
        appIcon: modelData.appIcon,
        summary: modelData.summary,
        body: modelData.body,
        image: modelData.image,
        urgency: modelData.urgency,
        actions: actionsArray,
        expireTimeout: modelData.expireTimeout,
        defaultTimeout: modelData.defaultTimeout,
        invokeAction: function(id) {
            try { modelData.invokeAction(id); } catch(e) {}
        },
        dismiss: function() {
            try { modelData.dismiss(); } catch(e) {}
            removeNotification(this.seqId);
        }
    };
    
    notificationHistory.unshift(n);
    historyUpdated++;
}

function removeNotification(seqId) {
    var initialLen = notificationHistory.length;
    notificationHistory = notificationHistory.filter(function(n) { return n.seqId !== seqId; });
    if (notificationHistory.length !== initialLen) {
        historyUpdated++;
    }
}

function clearNotifications() {
    for (var i = 0; i < notificationHistory.length; i++) {
        var n = notificationHistory[i];
        if (n && typeof n.dismiss === 'function' && !n.closed) {
            n.dismiss();
        }
    }
    notificationHistory = [];
    historyUpdated++;
}
