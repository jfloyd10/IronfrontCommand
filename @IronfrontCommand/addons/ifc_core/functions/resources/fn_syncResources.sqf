/*
    Function: IFC_fnc_syncResources
    Description: Forces a re-broadcast of all resource variables for a player.
                 Used for JIP (Join In Progress) synchronization — when a new
                 player connects mid-game, call this to ensure they receive
                 current resource state.
                 Server-authoritative.

    Parameters:
        0: OBJECT - The player object to sync
    Returns: Nothing
    Author: IFC Dev
*/

params [["_player", objNull, [objNull]]];

// Server authority redirect
if (!isServer) exitWith {
    [_player] remoteExecCall ["IFC_fnc_syncResources", 2];
};

if (isNull _player) exitWith {
    diag_log "IFC: syncResources — null player, aborting";
};

// Re-broadcast all resource variables with broadcast=true
// This forces network sync to all clients including newly joined ones
_player setVariable ["IFC_minerals",
    _player getVariable ["IFC_minerals", 0], true];
_player setVariable ["IFC_supply_used",
    _player getVariable ["IFC_supply_used", 0], true];
_player setVariable ["IFC_supply_cap",
    _player getVariable ["IFC_supply_cap", 0], true];
_player setVariable ["IFC_buildings",
    _player getVariable ["IFC_buildings", []], true];
_player setVariable ["IFC_units",
    _player getVariable ["IFC_units", []], true];
_player setVariable ["IFC_isEliminated",
    _player getVariable ["IFC_isEliminated", false], true];
_player setVariable ["IFC_nodeIncome",
    _player getVariable ["IFC_nodeIncome", 0], true];

diag_log format ["IFC: Resources synced for %1", name _player];

// TEST: Open debug console, run:
// [player] call IFC_fnc_syncResources;
// Expected: All IFC_ variables on player are re-broadcast. No visible change
// in single player, but in MP this ensures JIP clients receive current state.
