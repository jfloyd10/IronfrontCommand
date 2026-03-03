/*
    Function: IFC_fnc_initPlayer
    Description: Per-player initialization. Sets starting resources on the server
                 and registers the HUD update per-frame handler on the client.
                 Called once per player at mission start or JIP.

    Parameters:
        0: OBJECT - The player object to initialize
    Returns: Nothing
    Author: IFC Dev
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {
    diag_log "IFC: initPlayer — null player, aborting";
};

// ============================================================================
// Server: Set starting resource variables (broadcast to all clients)
// ============================================================================
if (isServer) then {
    _player setVariable ["IFC_minerals", 200, true];
    _player setVariable ["IFC_supply_used", 0, true];
    _player setVariable ["IFC_supply_cap", 10, true];
    _player setVariable ["IFC_buildings", [], true];
    _player setVariable ["IFC_units", [], true];
    _player setVariable ["IFC_isEliminated", false, true];
    _player setVariable ["IFC_nodeIncome", 0, true];

    diag_log format ["IFC: Player initialized on server — %1 (UID: %2)",
        name _player, getPlayerUID _player];
};

// ============================================================================
// Client: Load definitions, create HUD, register update handler
// ============================================================================
if (hasInterface) then {
    // Ensure global definitions are loaded on this client
    [] call IFC_fnc_init;

    // Create the resource HUD overlay using cutRsc
    // This creates a non-interactive always-on overlay from RscTitles
    "IFC_ResourceHUD" cutRsc ["IFC_ResourceHUD", "PLAIN"];

    // Register HUD update per-frame handler (every 0.5 seconds)
    // CBA PFH is used instead of sleep loops — never sleep in UI code
    ["IFC_hud_perFrame", {
        [] call IFC_fnc_updateHUD;
    }, 0.5] call CBA_fnc_addPerFrameHandler;

    diag_log "IFC: Player initialized on client — HUD created, PFH registered";
};

// TEST: Open debug console, run:
// [player] call IFC_fnc_initPlayer;
// Expected: HUD appears in top-left showing "200" minerals, "Supply: 0/10", "+25/tick"
// player getVariable "IFC_minerals"  → 200
// player getVariable "IFC_supply_cap"  → 10
