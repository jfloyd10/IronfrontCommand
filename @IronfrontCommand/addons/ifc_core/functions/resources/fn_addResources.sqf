/*
    Function: IFC_fnc_addResources
    Description: Adds (or subtracts) minerals to a player's resource pool.
                 Server-authoritative — if called on a client, it redirects
                 to the server via remoteExecCall.
                 Minerals are floored at 0 (cannot go negative).

    Parameters:
        0: OBJECT  - The player object
        1: NUMBER  - Mineral amount to add (negative to subtract)
        2: NUMBER  - (Optional) Supply cap adjustment (default 0)
    Returns: Nothing
    Author: IFC Dev
*/

params [
    ["_player", objNull, [objNull]],
    ["_minerals", 0, [0]],
    ["_supply", 0, [0]]
];

// Server authority redirect — if called on client, forward to server
if (!isServer) exitWith {
    [_player, _minerals, _supply] remoteExecCall ["IFC_fnc_addResources", 2];
};

if (isNull _player) exitWith {
    diag_log "IFC: addResources — null player, aborting";
};

// Add minerals (floor at 0)
private _currentMinerals = _player getVariable ["IFC_minerals", 0];
_player setVariable ["IFC_minerals", ((_currentMinerals + _minerals) max 0), true];

// Adjust supply cap if requested
if (_supply != 0) then {
    private _currentCap = _player getVariable ["IFC_supply_cap", 0];
    _player setVariable ["IFC_supply_cap", ((_currentCap + _supply) max 0), true];
};

// TEST: Open debug console, run:
// [player, 100] call IFC_fnc_addResources;
// Expected: player getVariable "IFC_minerals" increases by 100
//
// [player, -999] call IFC_fnc_addResources;
// Expected: player getVariable "IFC_minerals" becomes 0 (floored, not negative)
//
// [player, 0, 5] call IFC_fnc_addResources;
// Expected: player getVariable "IFC_supply_cap" increases by 5
