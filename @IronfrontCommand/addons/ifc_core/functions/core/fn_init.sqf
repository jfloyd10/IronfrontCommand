/*
    Function: IFC_fnc_init
    Description: Initializes global definitions, constants, and data tables for
                 the Ironfront Command mod. Must be called on both server and
                 all clients before any other IFC systems are used.

    Parameters: None
    Returns: Nothing
    Author: IFC Dev
*/

// Guard against double initialization
if (!isNil "IFC_initialized") exitWith {};
IFC_initialized = true;

// ============================================================================
// Global Constants
// ============================================================================
IFC_resourceTickInterval = 8;   // Seconds between resource ticks
IFC_mineralsPerTick_base = 25;  // Base mineral income per tick (from HQ)

// ============================================================================
// Building Definitions
// [id, displayName, classname, mineralCost, buildTime(s), supplyProvided, category]
// ============================================================================
IFC_buildingDefs = [
    ["HQ",        "Headquarters",  "Land_Cargo_HQ_V1_F",     0,   0,  10, "core"],
    ["BARRACKS",  "Barracks",      "Land_Cargo_Tower_V1_F",  150, 45, 0,  "infantry"],
    ["HANGAR",    "Hangar",        "Land_TentHangar_V1_F",   300, 90, 0,  "air"],
    ["ARMORY",    "Armory",        "Land_Cargo_Patrol_V1_F", 200, 60, 0,  "vehicles"],
    ["DEPOT",     "Supply Depot",  "Land_Cargo_House_V1_F",  100, 30, 8,  "supply"],
    ["TURRET",    "Defense Tower", "Land_BagFence_01_long_F",100, 20, 0,  "defense"]
];

// ============================================================================
// Unit Definitions
// [id, displayName, unitClass, mineralCost, supplyCost, trainTime(s), requiredBuilding]
// ============================================================================
IFC_unitDefs = [
    ["RIFLEMAN",    "Rifleman",         "B_Soldier_F",                    50,  1, 10, "BARRACKS"],
    ["MEDIC",       "Medic",            "B_medic_F",                      75,  1, 12, "BARRACKS"],
    ["MG_GUNNER",   "Machinegunner",    "B_HeavyGunner_F",              100,  2, 15, "BARRACKS"],
    ["SNIPER",      "Sniper",           "B_sniper_F",                    125,  2, 18, "BARRACKS"],
    ["AT_SOLDIER",  "Anti-Tank",        "B_soldier_AT_F",                150,  2, 20, "BARRACKS"],
    ["APC",         "Armored Carrier",  "B_APC_Wheeled_01_cannon_F",     400,  4, 40, "ARMORY"],
    ["MBT",         "Main Battle Tank", "B_MBT_01_cannon_F",             600,  6, 60, "ARMORY"],
    ["HELICOPTER",  "Attack Helo",      "B_Heli_Attack_01_F",            500,  4, 50, "HANGAR"],
    ["TRANSPORT",   "Transport Helo",   "B_Heli_Transport_03_F",         300,  3, 35, "HANGAR"],
    ["JET",         "CAS Jet",          "B_Plane_CAS_01_F",              700,  5, 70, "HANGAR"]
];

// ============================================================================
// Lookup Helpers
// ============================================================================
IFC_fnc_getBuildingDef = {
    params [["_id", "", [""]]];
    private _result = IFC_buildingDefs select { (_x select 0) == _id };
    _result param [0, []]
};

IFC_fnc_getUnitDef = {
    params [["_id", "", [""]]];
    private _result = IFC_unitDefs select { (_x select 0) == _id };
    _result param [0, []]
};

// ============================================================================
// Global State Flags (client-side defaults)
// ============================================================================
IFC_inCommanderMode = false;
IFC_selectedUnits = [];
IFC_placementMode = false;

diag_log "IFC: Init complete — definitions loaded";

// TEST: Open debug console, run:
// [] call IFC_fnc_init;
// Expected: IFC_buildingDefs has 6 entries, IFC_unitDefs has 10 entries
// ["BARRACKS"] call IFC_fnc_getBuildingDef  → returns barracks definition array
// ["RIFLEMAN"] call IFC_fnc_getUnitDef  → returns rifleman definition array
