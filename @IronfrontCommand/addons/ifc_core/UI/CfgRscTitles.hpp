// ============================================================================
// Ironfront Command — HUD Overlay (CfgRscTitles)
// Sprint 1: Resource HUD — minerals, supply, income rate
// ============================================================================

class RscTitles {
    class IFC_ResourceHUD {
        idd = 9001;
        movingEnable = 0;
        enableSimulation = 1;
        duration = 1e+011;
        fadeIn = 0;
        fadeOut = 0;
        name = "IFC_ResourceHUD";

        onLoad = "uiNamespace setVariable ['IFC_ResourceHUD', _this select 0];";

        class controls {
            // ================================================================
            // Background panel — dark semi-transparent box
            // ================================================================
            class MineralBG : RscText {
                idc = 1001;
                x = "safeZoneX + 0.01";
                y = "safeZoneY + 0.01";
                w = 0.19;
                h = 0.095;
                style = 0;
                text = "";
                colorBackground[] = {0, 0, 0, 0.65};
            };

            // ================================================================
            // Mineral icon — placeholder (no .paa texture yet)
            // ================================================================
            class MineralIcon : RscPicture {
                idc = 1002;
                x = "safeZoneX + 0.015";
                y = "safeZoneY + 0.017";
                w = 0.025;
                h = 0.025;
                style = 48;
                text = "";
                colorText[] = {0.9, 0.85, 0.2, 1};
            };

            // ================================================================
            // Mineral count text — gold color
            // ================================================================
            class MineralText : RscText {
                idc = 1003;
                x = "safeZoneX + 0.045";
                y = "safeZoneY + 0.015";
                w = 0.14;
                h = 0.03;
                style = 0;
                text = "0";
                font = "PuristaMedium";
                sizeEx = 0.032;
                colorText[] = {0.9, 0.85, 0.2, 1};
                colorBackground[] = {0, 0, 0, 0};
                shadow = 2;
            };

            // ================================================================
            // Supply text — cyan color "Supply: 0/10"
            // ================================================================
            class SupplyText : RscText {
                idc = 1004;
                x = "safeZoneX + 0.015";
                y = "safeZoneY + 0.05";
                w = 0.17;
                h = 0.025;
                style = 0;
                text = "Supply: 0/10";
                font = "PuristaMedium";
                sizeEx = 0.024;
                colorText[] = {0.6, 0.9, 1, 1};
                colorBackground[] = {0, 0, 0, 0};
                shadow = 2;
            };

            // ================================================================
            // Income rate text — green color "+25/tick"
            // ================================================================
            class IncomeText : RscText {
                idc = 1005;
                x = "safeZoneX + 0.015";
                y = "safeZoneY + 0.077";
                w = 0.17;
                h = 0.02;
                style = 0;
                text = "+0/tick";
                font = "PuristaMedium";
                sizeEx = 0.02;
                colorText[] = {0.4, 0.9, 0.4, 1};
                colorBackground[] = {0, 0, 0, 0};
                shadow = 2;
            };
        };
    };
};
