comment "-------------------------------------------------------------------------------------------------------";
comment "											indiCam, by woofer.											";
comment "																										";
comment "										  indiCam_scene_selectMain										";
comment "																										";
comment "-------------------------------------------------------------------------------------------------------";




comment "-------------------------------------------------------------------------------------------------------";
comment "												init													";
comment "-------------------------------------------------------------------------------------------------------";

// Set the outside all brackets scope name to give us a place to exit to
scopeName "topLevel";

// This is a way to make known that scene select is currently running. Turns false at the end.
indiCam_var_sceneSelectRunning = true;


comment "-------------------------------------------------------------------------------------------------------";
comment "												init													";
comment "-------------------------------------------------------------------------------------------------------";


// Get the current sceneType
	// foot
	// car
	// helicopter
	// plane
	// tank
	// boat
private _sceneType = indiCam_var_sceneType;
	
// Check the environment 
private _environmentCheck = [] call indicam_fnc_environmentCheck;



comment "-------------------------------------------------------------------------------------------------------";
comment "											main loop start												";
comment "-------------------------------------------------------------------------------------------------------";
// This loop will run until a scene is found that will have enough visibility of the actor.
while {true} do {


comment "-------------------------------------------------------------------------------------------------------";
comment "										scene vehicle selection											";
comment "-------------------------------------------------------------------------------------------------------";
// Pulls scene parameters defined in separate categories depending on what string was passed

	switch (_sceneType) do {
		
		case "foot": { // Actor on foot scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainFoot.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainFoot;
			};
		};

		case "car": { // Car, quad, truck or similar type scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainCar.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainCar;
			};
		};
		
		case "helicopter": { // Helicopter scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainHelicopter.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainHelicopter;
			};
		};
		
		case "plane": { // plane scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainPlane.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainPlane;
			};
		};
		
		case "tank": { // Tank scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainTank.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainTank;
			};
			
		};

		case "boat": { // Boat scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainBoat.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainBoat;
			};
		};
		
		default { // Generic scenes to use when no param was passed, we'll do foot for now but should be separate script
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainFoot.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainFoot;
			};
		};

		/* Old way of starting scripted scenes
		case "scripted": { // Scripted scenes
			if (indiCam_devMode) then {
			_handle = [] execVM "INDICAM\scenes\indiCam_scene_mainScripted.sqf";
			waitUntil {scriptDone _handle};
			} else {
			[] call indiCam_scene_mainScripted;
			};
		};
		*/

	}; // Switch closed
	
	
	
	
	comment "-------------------------------------------------------------------------------------------------------";
	comment "										scene prototyping area											";
	comment "																										";
	comment "					To be used when developing sceens - set the bool below to true						";
	comment "																										";
	comment "-------------------------------------------------------------------------------------------------------";
	private _prototypeScene = false; // Switch this to true to use the prototyping area
	if (_prototypeScene) then {
	systemChat "Testing area scene";
	// Change the stuff below here
	

			// Regular stationary camera tracking a logic target around the actor
			indiCam_var_cameraType = "stationaryCameraLogicTarget";
			indiCam_var_disqualifyScene = false;	// If true, this scene will not be applied and a new one will be selected
			indiCam_var_takeTime = 60;				// Time after which a new scene will be selected
			_posX = selectRandom [random [-15,-2,-15],random [2,15,2]]; // Specifies the range for the camera position sideways to the actor
			_posY = selectRandom [random [-15,-10,-15],random [10,15,10]];	// Specifies the range for the camera position to the front and back of the actor
			_posZ = random [0.5,1,2];				// Specifies the range for the camera position vertically from the actor
			indiCam_var_cameraPos = [_posX,_posY,_posZ]; // Position of camera relative to the actor
			indiCam_var_targetPos = [0,0,1.8];		// Position of camera target relative to the actor
			indiCam_var_targetSpeed = 0.6;			// Defines how tightly the logic will track it's defined position
			indiCam_var_cameraTarget = indiCam_var_proxyTarget;	// The object that the camera is aimed at
			indiCam_var_cameraFov = random [0.1,0.2,0.3]; // Field of view, standard Arma FOV is 0.74
			indiCam_var_maxDistance = 600;			// Max distance between actor and camera before scene switches
			indiCam_var_ignoreHiddenActor = false;	// True will disable line of sight checks during scene, actor may stay hidden
			indiCam_var_cameraAttach = false;		// Control whether the camera should be attached to anything
			


	comment "-------------------------------------------------------------------------------------------------------";
	indiCam_var_previousScene = "letsnotgothere";
	}; // End of prototyping area
	comment "-------------------------------------------------------------------------------------------------------";





	// This disables the previous scene check that prevents scenes repeating
	// Used for debugging
	if (indiCam_debug) then {
		indiCam_var_previousScene = "letsnotgothere";
	};




