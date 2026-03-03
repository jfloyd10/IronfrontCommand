/*
    Function: IFC_fnc_initServer
    Description: Server-side initialization. Loads global definitions and starts
                 the resource tick loop. Must be called once on the server at
                 mission start.

    Parameters: None
    Returns: Nothing
    Author: IFC Dev
*/

if (!isServer) exitWith {};

// Load global definitions (building defs, unit defs, constants)
[] call IFC_fnc_init;

// Start the resource tick loop (runs forever on server)
[] spawn IFC_fnc_resourceTick;

diag_log "IFC: Server init complete — resource tick started";

// TEST: In single player (which is both server and client), run:
// [] call IFC_fnc_initServer;
// Expected: RPT log shows "IFC: Server init complete", resource tick begins running
