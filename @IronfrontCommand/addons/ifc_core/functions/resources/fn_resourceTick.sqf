/*
    Function: IFC_fnc_resourceTick
    Description: Server-only looping script that awards passive mineral income
                 to all living, non-eliminated players every tick interval.
                 Income = base HQ income + bonus from captured resource nodes.
                 Must be called via spawn (uses sleep).

    Parameters: None
    Returns: Nothing (loops forever)
    Author: IFC Dev
*/

if (!isServer) exitWith {};

diag_log format ["IFC: Resource tick started — interval: %1s, base income: %2",
    IFC_resourceTickInterval, IFC_mineralsPerTick_base];

while {true} do {
    {
        private _player = _x;

        // Skip dead players
        if (!alive _player) then { continue };

        // Skip eliminated players
        if (_player getVariable ["IFC_isEliminated", false]) then { continue };

        // Calculate total income: base HQ + captured node bonuses
        private _income = IFC_mineralsPerTick_base;
        private _nodeBonus = _player getVariable ["IFC_nodeIncome", 0];
        _income = _income + _nodeBonus;

        // Award minerals (server-authoritative)
        [_player, _income, 0] call IFC_fnc_addResources;

    } forEach allPlayers;

    sleep IFC_resourceTickInterval;
};

// TEST: After calling [] call IFC_fnc_initServer, wait 8 seconds.
// player getVariable "IFC_minerals" should increase by 25 each tick.
// Starting at 200: after 8s → 225, after 16s → 250, after 24s → 275
