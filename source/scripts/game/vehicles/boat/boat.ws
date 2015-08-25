/*
Copyright © CD Projekt RED 2015
*/





import class W3Boat extends CGameplayEntity
{
	private autobind boatComp : CBoatComponent = single;
	private autobind mountInteractionComp : CInteractionComponent = "mountExplorationInteraction";
	private autobind mountInteractionCompPassenger : CInteractionComponent = "mountExplorationInteractionPassenger";
	
	private var hasDrowned : bool;					default hasDrowned = false;
	private saved var canBeDestroyed : bool;		default canBeDestroyed = true;
	private var needEnableInteractions: bool;		default needEnableInteractions = false;

	event OnStreamOut()
	{
		if(theGame.IsBoatMarkedForDestroy(this))
		{
			AddTimer( 'DelayedDestroyBoat', 0.1f );	
		}
	}
	timer function DelayedDestroyBoat( td : float , id : int)
	{
		RemoveTimer( 'DelayedDestroyBoat' );
		Destroy();
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var player : CR4Player;
	
		player = (CR4Player)activator.GetEntity();
		
		if( player )	
		{
			if( area.GetName() == "FirstDiscoveryTrigger" )
			{
				area.SetEnabled( false );
			}
			else if( area.GetName() == "OnBoatTrigger" )
			{
				player.SetIsOnBoat( true );
				player.BlockAction( EIAB_RunAndSprint, 'OnBoatTrigger', false, false, true );
				player.BlockAction( EIAB_CallHorse, 'OnBoatTrigger', false, false, true );
				
				if( !HasDrowned() )
				{
					needEnableInteractions = true;
					
					if( mountInteractionComp )
						mountInteractionComp.SetEnabled( true );
					if( mountInteractionCompPassenger && boatComp.user )	
						mountInteractionCompPassenger.SetEnabled( true );
				}
			}
		}
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var player : CR4Player;
	
		player = (CR4Player)activator.GetEntity();
		
		if( player )	
		{
			if( area.GetName() == "OnBoatTrigger" )
			{
				player.SetIsOnBoat( false );
				player.UnblockAction( EIAB_RunAndSprint, 'OnBoatTrigger' );
				player.UnblockAction( EIAB_CallHorse, 'OnBoatTrigger' );
				player.SetBehaviorVariable( 'bRainStormIdleAnim', 0.0 );
				
				needEnableInteractions = false;
				
				if( mountInteractionComp )
					mountInteractionComp.SetEnabled( false );
				if( mountInteractionCompPassenger )
					mountInteractionCompPassenger.SetEnabled( false );
			}
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if( ( interactionComponentName == "mountExplorationInteraction" || interactionComponentName == "mountExplorationInteractionPassenger" ) && activator == thePlayer && !HasDrowned() )
		{
			if( !thePlayer.IsActionAllowed( EIAB_MountVehicle ) )
				return false;
				
			return true;
		}
	}
	
	event OnInteractionAttached( interaction : CInteractionComponent )
	{
		interaction.SetEnabled( needEnableInteractions );
	}
	
	timer function DrowningDismount( dt : float, id : int )
	{
		if( !boatComp )
		{
			LogBoatFatal( "Entity doesn't have boat component." );
			return;
		}
		
		boatComp.IssueCommandToDismount( DT_normal );
	}
	
	public function HasDrowned() : bool 		{ return hasDrowned; }
	public function SetHasDrowned( val : bool ) 	{ hasDrowned = val; }
	
	event OnStreamIn()
	{
	}
	
	import final function SetTeleportedFromOtherHUB( val : bool );
	
	
	
	
	
	public function GetBoatComponent() : CBoatComponent
	{
		return boatComp;
	}
	
	public function GetMountInteractionComponent( optional forPassenger : bool ) : CInteractionComponent
	{
		if( forPassenger )		
			return mountInteractionCompPassenger;
		else
			return mountInteractionComp;
	}
	
	public function SetCanBeDestroyed( val : bool )	{ canBeDestroyed = val; }
	public function GetCanBeDestroyed() : bool		{ return canBeDestroyed; }

	
	
	
}
