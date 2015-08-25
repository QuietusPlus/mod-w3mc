/*
Copyright © CD Projekt RED 2015
*/






class W3FireSource extends CGameplayEntity
{
	var glComponent : CGameplayLightComponent;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		glComponent = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
	}
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( !glComponent )
		{
			glComponent = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		}
		
		if (!glComponent)
			return false;

		if ( activator == thePlayer && interactionComponentName == "ApplyDamage" && ((CGameplayLightComponent)glComponent).IsLightOn() )
		{
			thePlayer.AddEffectDefault(EET_Burning, this, 'environment');
			AddTimer ( 'ApplyFireSourceDamage', 3.0f, true );
		}
	}

	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( !glComponent )
		{
			glComponent = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		}
		
		if (!glComponent)
			return false;

		if ( activator == thePlayer && interactionComponentName == "ApplyDamage" && ((CGameplayLightComponent)glComponent).IsLightOn() )
		{
			RemoveTimer ( 'ApplyFireSourceDamage' );
		}
	}
	
	timer function ApplyFireSourceDamage( dt : float, id : int )
	{
		if ( !glComponent )
		{
			glComponent = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		}
		
		if ( !glComponent.IsLightOn() )
		{
			RemoveTimer ( 'ApplyFireSourceDamage' );
			return;
		}
		thePlayer.AddEffectDefault(EET_Burning, this, 'environment');		
	}
}	


