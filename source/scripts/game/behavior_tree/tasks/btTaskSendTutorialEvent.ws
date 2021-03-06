/*
Copyright © CD Projekt RED 2015
*/

class CBTTaskSendTutorialEvent extends IBehTreeTask
{
	public var onActivation 		: bool;
	public var onDeactivation 		: bool;
	
	public var guardSwordWarning	: bool;
	public var guardGeneralWarning	: bool;
	public var guardLootingWarning	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivation ) SendEvent();
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		if ( onDeactivation ) SendEvent();
	}
	
	
	function SendEvent()
	{
		if ( GetActor().GetAttitude(thePlayer) == AIA_Friendly )
			return;
		if ( guardSwordWarning )
			theGame.GetTutorialSystem().OnGuardSwordWarning();
		if ( guardGeneralWarning )
			theGame.GetTutorialSystem().OnGuardGeneralWarning();
		if ( guardLootingWarning )
			theGame.GetTutorialSystem().OnGuardLootingWarning();
	}
}

class CBTTaskSendTutorialEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSendTutorialEvent';

	editable var onActivation 			: bool;
	editable var onDeactivation 		: bool;
	
	editable var guardSwordWarning		: bool;
	editable var guardGeneralWarning	: bool;
	editable var guardLootingWarning	: bool;
};