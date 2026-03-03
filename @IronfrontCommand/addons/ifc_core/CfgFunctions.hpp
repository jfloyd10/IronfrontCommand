// ============================================================================
// Ironfront Command — CfgFunctions
// Sprint 1: Core, Resources, UI
// ============================================================================

class CfgFunctions {
    class IFC {
        // ====================================================================
        // Core — Initialization
        // ====================================================================
        class Core {
            file = "addons\ifc_core\functions\core";
            class init {};
            class initServer {};
            class initPlayer {};
        };

        // ====================================================================
        // Resources — Economy System
        // ====================================================================
        class Resources {
            file = "addons\ifc_core\functions\resources";
            class resourceTick {};
            class addResources {};
            class spendResources {};
            class canAfford {};
            class syncResources {};
        };

        // ====================================================================
        // UI — HUD and Interface
        // ====================================================================
        class UI {
            file = "addons\ifc_core\functions\ui";
            class updateHUD {};
        };
    };
};
