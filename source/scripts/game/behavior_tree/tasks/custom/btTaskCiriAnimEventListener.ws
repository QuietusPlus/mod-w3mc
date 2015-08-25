/*
Copyright © CD Projekt RED 2015
*/

 

class CBTTaskSmartSetVisible extends IBehTreeTask
{
	var makeVisbleOnDeactivate : bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( makeVisbleOnDeactivate )
		{
			SmartSetVisible(true);
			GetNPC().SetGameplayVisibility(true);
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'appear' )
		{
			SmartSetVisible(true);
			GetNPC().SetGameplayVisibility(true);
			return true;
		}
		else if ( animEventName == 'disappear' )
		{
 			SmartSetVisible(false);
 			GetNPC().SetGameplayVisibility(false);
 			return true;
		}
		
		return false;
	}
	
	function SmartSetVisible( toggle : bool )
	{
		GetActor().SetHideInGame(!toggle);
		
		MakeInvulnerable(!toggle);
	}
	
	function SetVisible(toggle : bool, compList : array<CComponent>)
	{
		var i : int;
		
		for ( i=0; i<=compList.Size(); i+=1 )
		{
			((CDrawableComponent)compList[i]).SetVisible(toggle);
		}
	}
	
	function MakeInvulnerable( toggle : bool )
	{
		var owner : CActor = GetActor();
		if ( toggle )
		{
			owner.SetImmortalityMode(AIM_Invulnerable, AIC_Combat);
			owner.SetCanPlayHitAnim(false);
			owner.EnableCharacterCollisions(false);
			owner.AddBuffImmunity_AllNegative('SmartSetVisible', true);
		}
		else
		{
			owner.SetImmortalityMode(AIM_None, AIC_Combat);
			owner.SetCanPlayHitAnim(true);
			owner.EnableCharacterCollisions(true);
			owner.RemoveBuffImmunity_AllNegative('SmartSetVisible');
		}
	}
}

class CBTTaskSmartSetVisibleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSmartSetVisible';

	editable var makeVisbleOnDeactivate : bool;
	
	hint makeVisbleOnDeactivate = "failSafe";
	
	default makeVisbleOnDeactivate = true; 
}