comment "-------------------------------------------------------------------------------------------------------";
comment "											test the scene												";
comment "-------------------------------------------------------------------------------------------------------";

	// Do all the necessary tests
	
	// Test the the scene before applying it
	_sceneTest = [(indiCam_actor modelToWorldWorld indiCam_var_cameraPos)] call indiCam_fnc_sceneTest; // If the scene test checks out good, this will return true
	
	// If the scene is ok, exit sceneSelect and keep what's stored in global
	// Also make sure the scene doesn't have the same name as the previously committed one
	if (_sceneTest && !(indiCam_var_scene isEqualTo indiCam_var_previousScene)) then {
	
		if (indiCam_debug) then {systemChat format ["Scene selected: %1",indiCam_var_scene]};
			
			// Store the last used scene in a variable so that it can be prevented to run the very next time
			indiCam_var_previousScene = indiCam_var_scene;
			
			// Now that we have what we want, exit to outside of the loop
			breakTo "topLevel";

	} else {
		
		// Since we couldn't get the visibility we wanted, let the loop start over
		if (indiCam_debug) then {systemChat "actor obscured or same scene - selecting new scene"};
		
	};
	
};






comment "-------------------------------------------------------------------------------------------------------";
comment "											commit the scene											";
comment "-------------------------------------------------------------------------------------------------------";

// Move the values over to permanent variables so that the scene selection can get going again
// Keeping this system for now. At least it can be used to recall last known values
// I should probably do it more straightforward with local vars ybtuk cinnut
indiCam_appliedVar_takeTime = indiCam_var_takeTime;
indiCam_appliedVar_cameraMovementRate = indiCam_var_cameraMovementRate;
indiCam_appliedVar_cameraPos = indiCam_var_cameraPos;
indiCam_appliedVar_targetPos = indiCam_var_targetPos;
indiCam_appliedVar_cameraSpeed = indiCam_var_cameraSpeed;
indiCam_appliedVar_targetSpeed = indiCam_var_targetSpeed;
indiCam_appliedVar_cameraTarget = indiCam_var_cameraTarget;
indiCam_appliedVar_cameraTargetScripted = indiCam_var_cameraTargetScripted;
indiCam_appliedVar_cameraFov = indiCam_var_cameraFov;
indiCam_appliedVar_maxDistance = indiCam_var_maxDistance;
indiCam_appliedVar_ignoreHiddenActor = indiCam_var_ignoreHiddenActor;
indiCam_appliedVar_cameraType = indiCam_var_cameraType;


// Kill any onEachFrame camera eventhandlers still going.
[] call indiCam_fnc_clearEventhandlers;

// Stop any already running logic scripts
indiCam_indiCamLogicLoop = false;


