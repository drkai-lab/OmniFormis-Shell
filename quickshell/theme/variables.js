.pragma library

var radiusAmount = 0.5;
var radiusSmall = 8;
var radiusMedium = 16;
var radiusLarge = 24;
var radiusExtraLarge = 38;

var spacingSmall = 11;
var spacingMedium = 16;
var spacingLarge = 24;

var paddingSmall = 8;
var paddingMedium = 16;
var paddingLarge = 24;

var _radiusAmount = radiusAmount;
var _radiusSmall = radiusSmall;
var _radiusMedium = radiusMedium;
var _radiusLarge = radiusLarge;
var _radiusExtraLarge = radiusExtraLarge;

Object.defineProperty(this, 'radiusAmount', { get: function() { return panelStyle === "Framed" ? 0 : _radiusAmount; }, set: function(v) { _radiusAmount = v; } });
Object.defineProperty(this, 'radiusSmall', { get: function() { return panelStyle === "Framed" ? 0 : _radiusSmall; }, set: function(v) { _radiusSmall = v; } });
Object.defineProperty(this, 'radiusMedium', { get: function() { return panelStyle === "Framed" ? 0 : _radiusMedium; }, set: function(v) { _radiusMedium = v; } });
Object.defineProperty(this, 'radiusLarge', { get: function() { return panelStyle === "Framed" ? 0 : _radiusLarge; }, set: function(v) { _radiusLarge = v; } });
Object.defineProperty(this, 'radiusExtraLarge', { get: function() { return panelStyle === "Framed" ? 0 : _radiusExtraLarge; }, set: function(v) { _radiusExtraLarge = v; } });

var _spacingSmall = spacingSmall;
var _spacingMedium = spacingMedium;
var _spacingLarge = spacingLarge;

Object.defineProperty(this, 'spacingSmall', { get: function() { return panelStyle === "Framed" ? 0 : _spacingSmall; }, set: function(v) { _spacingSmall = v; } });
Object.defineProperty(this, 'spacingMedium', { get: function() { return panelStyle === "Framed" ? 0 : _spacingMedium; }, set: function(v) { _spacingMedium = v; } });
Object.defineProperty(this, 'spacingLarge', { get: function() { return panelStyle === "Framed" ? 0 : _spacingLarge; }, set: function(v) { _spacingLarge = v; } });

var _paddingSmall = paddingSmall;
var _paddingMedium = paddingMedium;
var _paddingLarge = paddingLarge;

Object.defineProperty(this, 'paddingSmall', { get: function() { return panelStyle === "Framed" ? 0 : _paddingSmall; }, set: function(v) { _paddingSmall = v; } });
Object.defineProperty(this, 'paddingMedium', { get: function() { return panelStyle === "Framed" ? 0 : _paddingMedium; }, set: function(v) { _paddingMedium = v; } });
Object.defineProperty(this, 'paddingLarge', { get: function() { return panelStyle === "Framed" ? 0 : _paddingLarge; }, set: function(v) { _paddingLarge = v; } });

var fontFamily = "Google Sans Flex";
var animationDuration = 240;
var flickDeceleration = 1500;
var maximumFlickVelocity = 3000;
var translucent = false;
var liquidGlass = true;
var liquidGlassPreset = "apple";
var blurAmount = 30;

var overviewGridRows = 2;
var overviewGridColumns = 5;
var overviewScale = 0.8;

var wallpaperMaskEnabled = true;
var wallpaperMaskScale = 1.05;
var wallpaperMaskShape = "4LeafClover";
var wallpaperMaskColor = "primary";
var wallpaperMaskOffsetX = 0;
var wallpaperMaskOffsetY = 4;

var clockShape = "6SidedCookie";
var clockShowTicks = false;
var clockShowCenterDot = false;

var mediaPlayerShape = "12SidedCookie";
var mediaPlayerArtScale = 1;

var panelStyle = "Attached";
var pillPosition = "Left";
var gameMode = false;

var desktopClockEnabled = true;
var desktopCalenderEnabled = false;
var desktopMediaPlayerEnabled = false;

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
    if (style === "Framed") return 0;
    if (style === "Attached" && (pos === "Top" || pos === "Left")) return 0;
    return rad;
}

function getTopRightRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Framed") return 0;
    if (style === "Attached" && (pos === "Top" || pos === "Right")) return 0;
    return rad;
}

function getBottomLeftRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Framed") return 0;
    if (style === "Attached" && (pos === "Bottom" || pos === "Left")) return 0;
    return rad;
}

function getBottomRightRadius(style, pos, isGame, defRad) {
    var rad = (defRad !== undefined && defRad !== null) ? defRad : 24;
    if (isGame || !style || !pos) return rad;
    if (style === "Framed") return 0;
    if (style === "Attached" && (pos === "Bottom" || pos === "Right")) return 0;
    return rad;
}

function fuzzyMatch(pattern, str) {
    return fuzzyMatchScore(pattern, str) > 0;
}

function fuzzyMatchScore(pattern, str) {
    if (!pattern) return 1;
    if (!str) return 0;
    pattern = pattern.toLowerCase();
    str = str.toLowerCase();
    
    var patternIdx = 0;
    var score = 0;
    var firstMatchIndex = -1;
    for (var i = 0; i < str.length; i++) {
        if (str[i] === pattern[patternIdx]) {
            if (firstMatchIndex === -1) firstMatchIndex = i;
            score += (100 - i); // higher score for earlier matches
            patternIdx++;
            if (patternIdx === pattern.length) {
                // Bonus for matching at the beginning of the word
                if (firstMatchIndex === 0) score += 500;
                return score;
            }
        }
    }
    return 0;
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
