// ============================================================================
// Ironfront Command — Master Config
// Sprint 1: Foundation & Resource System
// ============================================================================

class CfgPatches {
    class IFC_Core {
        name = "Ironfront Command - Core";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.98;
        requiredAddons[] = {"cba_main", "A3_UI_F"};
        version = "0.1.0";
        author = "IFC Dev";
    };
};

// ============================================================================
// Function Registration
// ============================================================================
#include "CfgFunctions.hpp"

// ============================================================================
// UI Definitions
// ============================================================================
#include "UI\CfgRscTitles.hpp"

// ============================================================================
// Remote Execution Whitelist
// ============================================================================
class CfgRemoteExec {
    class Functions {
        mode = 2;  // Whitelist mode
        jip = 1;

        // Resource mutations — server only
        class IFC_fnc_addResources      { allowedTargets = 2; };
        class IFC_fnc_spendResources    { allowedTargets = 2; };
        class IFC_fnc_syncResources     { allowedTargets = 2; };

        // Player init — all targets
        class IFC_fnc_initPlayer        { allowedTargets = 0; };
    };
};

// ============================================================================
// Base UI Classes (inherited by HUD controls)
// ============================================================================
class RscText {
    type = 0;
    idc = -1;
    x = 0;
    y = 0;
    w = 0.1;
    h = 0.04;
    style = 0;
    font = "PuristaMedium";
    sizeEx = 0.028;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    linespacing = 1;
    tooltipColorText[] = {1, 1, 1, 1};
    tooltipColorBox[] = {1, 1, 1, 1};
    tooltipColorShade[] = {0, 0, 0, 0.65};
    text = "";
    shadow = 1;
    tooltip = "";
    access = 0;
};

class RscPicture {
    type = 0;
    idc = -1;
    style = 48;
    x = 0;
    y = 0;
    w = 0.1;
    h = 0.04;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    font = "PuristaMedium";
    sizeEx = 0.028;
    lineSpacing = 0;
    text = "";
    shadow = 0;
    tooltip = "";
};
