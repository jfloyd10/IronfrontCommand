// ============================================================================
// Ironfront Command — Dev Test Mission Init
// Sprint 1: Foundation & Resource System
// ============================================================================

// Wait for game display to be ready
waitUntil { !isNull findDisplay 46 };
waitUntil { time > 0 };

// ============================================================================
// Server Initialization
// ============================================================================
if (isServer) then {
    [] call IFC_fnc_initServer;

    diag_log "IFC: [Mission] Server init complete";
};

// ============================================================================
// Client Initialization
// ============================================================================
if (hasInterface) then {
    // Wait for player object to exist
    waitUntil { !isNull player };
    waitUntil { alive player };

    // Initialize this player's resources and HUD
    [player] call IFC_fnc_initPlayer;

    diag_log "IFC: [Mission] Client init complete";

    // Welcome hint
    hint "IRONFRONT COMMAND\nSprint 1 — Resource System Test\n\nMinerals: 200\nIncome: +25 every 8 seconds\n\nOpen Debug Console to test functions.";
};
