/*
    Function: IFC_fnc_spendResources
    Description: Attempts to spend minerals and supply for a player.
                 Server-authoritative — if called on client, redirects to server.
                 Checks affordability first; deducts minerals and increases
                 supply_used on success.

    Parameters:
        0: OBJECT  - The player object
        1: NUMBER  - Mineral cost to deduct
        2: NUMBER  - (Optional) Supply cost to consume (default 0)
    Returns: BOOL - true if purchase succeeded, false if insufficient resources
    Author: IFC Dev
*/

params [
    ["_player", objNull, [objNull]],
    ["_mineralCost", 0, [0]],
    ["_supplyCost", 0, [0]]
];

// Server authority redirect — if called on client, forward to server
if (!isServer) exitWith {
    [_player, _mineralCost, _supplyCost] remoteExecCall ["IFC_fnc_spendResources", 2];
};

if (isNull _player) exitWith {
    diag_log "IFC: spendResources — null player, aborting";
    false
};

// Check if the player can afford this purchase
if !([_player, _mineralCost, _supplyCost] call IFC_fnc_canAfford) exitWith {
    diag_log format ["IFC: spendResources — %1 cannot afford %2 minerals, %3 supply",
        name _player, _mineralCost, _supplyCost];
    false
};

// Deduct minerals
private _currentMinerals = _player getVariable ["IFC_minerals", 0];
_player setVariable ["IFC_minerals", (_currentMinerals - _mineralCost) max 0, true];

// Increase supply used
if (_supplyCost > 0) then {
    private _currentSupplyUsed = _player getVariable ["IFC_supply_used", 0];
    _player setVariable ["IFC_supply_used", _currentSupplyUsed + _supplyCost, true];
};

true

// TEST: Open debug console, run:
// [player, 50, 1] call IFC_fnc_spendResources;
// Expected: minerals decrease by 50 (200→150), supply_used increases by 1 (0→1)
// HUD updates within 0.5s to show new values
//
// [player, 9999] call IFC_fnc_spendResources;
// Expected: returns false, no change to minerals or supply (insufficient funds)
