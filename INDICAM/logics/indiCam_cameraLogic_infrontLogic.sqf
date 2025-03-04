comment "-------------------------------------------------------------------------------------------------------";
comment "											indiCam, by woofer.											";
comment "																										";
comment "											indiCam_cameraLogic_infrontLogic										";
comment "																										";
comment "	Creates, maintains and removes logic objects for use with the camera.								";
comment "																										";
comment "	This script contains sleep and has to be spawned.													";
comment "	Arguments: [ cameraChaseSpeed , _targetTrackingSpeed ]												";
comment "																										";
comment "-------------------------------------------------------------------------------------------------------";






// I need to somehow commit this after the scene pre-check
// Otherwise the current logic will break



// Make this into a function and pass these arguments here
private _distance = _this select 0; // How far in front of the actor to place the logic target
private _targetTrackingSpeed = _this select 1; // How quickly the logic should be striving toward the point in front of the actor



comment "-------------------------------------------------------------------------------------------------------";
comment "	Script control block 																				";
comment "-------------------------------------------------------------------------------------------------------";
// Hold on to the marbles until the script is let loose - or kill it if it won't be used.
// Basically I only want it to run when the scene change is happening in sceneCommit.
// It will not have to be held for long, only for the duration to evaluate the next scene.
indiCam_var_holdScript = true;

while {indiCam_var_holdScript} do {
	if (indiCam_var_exitScript || indiCam_var_runScript) then {indiCam_var_holdScript = false;};
	sleep 0.01;
};

if (indiCam_var_runScript) then { // if this script is terminated, don't run this

comment "-------------------------------------------------------------------------------------------------------";



comment "-------------------------------------------------------------------------------------------------------";
comment "	Game logic animation																				";
comment "-------------------------------------------------------------------------------------------------------";

	// The following creates a logic position for the camera target
	[_distance,_targetTrackingSpeed] spawn {
		indiCam_indiCamLogicLoop = true;
		indiCam_infrontLogic setPos indiCam_appliedVar_cameraPos; // Move the logic close to it's starting point
		while {indiCam_indiCamLogicLoop} do {
			_logicTargetRelativePos = actor modelToWorldWorld [0,(_this select 0),1];
			_distanceTarget = (getPosASL indiCam_infrontLogic) distance _logicTargetRelativePos;
			_offsetVectorTarget = (getposASL indiCam_infrontLogic) vectorFromTo _logicTargetRelativePos;
			_offsetVectorTarget = _offsetVectorTarget vectorMultiply _distanceTarget*(_this select 1);
			_offsetVectorTarget = (getPosASL indiCam_infrontLogic) vectorAdd _offsetVectorTarget;
			indiCam_infrontLogic setPosASL _offsetVectorTarget;
			sleep (1/90);
		};
		
	};
};

comment "-------------------------------------------------------------------------------------------------------";
comment "	Script control block 																				";
comment "																										";
indiCam_var_exitScript = false; // Used for killing waiting logic scripts
comment "-------------------------------------------------------------------------------------------------------";
