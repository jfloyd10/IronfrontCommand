# CLAUDE.md — Arma 3 RTS Mod: "IRONFRONT COMMAND"
> A StarCraft 2-inspired Real-Time Strategy game mode for Arma 3

---

## ✅ FEASIBILITY VERDICT: YES — This Is Fully Buildable

Arma 3's SQF scripting engine, config-based UI framework, Zeus infrastructure, and multiplayer 
networking make this entirely achievable. Key engine capabilities that confirm feasibility:

- `createVehicle` / `createUnit` / `createGroup` → spawn buildings and troops dynamically
- `BIS_fnc_camera` + custom scripted cameras → Commander (RTS) overhead mode
- `selectPlayer` + `selectNoPlayer` → toggle between commander and unit control
- Arma's `RscDisplays` / `ctrlCreate` system → full custom UI (resource bars, build menus, minimaps)
- `setVariable` / `getVariable` with JIP (Join In Progress) → multiplayer-safe state sync
- `addMPEventHandler` / `remoteExec` → network-safe calls across clients and server
- CBA_A3 (Community Base Addons) → settings, keybindings, per-frame handlers
- Zeus (`BIS_fnc_activateCurator`) → proven RTS-style camera system to reference/extend

**Key constraint to plan around:** Arma 3 is NOT a native RTS engine. Every RTS mechanic 
(fog of war, resource ticking, build queues, minimap) must be scripted from scratch in SQF.
Performance caps at ~200–300 active AI units before FPS degrades significantly. Design accordingly.

---

## 📁 PROJECT STRUCTURE

```
@IronfrontCommand/
├── mod.cpp
├── meta.cpp
├── addons/
│   └── ifc_core/
│       ├── $PBOPREFIX$
│       ├── config.cpp                  ← Master config: CfgPatches, CfgFunctions, CfgSounds, UI classes
│       ├── CfgFunctions.hpp
│       ├── CfgVehicles.hpp             ← Building class definitions
│       ├── CfgMissions.hpp
│       ├── UI/
│       │   ├── CfgRscTitles.hpp        ← HUD overlays
│       │   ├── dialog_buildmenu.hpp    ← Build menu dialog
│       │   ├── dialog_hq.hpp           ← HQ interaction dialog
│       │   └── ifc_hud.hpp             ← Resource bar, minimap overlay
│       ├── functions/
│       │   ├── core/
│       │   │   ├── fn_init.sqf
│       │   │   ├── fn_initServer.sqf
│       │   │   ├── fn_initPlayer.sqf
│       │   │   └── fn_moduleInit.sqf
│       │   ├── resources/
│       │   │   ├── fn_resourceTick.sqf
│       │   │   ├── fn_addResources.sqf
│       │   │   ├── fn_spendResources.sqf
│       │   │   ├── fn_canAfford.sqf
│       │   │   └── fn_syncResources.sqf
│       │   ├── buildings/
│       │   │   ├── fn_placeBuilding.sqf
│       │   │   ├── fn_buildingPreview.sqf
│       │   │   ├── fn_cancelBuild.sqf
│       │   │   ├── fn_completeBuild.sqf
│       │   │   ├── fn_destroyBuilding.sqf
│       │   │   └── fn_getBuildingsByFaction.sqf
│       │   ├── production/
│       │   │   ├── fn_trainUnit.sqf
│       │   │   ├── fn_buildQueue.sqf
│       │   │   ├── fn_completeUnit.sqf
│       │   │   └── fn_getProductionBuildings.sqf
│       │   ├── camera/
│       │   │   ├── fn_enterCommanderMode.sqf
│       │   │   ├── fn_exitCommanderMode.sqf
│       │   │   ├── fn_cameraUpdate.sqf
│       │   │   ├── fn_cameraEdgeScroll.sqf
│       │   │   └── fn_cameraZoom.sqf
│       │   ├── selection/
│       │   │   ├── fn_selectUnit.sqf
│       │   │   ├── fn_boxSelect.sqf
│       │   │   ├── fn_issueMove.sqf
│       │   │   ├── fn_issueAttack.sqf
│       │   │   └── fn_issueStop.sqf
│       │   ├── resources_nodes/
│       │   │   ├── fn_initResourceNode.sqf
│       │   │   ├── fn_captureNode.sqf
│       │   │   └── fn_nodePassiveTick.sqf
│       │   ├── ui/
│       │   │   ├── fn_openBuildMenu.sqf
│       │   │   ├── fn_closeBuildMenu.sqf
│       │   │   ├── fn_updateHUD.sqf
│       │   │   ├── fn_showMinimap.sqf
│       │   │   └── fn_buildingActionMenu.sqf
│       │   ├── fog_of_war/
│       │   │   ├── fn_fowInit.sqf
│       │   │   ├── fn_fowUpdate.sqf
│       │   │   └── fn_fowReveal.sqf
│       │   └── win_conditions/
│       │       ├── fn_checkWinCondition.sqf
│       │       ├── fn_playerEliminated.sqf
│       │       └── fn_endGame.sqf
│       └── textures/
│           ├── ui_resource_icon.paa
│           ├── ui_supply_icon.paa
│           └── minimap_icons/
└── missions/
    └── IFC_2p_Altis.Altis/
        ├── mission.sqm
        ├── description.ext
        ├── init.sqf
        └── briefing.sqf
```

---

## 🧠 CORE SYSTEMS OVERVIEW

### System 1: Resource Engine
### System 2: Building Placement & Construction
### System 3: Unit Production Queue
### System 4: Commander Camera Mode
### System 5: Unit Selection & Orders
### System 6: Resource Nodes (Harvesting)
### System 7: HUD & UI
### System 8: Fog of War
### System 9: Win Conditions & Game Flow
### System 10: Multiplayer Sync Layer

---

## 🔧 TECHNICAL CONVENTIONS

```sqf
// All mod variables namespaced: IFC_
// Server-authoritative: all resource mutations run on server via remoteExecCall
// Client-side: camera, UI, selection are purely local
// CBA per-frame handler for camera: "IFC_camera_perFrame"
// CBA per-frame handler for HUD updates: "IFC_hud_perFrame"
// Resource tick uses a looping script on server only (isServer check)
// Buildings stored in: missionNamespace getVariable "IFC_buildings_<side>"  (array of objects)
// Player resources: player getVariable ["IFC_resources", [0, 0]]  → [minerals, supply_used]
```

