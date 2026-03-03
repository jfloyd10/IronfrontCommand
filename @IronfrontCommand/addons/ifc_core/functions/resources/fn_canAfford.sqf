/*
    Function: IFC_fnc_canAfford
    Description: Checks whether a player has enough minerals and supply room
                 for a given cost. Pure read operation — safe to call on any
                 machine (client or server).

    Parameters:
        0: OBJECT  - The player object
        1: NUMBER  - Mineral cost to check
        2: NUMBER  - (Optional) Supply cost to check (default 0)
    Returns: BOOL - true if player can afford, false otherwise
    Author: IFC Dev
*/

params [
    ["_player", objNull, [objNull]],
    ["_mineralCost", 0, [0]],
    ["_supplyCost", 0, [0]]
];

if (isNull _player) exitWith { false };

private _minerals = _player getVariable ["IFC_minerals", 0];
private _supplyUsed = _player getVariable ["IFC_supply_used", 0];
private _supplyCap = _player getVariable ["IFC_supply_cap", 0];

// Can afford if: have enough minerals AND adding supply won't exceed cap
(_minerals >= _mineralCost) && {(_supplyUsed + _supplyCost) <= _supplyCap}

// TEST: Open debug console, run:
// [player, 100] call IFC_fnc_canAfford;
// Expected: true (player starts with 200 minerals)
//
// [player, 9999] call IFC_fnc_canAfford;
// Expected: false (not enough minerals)
//
// [player, 10, 5] call IFC_fnc_canAfford;
// Expected: true (10 minerals affordable, 0+5 <= 10 supply cap)
//
// [player, 10, 11] call IFC_fnc_canAfford;
// Expected: false (0+11 > 10 supply cap)
