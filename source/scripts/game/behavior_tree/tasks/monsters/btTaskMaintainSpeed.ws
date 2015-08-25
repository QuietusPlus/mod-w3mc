/*
Copyright © CD Projekt RED 2015
*/






class CBTTaskMaintainSpeed extends IBehTreeTask
{
	var moveType 		: EMoveType;
	var moveSpeed		: float;
	var manageFlySpeed	: bool;
	var onActivate		: bool;
	var onDeactivate	: bool;
	var speedDecay		: bool;

	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		switch ( moveType )
		{
			case MT_Walk 	: moveSpeed = 0.3;
			break;
			case MT_Run 	: moveSpeed = 1.0;
			break;
		}
		
		if ( onActivate )
		{
			npc.SetBehaviorVariable( 'Editor_MovementSpeed', moveSpeed );
			if ( manageFlySpeed )
			{
				npc.SetBehaviorVariable( 'Editor_FlySpeed', moveSpeed );
			}
			if ( speedDecay )
			{
				npc.AddTimer( 'MaintainSpeedTimer', 0.5, false );
				if ( manageFlySpeed )
				{
					npc.AddTimer( 'MaintainFlySpeedTimer', 0.5, false );
				}
			}
		}		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onDeactivate )
		{
			npc.SetBehaviorVariable( 'Editor_MovementSpeed', moveSpeed );
			if ( manageFlySpeed )
			{
				npc.SetBehaviorVariable( 'Editor_FlySpeed', moveSpeed );
			}
			if ( speedDecay )
			{
				npc.AddTimer( 'MaintainSpeedTimer', 0.5, false );
				if ( manageFlySpeed )
				{
					npc.AddTimer( 'MaintainFlySpeedTimer', 0.5, false );
				}
			}
		}
	}
};

class CBTTaskMaintainSpeedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskMaintainSpeed';
	
	editable var moveType 		: EMoveType;
	editable var manageFlySpeed	: bool;
	editable var onActivate		: bool;
	editable var onDeactivate	: bool;
	editable var speedDecay		: bool;
	
	default moveType = MT_Run;
	default onDeactivate = true;
	default speedDecay = true;
};