### SQF Coding Standards
- All functions must check `if (!isServer)` or `if (!hasInterface)` where appropriate
- Use `params` macro at top of every function for argument validation
- All `remoteExec` calls must use `[args, "IFC_fnc_name", target, JIP]` pattern
- Never use `sleep` in UI or camera functions — use CBA `addPerFrameHandler`
- Building objects use `setVariable ["IFC_buildingData", hashmap]` for metadata storage
- Groups use `setVariable ["IFC_ownerUID", getPlayerUID player]` to track ownership

---

## 📦 PHASE 1 — Foundation & Resource System

**Goal:** Establish the core resource economy that all other systems depend on.

### 1.1 — Config Setup (`config.cpp`)

```cpp
// config.cpp skeleton
class CfgPatches {
    class IFC_Core {
        name = "Ironfront Command - Core";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.98;
        requiredAddons[] = {"cba_main"};
        version = "0.1.0";
        author = "YourName";
    };
};

#include "CfgFunctions.hpp"
#include "UI\CfgRscTitles.hpp"
#include "CfgVehicles.hpp"
```

```cpp
// CfgFunctions.hpp
class CfgFunctions {
    class IFC {
        class Core {
            file = "addons\ifc_core\functions\core";
            class init {};
            class initServer {};
            class initPlayer {};
        };
        class Resources {
            file = "addons\ifc_core\functions\resources";
            class resourceTick {};
            class addResources {};
            class spendResources {};
            class canAfford {};
            class syncResources {};
        };
        class Buildings {
            file = "addons\ifc_core\functions\buildings";
            class placeBuilding {};
            class buildingPreview {};
            class completeBuild {};
            class destroyBuilding {};
        };
        class Camera {
            file = "addons\ifc_core\functions\camera";
            class enterCommanderMode {};
            class exitCommanderMode {};
            class cameraUpdate {};
        };
        // ... etc for all systems
    };
};
```

### 1.2 — Resource Data Model

Each player has two resource types mirroring StarCraft:
- **Minerals** (primary currency) — earned from resource nodes + passive HQ income
- **Supply** (unit cap) — capacity provided by buildings, consumed by units

```sqf
// fn_initPlayer.sqf — runs on each client when they join
params ["_player"];

// Initialize resource variables on the player object (server-authoritative copy on server)
if (isServer) then {
    _player setVariable ["IFC_minerals", 200, true];     // Starting minerals, broadcast=true
    _player setVariable ["IFC_supply_used", 0, true];
    _player setVariable ["IFC_supply_cap", 10, true];    // HQ provides initial 10 supply
    _player setVariable ["IFC_buildings", [], true];
    _player setVariable ["IFC_units", [], true];
    _player setVariable ["IFC_isEliminated", false, true];
};

// Client-side: register HUD update handler
if (hasInterface) then {
    ["IFC_hud_perFrame", {
        [] call IFC_fnc_updateHUD;
    }, 0.5] call CBA_fnc_addPerFrameHandler;  // Update HUD every 0.5 seconds
};
```

### 1.3 — Resource Tick (Server Only)

```sqf
// fn_resourceTick.sqf — looping server script
// Runs on server, awards passive income every tick interval

IFC_resourceTickInterval = 8;  // seconds between ticks
IFC_mineralsPerTick_base = 25; // base income per HQ

if (!isServer) exitWith {};

while {true} do {
    {
        private _player = _x;
        if (!alive _player) then { continue };
        if (_player getVariable ["IFC_isEliminated", false]) then { continue };
        
        // Base HQ income
        private _income = IFC_mineralsPerTick_base;
        
        // Bonus income from captured resource nodes
        private _nodeBonus = _player getVariable ["IFC_nodeIncome", 0];
        _income = _income + _nodeBonus;
        
        // Award resources
        [_player, _income, 0] call IFC_fnc_addResources;
        
    } forEach (allPlayers select { side _x == (side _x) }); // iterate all living players
    // NOTE: In multiplayer, iterate per-faction group leaders or all players
    
    sleep IFC_resourceTickInterval;
};
```

### 1.4 — Resource Functions

```sqf
// fn_addResources.sqf
params ["_player", "_minerals", ["_supply", 0]];
if (!isServer) exitWith { [_player, _minerals, _supply] remoteExecCall ["IFC_fnc_addResources", 2] };

private _current = _player getVariable ["IFC_minerals", 0];
_player setVariable ["IFC_minerals", (_current + _minerals) max 0, true];

// Trigger HUD sync event
["IFC_resourceChanged", [_player]] call CBA_fnc_serverEvent;
```

```sqf
// fn_canAfford.sqf — returns bool, runs on client for UI checks
params ["_player", "_mineralCost", ["_supplyCost", 0]];

private _minerals = _player getVariable ["IFC_minerals", 0];
private _supplyUsed = _player getVariable ["IFC_supply_used", 0];
private _supplyCap = _player getVariable ["IFC_supply_cap", 0];

(_minerals >= _mineralCost) && ((_supplyUsed + _supplyCost) <= _supplyCap)
```

```sqf
// fn_spendResources.sqf — server authoritative
params ["_player", "_mineralCost", ["_supplyCost", 0]];
if (!isServer) exitWith { [_player, _mineralCost, _supplyCost] remoteExecCall ["IFC_fnc_spendResources", 2] };

if !([_player, _mineralCost, _supplyCost] call IFC_fnc_canAfford) exitWith {
    ["IFC_purchaseFailed", [_player, "Insufficient resources"]] call CBA_fnc_serverEvent;
};

private _minerals = _player getVariable ["IFC_minerals", 0];
private _supplyUsed = _player getVariable ["IFC_supply_used", 0];

_player setVariable ["IFC_minerals", _minerals - _mineralCost, true];
_player setVariable ["IFC_supply_used", _supplyUsed + _supplyCost, true];
true  // return success
```

---

## 📦 PHASE 2 — Buildings System

**Goal:** Players can select a building type, preview placement, confirm, and the building 
constructs over time.

### 2.1 — Building Definitions (Data-Driven Config)

```sqf
// fn_init.sqf — define all buildable structures
IFC_buildingDefs = [
    // [id, displayName, classname, mineralCost, buildTime(s), supplyProvided, category]
    ["HQ",        "Headquarters",  "Land_Cargo_HQ_V1_F",     0,   0,  10, "core"],
    ["BARRACKS",  "Barracks",      "Land_Cargo_Tower_V1_F",  150, 45, 0,  "infantry"],
    ["HANGAR",    "Hangar",        "Land_TentHangar_V1_F",   300, 90, 0,  "air"],
    ["ARMORY",    "Armory",        "Land_Cargo_Patrol_V1_F", 200, 60, 0,  "vehicles"],
    ["DEPOT",     "Supply Depot",  "Land_Cargo_House_V1_F",  100, 30, 8,  "supply"],
    ["TURRET",    "Defense Tower", "Land_BagFence_01_long_F",100, 20, 0,  "defense"]
];

// Lookup helper
IFC_fnc_getBuildingDef = {
    params ["_id"];
    (IFC_buildingDefs select { (_x select 0) == _id }) param [0, []]
};
```

