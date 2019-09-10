comment "-------------------------------------------------------------------------------------------------------";
comment "											indiCam, by woofer.											";
comment "																										";
comment "											indiCam_fnc_sceneCommit										";
comment "																										";
comment "	This script commits a selected and tested scene to the indiCam camera.								";
comment "																										";
comment "	Takes the values from the selected scene and promotes them to applied variables which are in turn	";
comment "	used in the selected camera commit type.															";
comment "																										";
comment "																										";
comment "-------------------------------------------------------------------------------------------------------";

/*
Available camera commit types:
default - For general basic camera use
logics - For use with game logics
relative - Used when camSetRelPos is in effect rather than attachTo
*/

//TODO- Go through all the variables to see what is actually used
//TODO- Add a commit type that skips applying any camera stuff so that a scene can just execute a script.


// Stop any already running logic scripts
indiCam_indiCamLogicLoop = false;


// Move the values over to permanent variables so that the scene selection can get going again
indiCam_appliedVar_takeTime = indiCam_var_takeTime;
indiCam_appliedVar_cameraMovementRate = indiCam_var_cameraMovementRate;
indiCam_appliedVar_cameraPos = indiCam_var_cameraPos;

indiCam_appliedVar_useRelativePos = indiCam_var_useRelativePos;
indiCam_appliedVar_relativePos = indiCam_var_relativePos;
indiCam_appliedVar_cameraAttach = indiCam_var_cameraAttach;

indiCam_appliedVar_cameraPos = indiCam_var_cameraPos;
indiCam_appliedVar_cameraTarget = indiCam_var_cameraTarget;
indiCam_appliedVar_cameraFov = indiCam_var_cameraFov;
indiCam_appliedVar_maxDistance = indiCam_var_maxDistance;

indiCam_appliedVar_ignoreHiddenActor = indiCam_var_ignoreHiddenActor;

indiCam_appliedVar_cameraType = indiCam_var_cameraType;






// Apply the camera using the last values pulled on the scene
switch (indiCam_appliedVar_cameraType) do {


	case "default": {
	/*
	This is the basic camera commit without any bells and whistles
	*/
		
		// Detach camera if needed
		if (!(indiCam_var_cameraAttach)) then {detach indiCam};
		
		// Prepare camera before committing it
		indiCam camSetPos indiCam_appliedVar_cameraPos;
		indiCam camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam camSetFov indiCam_appliedVar_cameraFov;

		// Do the actual commit
			if (indiCam_appliedVar_takeTime == 1) then {indiCam_appliedVar_takeTime = 2}; // prevents division by zero
			if (indiCam_appliedVar_cameraMovementRate == 0) then {  // prevents division by zero
				indiCam camCommit 0;
			}
			else {
				indiCam camCommit (((indiCam distance indiCam_appliedVar_cameraPos) / (indiCam_appliedVar_takeTime - 1)) / indiCam_appliedVar_cameraMovementRate);
			};
				
	}; // end of case

	
	
	case "logics": {
	/*
	This camera will start up game any waiting game logics
	*/
		// Detach camera if needed
		if (!indiCam_var_cameraAttach) then {detach indiCam};
		
		// This will engage switch paused logic scripts
		indiCam_var_runScript = true;
		
		// Prepare camera before committing it
		indiCam camSetPos indiCam_appliedVar_cameraPos;
		indiCam camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam camSetFov indiCam_appliedVar_cameraFov;

		// Do the actual commit
		indiCam camCommit indiCam_var_cameraMovementRate;

	}; // end of case
	
	
	case "relative": {
	/*
	This camera positiones itself relative to the actor
	It is an attempt to use the relPos instead of attach
	It is less jerky as it follows a relative position rather than
	being stuck to a memory point like with attachTo
	*/
		
		// Detach camera if needed
		if (!(indiCam_appliedVar_cameraAttach)) then {detach indiCam};
		
		// Prepare camera before starting to commit it
		indiCam camSetTarget indiCam_appliedVar_cameraTarget;
		indiCam camSetFov indiCam_appliedVar_cameraFov;

		// Do a continuous commit
		indiCam_var_continuousCameraCommit = true;
		[] spawn {
			//systemChat "Spawned continuous camera commit...";
			indiCam_var_continuousCameraStopped = false;
			while {indiCam_var_continuousCameraCommit} do {
				indiCam camSetRelPos indiCam_appliedVar_relativePos;
				indiCam camCommit 0;
				sleep (1/90);
			};
			indiCam_var_continuousCameraStopped = true;
			//systemChat "stopped continuous camera commit!";
		};
		
	
	}; // end of case
	
	
}; // end of switch




















