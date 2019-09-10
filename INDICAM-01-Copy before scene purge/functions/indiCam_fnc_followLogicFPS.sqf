comment "-------------------------------------------------------------------------------------------------------";
comment "											indiCam, by woofer.											";
comment "																										";
comment "										  indiCam_fnc_followLogicFPS									";
comment "																										";
comment "																										";
comment "	Call this function using a stackable eventhandler onEachFrame to make an object follow a position.	";
comment "	Uses FPS only as a divider of time for now. Would be nice to detect low FPS and mitigate that.		";
comment "																										";
comment "	Params: [ _object, _target _speed ]																	";
comment "																										";
comment "-------------------------------------------------------------------------------------------------------";
// Result: 0.0431 ms
// Cycles: 10000/10000

/*
indiCam_var_ball = createVehicle ["Sign_Sphere25cm_F", (player modelToWorld [0,5,1]), [], 0, "CAN_COLLIDE"];
["indiCam_id_ballVelocity", "onEachFrame", {[indiCam_var_ball,(player modelToWorld [0,5,1]),1] call indiCam_fnc_followLogicFPS}] call BIS_fnc_addStackedEventHandler;

["indiCam_id_ballTarget", "onEachFrame", {}] call BIS_fnc_addStackedEventHandler; 
["indiCam_id_ballCamera", "onEachFrame", {}] call BIS_fnc_addStackedEventHandler;

["indiCam_id_logicTarget", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
["indiCam_id_logicCamera", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
*/

params [
		"_object",		// The object that is to be moved
		"_target",		// The target which the object is to follow
		"_speed"		// The speed of the object as a function of distance from the target speed*distance^2
		];

// First find out where our object is located
_pos = getPosASL _object;

// Find the vector along which we want to move. Both direction and length in this one.
_vector = _pos vectorDiff _target;

//systemChat format ["Dumped _vector: %1, for object %2",_vector,_object];

// Then we decide on how far to move
_distance = vectorMagnitude _vector;			// Get the length of the vector
_speedModifier = (-1 * _speed * _distance^2);	// Speed will increase by function of a second degree polynomial with distance from target
_fps = diag_fps;								// Get the current mean fps
_frameDist = _speedModifier * (1 / _fps);		// This is how far we move each frame





// Get the movement direction and multiply by how far to move the object
_velocityVector = (vectorNormalized _vector) vectorMultiply _frameDist;

// Find the new position by adding the _velocityVector to the current pos
_newPos = _pos vectorAdd _velocityVector;

// Move the object one _frameDistance in the direction of _velocityVector
_object setPosASL _newPos;