### 2.2 — Building Placement Flow

```sqf
// fn_placeBuilding.sqf
// Called on client when player selects a building from build menu
// Enters placement preview mode — player clicks terrain to confirm position

params ["_buildingID"];

if (!(hasInterface)) exitWith {};

// Check player can afford it
private _def = [_buildingID] call IFC_fnc_getBuildingDef;
if (_def isEqualTo []) exitWith { hint "Unknown building type." };

private _cost = _def select 3;
if !([player, _cost] call IFC_fnc_canAfford) exitWith {
    ["IFC_ui_showMessage", ["Not enough minerals!"]] call CBA_fnc_localEvent;
};

// Enter placement mode — store pending build
IFC_pendingBuild = _buildingID;
IFC_placementMode = true;

// Create a ghost/preview object that follows the mouse
private _ghostClass = _def select 2;
IFC_previewObject = createVehicle [_ghostClass, player modelToWorld [0,10,0], [], 0, "CAN_COLLIDE"];
IFC_previewObject allowDamage false;
IFC_previewObject setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.4)"];  // Green ghost

// Per-frame handler: move preview to cursor position
["IFC_placement_perFrame", {
    if (!IFC_placementMode) exitWith {
        [CBA_PFH_ID] call CBA_fnc_removePerFrameHandler;
    };
    private _pos = screenToWorld (getMousePosition select [0,2]);
    _pos set [2, 0];  // Snap to ground
    IFC_previewObject setPosASL (AGLToASL _pos);
    
    // Color feedback: red if invalid position
    private _isValid = [IFC_previewObject] call IFC_fnc_isValidBuildPosition;
    if (_isValid) then {
        IFC_previewObject setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.4)"];
        IFC_buildPositionValid = true;
    } else {
        IFC_previewObject setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,0.4)"];
        IFC_buildPositionValid = false;
    };
}, 0] call CBA_fnc_addPerFrameHandler;

// Mouse click handler to confirm placement
["IFC_placement_click"] call IFC_fnc_registerPlacementClick;
```

```sqf
// fn_completeBuild.sqf — SERVER SIDE — called after buildTime elapses
params ["_buildingClass", "_pos", "_dir", "_ownerUID", "_buildingID"];
if (!isServer) exitWith {};

private _owner = allPlayers select { getPlayerUID _x == _ownerUID } param [0, objNull];

// Spawn the real building object
private _building = createVehicle [_buildingClass, _pos, [], _dir, "NONE"];
_building allowDamage true;

// Tag building with metadata
_building setVariable ["IFC_owner", _ownerUID, true];
_building setVariable ["IFC_buildingID", _buildingID, true];
_building setVariable ["IFC_isComplete", true, true];

// Add to owner's building list
if (!isNull _owner) then {
    private _buildings = _owner getVariable ["IFC_buildings", []];
    _buildings pushBack _building;
    _owner setVariable ["IFC_buildings", _buildings, true];
    
    // Apply supply bonus if any
    private _def = [_buildingID] call IFC_fnc_getBuildingDef;
    private _supplyGain = _def select 5;
    if (_supplyGain > 0) then {
        private _cap = _owner getVariable ["IFC_supply_cap", 0];
        _owner setVariable ["IFC_supply_cap", _cap + _supplyGain, true];
    };
};

// Add action menu for interaction when player is near
_building addAction ["Open Building Menu", {
    params ["_target", "_caller", "_id", "_args"];
    [_target] call IFC_fnc_buildingActionMenu;
}, [], 5, true, true, "", "(_target getVariable ['IFC_isComplete', false])"];

// Register building for fog of war vision
[_building] call IFC_fnc_fowReveal;
```

### 2.3 — Building Validity Check

```sqf
// fn_isValidBuildPosition.sqf
params ["_previewObj"];

private _pos = getPosASL _previewObj;
private _isFlat = (abs ((getPosASL _previewObj) select 2)) < 2;  // Rough slope check

// Check no overlap with existing buildings (10m radius)
private _nearBuildings = _pos nearObjects ["Building", 10];
_nearBuildings = _nearBuildings select { _x getVariable ["IFC_isComplete", false] };

// Must be within player's territory/HQ range (optional: 200m from HQ)
private _playerHQ = player getVariable ["IFC_hqObject", objNull];
private _inRange = if (!isNull _playerHQ) then {
    (_pos distance getPosASL _playerHQ) < 300
} else { true };

(count _nearBuildings == 0) && _inRange && _isFlat
```

---

## 📦 PHASE 3 — Unit Production System

**Goal:** Each building type produces specific units with a queue system and build timer.

### 3.1 — Unit Definitions

```sqf
// Defined in fn_init.sqf
IFC_unitDefs = [
    // [id, displayName, unitClass, mineralCost, supplyCost, trainTime(s), requiredBuilding]
    ["RIFLEMAN",    "Rifleman",         "B_Soldier_F",           50,  1, 10, "BARRACKS"],
    ["MEDIC",       "Medic",            "B_medic_F",             75,  1, 12, "BARRACKS"],
    ["MG_GUNNER",   "Machinegunner",    "B_HeavyGunner_F",       100, 2, 15, "BARRACKS"],
    ["SNIPER",      "Sniper",           "B_sniper_F",            125, 2, 18, "BARRACKS"],
    ["AT_SOLDIER",  "Anti-Tank",        "B_soldier_AT_F",        150, 2, 20, "BARRACKS"],
    ["APC",         "Armored Carrier",  "B_APC_Wheeled_01_cannon_F", 400, 4, 40, "ARMORY"],
    ["MBT",         "Main Battle Tank", "B_MBT_01_cannon_F",    600, 6, 60, "ARMORY"],
    ["HELICOPTER",  "Attack Helo",      "B_Heli_Attack_01_F",   500, 4, 50, "HANGAR"],
    ["TRANSPORT",   "Transport Helo",   "B_Heli_Transport_03_F",300, 3, 35, "HANGAR"],
    ["JET",         "CAS Jet",          "B_Plane_CAS_01_F",     700, 5, 70, "HANGAR"]
];
```