// Apply the camera using the last values pulled on the scene with the proper camera type
switch (indiCam_appliedVar_cameraType) do {

	case "default": {
		//This is the basic camera commit without any bells or whistles
		
		// Prepare camera before committing it
		indiCam_camera setPosASL indiCam_appliedVar_cameraPos;
		indiCam_camera camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam_camera camSetFov indiCam_appliedVar_cameraFov;
		
		// Do the actual commit 
		if (indiCam_appliedVar_takeTime == 1) then {indiCam_appliedVar_takeTime = 2}; // prevents division by zero
		if (indiCam_appliedVar_cameraMovementRate == 0) then {  // prevents division by zero
			indiCam_camera camCommit 0;
		} else {
			indiCam_camera camCommit (((indiCam_camera distance indiCam_appliedVar_cameraPos) / (indiCam_appliedVar_takeTime - 1)) / indiCam_appliedVar_cameraMovementRate);
		};
		
	}; // end of case
	
	
	case "stationaryCameraLogicTarget": {
		// Camera is stationary at given point.
		// Camera target is a follow logic calculated on each frame.
				
		indiCam_var_proxyTarget setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_targetPos);
		indiCam_camera setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_cameraPos);

		["indiCam_id_logicTarget", "onEachFrame", {[indiCam_var_proxyTarget,(indiCam_actor modelToWorldWorld indiCam_appliedVar_targetPos),indiCam_appliedVar_targetSpeed] call indiCam_fnc_followLogicFPS}] call BIS_fnc_addStackedEventHandler;
		// Add this eventhandler to the current EH list
		indiCam_var_activeEventHandlers pushBackUnique "indiCam_id_logicTarget";
		
		indiCam_camera camSetFov indiCam_appliedVar_cameraFov;
		indiCam_camera camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam_camera camCommit 0;
	
	}; // end of case
	
	
	case "followCameraLogicTarget": {
		
		indiCam_camera camSetFov indiCam_appliedVar_cameraFov;
		indiCam_camera camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam_camera camCommit 0;
		
		indiCam_camera setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_cameraPos);
		indiCam_var_proxyTarget setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_targetPos);
		
		["indiCam_id_logicTarget", "onEachFrame", {[indiCam_var_proxyTarget,(indiCam_actor modelToWorldWorld indiCam_appliedVar_targetPos),indiCam_appliedVar_targetSpeed] call indiCam_fnc_followLogicFPS}] call BIS_fnc_addStackedEventHandler;
		// Add this eventhandler to the current EH list
		indiCam_var_activeEventHandlers pushBackUnique "indiCam_id_logicTarget";
		
		["indiCam_id_logicCamera", "onEachFrame", {[indiCam_camera,(indiCam_actor modelToWorldWorld indiCam_appliedVar_cameraPos),indiCam_appliedVar_cameraSpeed] call indiCam_fnc_followLogicFPS}] call BIS_fnc_addStackedEventHandler;
		// Add this eventhandler to the current EH list
		indiCam_var_activeEventHandlers pushBackUnique "indiCam_id_logicCamera";
		
		
	}; // end of case
	
	
	case "followCameraWeaponLogic": {
		
		indiCam_var_proxyTarget setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_targetPos);
		indiCam_camera setPosASL (indiCam_actor modelToWorldWorld indiCam_appliedVar_cameraPos);

		["indiCam_id_logicTarget", "onEachFrame", {[indiCam_var_proxyTarget,indiCam_appliedVar_targetPos,indiCam_appliedVar_targetSpeed] call indiCam_fnc_followLogicTurretAim}] call BIS_fnc_addStackedEventHandler;
		// Add this eventhandler to the current EH list
		indiCam_var_activeEventHandlers pushBackUnique "indiCam_id_logicTarget";
		
		["indiCam_id_logicCamera", "onEachFrame", {[indiCam_camera,indiCam_appliedVar_cameraPos,indiCam_appliedVar_cameraSpeed] call indiCam_fnc_followLogicTurretAim}] call BIS_fnc_addStackedEventHandler;
		// Add this eventhandler to the current EH list
		indiCam_var_activeEventHandlers pushBackUnique "indiCam_id_logicCamera";
		
		
		indiCam_camera camSetFov indiCam_appliedVar_cameraFov;
		indiCam_camera camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam_camera camCommit 0;
	
	}; // end of case
	
}; // end of switch


// This is used to tell scripts that scene select is now done
indiCam_var_sceneSelectRunning = false;
