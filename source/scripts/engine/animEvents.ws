/*
Copyright © CD Projekt RED 2015
*/

import struct SMultiValue
{
	import var floats		: array< float >; 
	import var bools 		: array< bool >; 
	import var enums 		: array< SEnumVariant >	;
	import var names		: array<name>;
};




import struct SSlideToTargetEventProps
{
	import var	minSlideDist				: float;
	import var	maxSlideDist				: float;
	import var	slideToMaxDistIfTargetSeen	: bool;
	import var	slideToMaxDistIfNoTarget	: bool;
};









import struct SEnumVariant
{
	import var	enumType	: name;
	import var	enumValue	: int;
};





import struct SAnimationEventAnimInfo
{
};


import function GetAnimNameFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : name;


import function GetLocalAnimTimeFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;


import function GetEventDurationFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;


import function GetEventEndsAtTimeFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;