### 3.2 — Production Queue

```sqf
// fn_trainUnit.sqf — client initiates, server authoritative
params ["_unitID", "_building"];

private _def = (IFC_unitDefs select { (_x select 0) == _unitID }) param [0, []];
if (_def isEqualTo []) exitWith {};

private _minCost  = _def select 3;
private _supCost  = _def select 4;
private _trainTime = _def select 5;

// Afford check
if !([player, _minCost, _supCost] call IFC_fnc_canAfford) exitWith {
    ["IFC_ui_showMessage", ["Cannot afford unit!"]] call CBA_fnc_localEvent;
};

// Deduct cost immediately
[player, _minCost, _supCost] call IFC_fnc_spendResources;

// Add to building's queue (server side)
[_building, _unitID, getPlayerUID player, _trainTime] remoteExecCall ["IFC_fnc_buildQueue", 2];
```

```sqf
// fn_buildQueue.sqf — SERVER ONLY
params ["_building", "_unitID", "_ownerUID", "_trainTime"];
if (!isServer) exitWith {};

private _queue = _building getVariable ["IFC_productionQueue", []];
_queue pushBack [_unitID, _ownerUID, _trainTime, diag_tickTime];
_building setVariable ["IFC_productionQueue", _queue, true];

// Start processing queue if not already running
if !(_building getVariable ["IFC_queueRunning", false]) then {
    _building setVariable ["IFC_queueRunning", true, false];
    [_building] spawn {
        params ["_building"];
        while { count (_building getVariable ["IFC_productionQueue", []]) > 0 } do {
            private _queue = _building getVariable ["IFC_productionQueue", []];
            private _item = _queue select 0;
            private _unitID = _item select 0;
            private _ownerUID = _item select 1;
            private _trainTime = _item select 2;
            
            // Broadcast queue update to owner
            private _owner = allPlayers select { getPlayerUID _x == _ownerUID } param [0, objNull];
            if (!isNull _owner) then {
                ["IFC_queueUpdated", [_building, _queue]] call CBA_fnc_targetEvent [_owner];
            };
            
            sleep _trainTime;
            
            // Spawn completed unit near building
            [_unitID, _building, _ownerUID] call IFC_fnc_completeUnit;
            
            // Remove from queue
            _queue deleteAt 0;
            _building setVariable ["IFC_productionQueue", _queue, true];
        };
        _building setVariable ["IFC_queueRunning", false, false];
    };
};
```

```sqf
// fn_completeUnit.sqf — SERVER ONLY
params ["_unitID", "_building", "_ownerUID"];
if (!isServer) exitWith {};

private _def = (IFC_unitDefs select { (_x select 0) == _unitID }) param [0, []];
private _unitClass = _def select 2;

// Find rally point (building's exit or default offset)
private _rallyPos = _building getVariable ["IFC_rallyPoint", 
    (getPosATL _building) vectorAdd [15, 0, 0]];

// Find owner player
private _owner = allPlayers select { getPlayerUID _x == _ownerUID } param [0, objNull];
private _side = if (!isNull _owner) then { side _owner } else { west };
private _group = createGroup [_side, true];

// Create unit
private _unit = _group createUnit [_unitClass, _rallyPos, [], 5, "FORM"];
_unit setVariable ["IFC_owner", _ownerUID, true];
_unit setVariable ["IFC_unitID", _unitID, true];

// Add to owner's unit list
if (!isNull _owner) then {
    private _units = _owner getVariable ["IFC_units", []];
    _units pushBack _unit;
    _owner setVariable ["IFC_units", _units, true];
};

// Notify client
["IFC_unitTrained", [_unitID, _unit]] remoteExecCall ["IFC_fnc_onUnitTrained", _owner];
```

---

## 📦 PHASE 4 — Commander Mode (RTS Camera)

**Goal:** Player can press a key to enter a top-down RTS camera and issue orders to units, 
then press a key to re-inhabit their soldier body.

### 4.1 — Mode Toggle Key

```sqf
// fn_init.sqf — register keybinding via CBA
["IFC", "ToggleCommanderMode", 
    "Toggle Commander / Soldier Mode",
    { [] call IFC_fnc_toggleCommanderMode }, 
    {},  // key up (not needed)
    [DIK_GRAVE, [false, false, false]]  // ` key, no modifiers
] call CBA_fnc_addKeybind;
```

```sqf
// fn_enterCommanderMode.sqf
if (IFC_inCommanderMode) exitWith {};
IFC_inCommanderMode = true;
IFC_lastPlayerPos = getPosASL player;

// Detach from player body — switch to free camera
IFC_commanderCam = "Camera" camCreate (getPosASL player vectorAdd [0, 0, 150]);
IFC_commanderCam camSetTarget (player modelToWorld [0, 50, 0]);
IFC_commanderCam camSetRelPos [0, 0, 150];
IFC_commanderCam camSetFov 0.7;
IFC_commanderCam camCommit 0;
IFC_commanderCam cameraEffect ["INTERNAL", "BACK"];

// Hide player and disable AI interference while in commander mode
player enableSimulation false;  // Keep alive but freeze
showHUD false;

// Start commander camera per-frame handler
["IFC_cmd_camera", {
    [] call IFC_fnc_cameraUpdate;
}, 0] call CBA_fnc_addPerFrameHandler;

// Show commander HUD overlay
[] call IFC_fnc_showCommanderHUD;

hint "COMMANDER MODE — Press ` to return to your unit";
```

```sqf
// fn_exitCommanderMode.sqf
if (!IFC_inCommanderMode) exitWith {};
IFC_inCommanderMode = false;

// Destroy camera, return control to player body
IFC_commanderCam cameraEffect ["TERMINATE", "BACK"];
camDestroy IFC_commanderCam;
showHUD true;
player enableSimulation true;

// Remove camera PFH
["IFC_cmd_camera"] call CBA_fnc_removeNamedPerFrameHandlers;

// Restore camera to player
camera setPos (getPosASL player);
hint "SOLDIER MODE — Press ` to enter Commander Mode";
```

### 4.2 — Camera Movement

```sqf
// fn_cameraUpdate.sqf — runs every frame during commander mode
if (!IFC_inCommanderMode) exitWith {};

private _camPos = getPosASL IFC_commanderCam;
private _moveSpeed = IFC_camHeight * 0.01;  // Speed scales with altitude
private _moveVec = [0, 0, 0];

