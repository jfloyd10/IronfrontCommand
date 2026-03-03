/*
    Function: IFC_fnc_updateHUD
    Description: Updates the resource HUD overlay with current player resource
                 values. Called every 0.5 seconds by a CBA per-frame handler.
                 Client-side only — reads broadcasted variables and updates
                 ctrlSetText on HUD controls.

    Parameters: None (reads from player object)
    Returns: Nothing
    Author: IFC Dev
*/

if (!hasInterface) exitWith {};

// Get the HUD display from uiNamespace (set by onLoad in CfgRscTitles)
private _display = uiNamespace getVariable ["IFC_ResourceHUD", displayNull];
if (isNull _display) exitWith {};

// Read current resource values from player object
private _minerals   = player getVariable ["IFC_minerals", 0];
private _supplyUsed = player getVariable ["IFC_supply_used", 0];
private _supplyCap  = player getVariable ["IFC_supply_cap", 0];
private _nodeIncome = player getVariable ["IFC_nodeIncome", 0];

// Calculate total income per tick
private _totalIncome = IFC_mineralsPerTick_base + _nodeIncome;

// Update HUD controls
// IDC 1003: Mineral count (gold text)
(_display displayCtrl 1003) ctrlSetText (str _minerals);

// IDC 1004: Supply used/cap (cyan text)
(_display displayCtrl 1004) ctrlSetText format ["Supply: %1/%2", _supplyUsed, _supplyCap];

// IDC 1005: Income rate (green text)
(_display displayCtrl 1005) ctrlSetText format ["+%1/tick", _totalIncome];

// TEST: After mission starts with HUD visible:
// player setVariable ["IFC_minerals", 500, true];
// Expected: Within 0.5s, HUD mineral text updates to "500"
//
// player setVariable ["IFC_supply_used", 3, true];
// Expected: Within 0.5s, HUD supply text updates to "Supply: 3/10"