// WASD / Arrow key movement
if (inputAction "MoveForward" > 0.1)  then { _moveVec set [1, _moveVec#1 + _moveSpeed] };
if (inputAction "MoveBack" > 0.1)     then { _moveVec set [1, _moveVec#1 - _moveSpeed] };
if (inputAction "MoveLeft" > 0.1)     then { _moveVec set [0, _moveVec#0 - _moveSpeed] };
if (inputAction "MoveRight" > 0.1)    then { _moveVec set [0, _moveVec#0 + _moveSpeed] };

// Edge scrolling (mouse near screen edge)
private _mouse = getMousePosition;
if (_mouse select 0 < 0.02) then { _moveVec set [0, _moveVec#0 - _moveSpeed] };
if (_mouse select 0 > 0.98) then { _moveVec set [0, _moveVec#0 + _moveSpeed] };
if (_mouse select 1 < 0.02) then { _moveVec set [1, _moveVec#1 + _moveSpeed] };
if (_mouse select 1 > 0.98) then { _moveVec set [1, _moveVec#1 - _moveSpeed] };

// Scroll wheel zoom
private _scroll = inputAction "zoomIn" - inputAction "zoomOut";
IFC_camHeight = (IFC_camHeight - (_scroll * 10)) max 30 min 500;
_camPos set [2, IFC_camHeight];

IFC_commanderCam setPosASL (_camPos vectorAdd _moveVec);
IFC_commanderCam camCommit 0;
```

---

## 📦 PHASE 5 — Unit Selection & Orders System

**Goal:** In commander mode, player can click/box-select units and right-click to issue Move/Attack orders.

### 5.1 — Unit Selection

```sqf
// fn_selectUnit.sqf — handles single click unit selection
params ["_screenPos"];

if (!IFC_inCommanderMode) exitWith {};

private _worldPos = screenToWorld _screenPos;
private _myUID = getPlayerUID player;

// Find units near the clicked world position that belong to this player
private _candidates = (allUnits select {
    (_x getVariable ["IFC_owner", ""]) == _myUID &&
    alive _x &&
    (_worldPos distance2D getPosATL _x) < 5
});

// Deselect all current selection
{
    _x setVariable ["IFC_selected", false, false];
    // Remove selection marker
} forEach IFC_selectedUnits;
IFC_selectedUnits = [];

if (count _candidates > 0) then {
    private _unit = _candidates select 0;
    _unit setVariable ["IFC_selected", true, false];
    IFC_selectedUnits = [_unit];
    [] call IFC_fnc_showUnitSelectionUI;
};
```

```sqf
// fn_boxSelect.sqf — drag-select multiple units
params ["_screenStart", "_screenEnd"];
if (!IFC_inCommanderMode) exitWith {};

private _myUID = getPlayerUID player;

// Convert screen rect to world bounding
// ... (use screenToWorld on all four corners, find 2D bounds)
// Select all owned living units within that 2D bounding box

IFC_selectedUnits = allUnits select {
    (_x getVariable ["IFC_owner", ""]) == _myUID &&
    alive _x &&
    // unit's screen pos is within _screenStart to _screenEnd
    {
        private _sp = worldToScreen getPosATL _x;
        (_sp select 0) > (_screenStart select 0) min (_screenEnd select 0) &&
        (_sp select 0) < (_screenStart select 0) max (_screenEnd select 0) &&
        (_sp select 1) > (_screenStart select 1) min (_screenEnd select 1) &&
        (_sp select 1) < (_screenStart select 1) max (_screenEnd select 1)
    }
};

{
    _x setVariable ["IFC_selected", true, false];
} forEach IFC_selectedUnits;

[] call IFC_fnc_showUnitSelectionUI;
```

### 5.2 — Issuing Orders

```sqf
// fn_issueMove.sqf — right-click move order to selected units
params ["_targetPos"];
if (count IFC_selectedUnits == 0) exitWith {};

// Formation offset so units don't stack
private _i = 0;
{
    private _offset = [(_i mod 5) * 4, floor(_i / 5) * 4, 0];
    private _finalPos = _targetPos vectorAdd _offset;
    
    // Order unit to move (via server to maintain authority)
    [_x, _finalPos] remoteExecCall ["IFC_fnc_orderMove", 2];
    _i = _i + 1;
} forEach IFC_selectedUnits;

// Visual waypoint marker at target
[] call IFC_fnc_showMoveMarker;
```

```sqf
// fn_orderMove.sqf — SERVER: actually commands the AI unit
params ["_unit", "_pos"];
if (!isServer) exitWith {};

private _group = group _unit;
_group setCurrentWaypoint [_group addWaypoint [_pos, 0, 0, ""]];
[_group] orderGetIn false;
_unit doMove _pos;
```

```sqf
// fn_issueAttack.sqf — right-click on enemy unit
params ["_targetUnit"];
if (count IFC_selectedUnits == 0) exitWith {};
if (alive _targetUnit) then {
    [IFC_selectedUnits, _targetUnit] remoteExecCall ["IFC_fnc_orderAttack", 2];
};
```

---

## 📦 PHASE 6 — Resource Nodes

**Goal:** Neutral resource nodes on the map can be captured to generate bonus income, 
mirroring SC2's mineral fields. Nodes must be physically held (units nearby).

### 6.1 — Node Initialization (placed in editor or spawned)

```sqf
// fn_initResourceNode.sqf
// Attach to a trigger or object placed in the mission editor

params ["_nodeObject", "_incomePerTick"];

_nodeObject setVariable ["IFC_isResourceNode", true, true];
_nodeObject setVariable ["IFC_nodeIncome", _incomePerTick, true];
_nodeObject setVariable ["IFC_nodeOwner", "", true];  // UID or "" for neutral

// Visual marker
private _marker = createMarkerLocal [
    format ["IFC_node_%1", _nodeObject],
    getPosATL _nodeObject
];
_marker setMarkerTypeLocal "hd_dot";
_marker setMarkerColorLocal "ColorYellow";
_marker setMarkerTextLocal format ["Resource +%1", _incomePerTick];

// Server: check for capture every 3 seconds
if (isServer) then {
    [_nodeObject] spawn {
        params ["_node"];
        while { !isNull _node } do {
            sleep 3;
            [_node] call IFC_fnc_captureNode;
        };
    };
};
```

```sqf
// fn_captureNode.sqf — SERVER
params ["_node"];

private _pos = getPosATL _node;
private _radius = 30;

// Find all players/units in radius
private _unitsNear = _pos nearEntities [["Man", "LandVehicle", "Air"], _radius];

// Tally sides present
private _sidesPresent = [];
{
    private _owner = _x getVariable ["IFC_owner", ""];
    if (_owner != "" && alive _x) then {
        _sidesPresent pushBackUnique _owner;
    };
} forEach _unitsNear;

private _currentOwner = _node getVariable ["IFC_nodeOwner", ""];
private _income = _node getVariable ["IFC_nodeIncome", 0];

// Contested: multiple sides present, no capture
if (count _sidesPresent > 1) exitWith {
    // Update marker to contested
    private _marker = format ["IFC_node_%1", _node];
    _marker setMarkerColor "ColorOrange";
};

// Capture: single side present
if (count _sidesPresent == 1) then {
    private _newOwner = _sidesPresent select 0;
    if (_newOwner != _currentOwner) then {
        // Remove income from old owner
        if (_currentOwner != "") then {
            private _oldPlayer = allPlayers select { getPlayerUID _x == _currentOwner } param [0, objNull];
            if (!isNull _oldPlayer) then {
                private _oldIncome = _oldPlayer getVariable ["IFC_nodeIncome", 0];
                _oldPlayer setVariable ["IFC_nodeIncome", (_oldIncome - _income) max 0, true];
            };
        };
        // Give income to new owner
        private _newPlayer = allPlayers select { getPlayerUID _x == _newOwner } param [0, objNull];
        if (!isNull _newPlayer) then {
            private _curIncome = _newPlayer getVariable ["IFC_nodeIncome", 0];
            _newPlayer setVariable ["IFC_nodeIncome", _curIncome + _income, true];
        };
        _node setVariable ["IFC_nodeOwner", _newOwner, true];
        // Update marker color to owner's side color
    };
};
```

---

## 📦 PHASE 7 — HUD & User Interface

**Goal:** Persistent HUD shows minerals, supply, and minimap. Build menu opens via action or key.

### 7.1 — Resource HUD (CfgRscTitles)

```cpp
// UI/CfgRscTitles.hpp
class RscTitles {
    class IFC_ResourceHUD {
        idd = 9001;
        movingEnable = 0;
        enableSimulation = 1;
        duration = 1e+011;
        
        class controls {
            class MineralBG {
                type = CT_STATIC;
                idc = 1001;
                x = 0.01; y = 0.01; w = 0.18; h = 0.045;
                style = ST_PICTURE;
                text = "\IFC_Core\textures\ui_resource_bar_bg.paa";
                colorBackground[] = {0, 0, 0, 0.6};
            };
            class MineralIcon {
                type = CT_STATIC;
                idc = 1002;
                x = 0.012; y = 0.013; w = 0.025; h = 0.025;
                style = ST_PICTURE;
                text = "\IFC_Core\textures\ui_resource_icon.paa";
            };
            class MineralText {
                type = CT_STATIC;
                idc = 1003;
                x = 0.04; y = 0.015; w = 0.12; h = 0.025;
                style = ST_LEFT;
                text = "0";
                font = "PuristaMedium";
                sizeEx = 0.028;
                colorText[] = {0.9, 0.85, 0.2, 1};  // Gold
            };
            class SupplyText {
                type = CT_STATIC;
                idc = 1004;
                x = 0.01; y = 0.06; w = 0.12; h = 0.025;
                style = ST_LEFT;
                text = "Supply: 0/10";
                font = "PuristaMedium";
                sizeEx = 0.022;
                colorText[] = {0.6, 0.9, 1, 1};
            };
            // Income indicator
            class IncomeText {
                type = CT_STATIC;
                idc = 1005;
                x = 0.01; y = 0.085; w = 0.12; h = 0.02;
                style = ST_LEFT;
                text = "+25/tick";
                font = "PuristaMedium";
                sizeEx = 0.018;
                colorText[] = {0.4, 0.9, 0.4, 1};  // Green
            };
        };
    };
};
```

```sqf
// fn_updateHUD.sqf — called every 0.5s by per-frame handler
if (!hasInterface) exitWith {};

private _minerals = player getVariable ["IFC_minerals", 0];
private _supplyUsed = player getVariable ["IFC_supply_used", 0];
private _supplyCap = player getVariable ["IFC_supply_cap", 0];
private _income = (IFC_mineralsPerTick_base + (player getVariable ["IFC_nodeIncome", 0]));

// Update controls
((uiNamespace getVariable "IFC_ResourceHUD") displayCtrl 1003) ctrlSetText (str _minerals);
((uiNamespace getVariable "IFC_ResourceHUD") displayCtrl 1004) ctrlSetText 
    format ["Supply: %1/%2", _supplyUsed, _supplyCap];
((uiNamespace getVariable "IFC_ResourceHUD") displayCtrl 1005) ctrlSetText 
    format ["+%1/tick", _income];
```

### 7.2 — Build Menu Dialog

```cpp
// UI/dialog_buildmenu.hpp
class IFC_BuildMenu {
    idd = 9002;
    movingEnable = 1;
    
    class controls {
        // Tab buttons: Infantry / Vehicles / Air / Structures / Defense
        class Tab_Infantry {
            type = CT_BUTTON;
            idc = 2001;
            text = "Infantry";
            // ... position/style
            action = "[] call IFC_fnc_showBuildTab_infantry";
        };
        // Build item list (dynamically populated)
        class BuildList {
            type = CT_LISTBOX;
            idc = 2010;
            // ... position/size
        };
        // Selected item info panel
        class ItemName    { type = CT_STATIC; idc = 2020; /* ... */ };
        class ItemCost    { type = CT_STATIC; idc = 2021; /* ... */ };
        class ItemTime    { type = CT_STATIC; idc = 2022; /* ... */ };
        class BtnBuild    { type = CT_BUTTON; idc = 2030; text = "BUILD"; };
        class BtnClose    { type = CT_BUTTON; idc = 2031; text = "X"; };
    };
};
```

---

## 📦 PHASE 8 — Fog of War

**Goal:** Players cannot see enemy units/buildings unless their own units/buildings have line of sight.
Implemented via client-side unit hiding (not true terrain fog — Arma limitation).

### 8.1 — Implementation Strategy

```sqf
// fn_fowInit.sqf — client side
// Arma has no native per-player fog of war, so we simulate it by:
// 1. Hiding all enemy objects at mission start
// 2. Revealing them when a friendly unit is within sight range
// 3. Hiding them again when no friendlies are in sight range

IFC_fowVisibleEnemies = [];  // Objects currently revealed
IFC_fowRadius = 150;         // Sight range in meters

// Per-frame handler at low frequency (every 1.5s for performance)
["IFC_fow_update", {
    [] call IFC_fnc_fowUpdate;
}, 1.5] call CBA_fnc_addPerFrameHandler;
```

```sqf
// fn_fowUpdate.sqf
if (!hasInterface) exitWith {};

private _myUID = getPlayerUID player;
private _myUnits = player getVariable ["IFC_units", []];
_myUnits = _myUnits select { alive _x };

// Add buildings to vision sources
private _myBuildings = player getVariable ["IFC_buildings", []];
private _visionSources = _myUnits + _myBuildings;

// Find all objects within vision range of ANY friendly
private _revealed = [];
{
    private _src = _x;
    {
        _revealed pushBackUnique _x;
    } forEach (_src nearEntities [["Man", "LandVehicle", "Air", "Building"], IFC_fowRadius]);
} forEach _visionSources;

// Reveal newly visible enemies
{
    if ((_x getVariable ["IFC_owner", ""]) != _myUID) then {
        _x hideObjectGlobal false;
        IFC_fowVisibleEnemies pushBackUnique _x;
    };
} forEach _revealed;

// Hide enemies no longer in range
{
    if !(_x in _revealed) then {
        _x hideObjectGlobal true;
        IFC_fowVisibleEnemies = IFC_fowVisibleEnemies - [_x];
    };
} forEach IFC_fowVisibleEnemies;
```

**Note:** `hideObjectGlobal` affects all clients. For per-player FOW in MP, use `hideObject` 
(local only) and run this script on each client independently. Test performance carefully.

---

## 📦 PHASE 9 — Win Conditions & Game Flow

### 9.1 — Elimination

```sqf
// fn_checkWinCondition.sqf — SERVER, runs every 10 seconds
if (!isServer) exitWith {};

private _activePlayers = allPlayers select { 
    !(_x getVariable ["IFC_isEliminated", false]) 
};

{
    private _p = _x;
    private _hq = _p getVariable ["IFC_hqObject", objNull];
    
    // Player is eliminated if HQ is destroyed
    if (isNull _hq || !alive _hq) then {
        [_p] call IFC_fnc_playerEliminated;
    };
} forEach _activePlayers;

// Check win: only one player/team remaining
private _remaining = allPlayers select { !(_x getVariable ["IFC_isEliminated", false]) };
if (count _remaining <= 1) then {
    private _winner = _remaining param [0, objNull];
    [_winner] call IFC_fnc_endGame;
};
```

```sqf
// fn_playerEliminated.sqf
params ["_player"];
if (!isServer) exitWith {};

_player setVariable ["IFC_isEliminated", true, true];

// Kill all their units
{
    if (alive _x) then { _x setDamage 1 };
} forEach (_player getVariable ["IFC_units", []]);

// Destroy all their buildings
{
    if (!isNull _x && alive _x) then { _x setDamage 1 };
} forEach (_player getVariable ["IFC_buildings", []]);

// Notify player
["IFC_playerEliminated", []] remoteExecCall ["IFC_fnc_onEliminated", _player];
```

### 9.2 — Victory Screen

```sqf
// fn_endGame.sqf
params ["_winner"];
if (!isServer) exitWith {};

private _winnerName = name _winner;

// Broadcast to all players
["IFC_gameOver", [_winnerName]] call CBA_fnc_serverEvent;

sleep 10;
["endMission", ["IFC_WIN"]] call CBA_fnc_serverEvent;
```

---

## 📦 PHASE 10 — Multiplayer Sync Architecture

### 10.1 — Golden Rules for MP

```
SERVER AUTHORITY:
  - All resource mutations (add, spend, sync)
  - All unit spawning and despawning
  - All building creation and destruction
  - Win condition checking
  - Production queue processing

CLIENT LOCAL:
  - Camera movement
  - Unit selection (client tracks selection, orders sent to server)
  - HUD display (reads broadcasted variables)
  - Fog of war hiding (hideObject local)
  - Build placement preview

BROADCAST PATTERN:
  - setVariable [..., true]  → broadcasts to all (use for game state)
  - setVariable [..., false] → local only (use for UI state)
  - remoteExecCall [..., 2]  → runs on server
  - remoteExecCall [..., 0]  → runs on all clients
  - remoteExecCall [..., -2] → runs on all EXCEPT server
```

### 10.2 — JIP (Join In Progress) Sync

```sqf
// fn_syncNewPlayer.sqf — SERVER, called when player connects mid-game
params ["_newPlayer"];

// Re-broadcast all building variables
{
    private _building = _x;
    private _data = _building getVariable ["IFC_buildingData", createHashMap];
    // Force variable broadcast to new player
    _building setVariable ["IFC_owner", _building getVariable ["IFC_owner", ""], true];
    _building setVariable ["IFC_buildingID", _building getVariable ["IFC_buildingID", ""], true];
    _building setVariable ["IFC_isComplete", _building getVariable ["IFC_isComplete", false], true];
} forEach (allMissionObjects "All" select { !isNull (_x getVariable ["IFC_buildingID", nil]) });

// Send resources to new player
[_newPlayer, 0, 0] call IFC_fnc_addResources;  // Trigger sync of their current values
```

---

## 📦 PHASE 11 — Mission File Setup

### 11.1 — description.ext

```cpp
// missions/IFC_2p_Altis.Altis/description.ext
author = "YourName";
briefingName = "Ironfront Command";
overviewText = "StarCraft-style RTS — Build your base, raise an army, destroy the enemy HQ.";
onLoadName = "IRONFRONT COMMAND";
loadScreen = "\IFC_Core\textures\loadscreen.paa";

respawn = "BASE";
respawnDelay = 0;
respawnOnStart = -1;

// Disable default Arma score screen
class Header {
    gameType = Coop;
    minPlayers = 1;
    maxPlayers = 8;
};
```

### 11.2 — init.sqf

```sqf
// missions/IFC_2p_Altis.Altis/init.sqf
waitUntil { !isNull findDisplay 46 };  // Wait for game to load
waitUntil { time > 2 };

// Server-only init
if (isServer) then {
    [] call IFC_fnc_initServer;
    
    // Place resource nodes
    {
        [_x, 50] call IFC_fnc_initResourceNode;
    } forEach IFC_resourceNodeObjects;  // Objects tagged in editor with variable name
    
    // Start win condition checker
    [] spawn {
        while { true } do {
            sleep 10;
            [] call IFC_fnc_checkWinCondition;
        };
    };
};

// Client-only init
if (hasInterface) then {
    waitUntil { !isNull player };
    [player] call IFC_fnc_initPlayer;
    
    // Show HUD
    createDialog "IFC_ResourceHUD";
};
```

---

## 🧪 TESTING CHECKLIST

### Phase 1 Tests
- [ ] Player spawns with 200 minerals
- [ ] Minerals increase every 8 seconds
- [ ] `IFC_fnc_canAfford` returns false when broke
- [ ] `IFC_fnc_spendResources` deducts correctly and broadcasts

### Phase 2 Tests
- [ ] Build menu opens via key/action
- [ ] Ghost preview follows mouse in commander mode
- [ ] Preview turns red when too close to another building
- [ ] Confirm placement deducts minerals
- [ ] Building spawns after build time elapses
- [ ] Supply cap increases from Supply Depot

### Phase 3 Tests
- [ ] Unit training queues correctly
- [ ] Unit spawns at rally point after train time
- [ ] Queue shows in UI with timer
- [ ] Supply used increments per unit trained
- [ ] Cannot train if supply is capped

### Phase 4 Tests
- [ ] Grave key toggles commander / soldier mode
- [ ] Camera moves with WASD and edge scrolling
- [ ] Camera zooms with scroll wheel
- [ ] Player body is frozen/protected in commander mode
- [ ] Returning to soldier body works correctly

### Phase 5 Tests
- [ ] Click selects own unit, not enemy unit
- [ ] Box select captures multiple units
- [ ] Right-click issues move order to correct world position
- [ ] Units path to ordered position
- [ ] Attack order causes units to engage target

### Phase 6 Tests
- [ ] Neutral node shows yellow on map
- [ ] Moving units near node captures it after 3s
- [ ] Income increases after capture
- [ ] Contesting blocks capture (orange marker)

### Phase 7 Tests  
- [ ] Mineral count shown accurately in HUD
- [ ] Supply shown as used/cap
- [ ] Income indicator updates after node capture
- [ ] Build menu tabs filter correctly

### Phase 8 Tests
- [ ] Enemy units not visible at mission start
- [ ] Enemy units appear when friendly unit gets close
- [ ] Enemy units disappear when friendly moves away
- [ ] Own units always visible

### Phase 9 Tests
- [ ] Destroying HQ eliminates that player
- [ ] Eliminated player's units/buildings are removed
- [ ] Victory screen shows correct winner
- [ ] Mission ends 10 seconds after victory

### Multiplayer Tests
- [ ] Two clients have separate resource pools
- [ ] Client A spending minerals does not affect Client B
- [ ] Units trained by Client A are not selectable by Client B
- [ ] JIP player receives correct game state on join
- [ ] Building placements visible to all clients

---

## ⚠️ KNOWN LIMITATIONS & WORKAROUNDS

| Limitation | Workaround |
|---|---|
| No native per-player FOW | Use `hideObject` (local) per-client in FOW update loop |
| AI pathfinding struggles indoors | Keep all buildings as props; units fight in open terrain |
| `screenToWorld` inaccurate at low angles | Use camera pitched near-vertical (80°+) for accuracy |
| No minimap API | Implement custom minimap using `ctrlMapCursorPos` on `RscMapControl` |
| `createVehicle` buildings can clip terrain | Use `BIS_fnc_findSafePos` or enforce flat placement zones |
| MP latency in production queue | Accept ~0.5s desync; queue is server-authoritative |
| Performance with 200+ AI | Cap per-player unit limit; stagger AI update rates |
| No drag-select native support | Track mouse down/up positions and do screen-rect unit filter |

---

## 🔗 REQUIRED DEPENDENCIES

1. **CBA_A3** — Community Base Addons (keybindings, per-frame handlers, events)
   - Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=450814997
   - All `CBA_fnc_*` calls require this
   
2. **ACE3** (optional but recommended) — Adds medical, interaction menus
   - Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=463939057

3. **Task Force Arrowhead Radio** (optional) — For realistic comms between commanders

---

## 📋 DEVELOPMENT PHASES (RECOMMENDED ORDER)

```
Sprint 1 (Foundation):     Config + Resource System + HUD display
Sprint 2 (Placement):      Building system + preview + construction
Sprint 3 (Camera):         Commander mode camera + toggle
Sprint 4 (Production):     Unit training queue + spawn
Sprint 5 (Orders):         Selection system + move/attack orders
Sprint 6 (Nodes):          Resource nodes + capture logic
Sprint 7 (FOW):            Fog of war system
Sprint 8 (Win Conditions): Elimination + victory
Sprint 9 (Polish):         UI refinement, sounds, minimap
Sprint 10 (MP Testing):    Dedicated server testing, JIP, desync fixes
```

---

## 🎮 RECOMMENDED EDITOR SETUP

- Map: **Altis** (large open terrain, good for RTS scale)
- Place 2 "Game Logic" modules per player spawn point — one for HQ position, one for start camera
- Tag resource nodes: set object variable `IFC_isNode = true` in editor attributes
- Set mission attributes: `enableEngineArtillery false`, disable respawn score screen
- Use `BIS_fnc_moduleRespawnPosition` for player respawn at their HQ

---

## 💡 DESIGN NOTES FOR LLM IMPLEMENTING THIS

1. **Always implement server-auth first.** Write the server-side function, verify it works in 
   SP (single player = both server+client), then add the remoteExec wrappers.

2. **Test in SP before MP.** Most logic bugs surface in single player. MP adds a second layer 
   of complexity — tackle them separately.

3. **SQF has no real type safety.** Always use `param[s]` with type validation. Example:
   `params [["_unit", objNull, [objNull]], ["_pos", [], [[]]]]`

4. **CBA per-frame handlers are your game loop.** Never use infinite `while + sleep` loops 
   on the client. Use `CBA_fnc_addPerFrameHandler` for anything UI/camera related.

5. **`remoteExec` whitelist.** In production MP, Arma requires all remoteExec function names 
   to be listed in `CfgRemoteExec`. Add all `IFC_fnc_*` server-targeted functions there.

6. **Object persistence.** Buildings and units do NOT persist through mission restart — this is 
   expected. All state lives in the mission session.

7. **Building as props, not actual buildings.** Use Arma props/structures as visual stand-ins.
   Do not rely on `BIS_fnc_buildingPositions` — treat them purely as positioned objects.

8. **When generating UI config (hpp files):** Use `safeZoneX/Y/W/H` expressions for 
   resolution-independent positioning.

9. **FOW performance:** Do not run FOW update more than once per 1-2 seconds. It touches 
   all mission objects.

10. **The game loop priority:** Resources tick → Buildings check health → Units update orders → 
    Win condition check. Keep this order to avoid state inconsistencies.
