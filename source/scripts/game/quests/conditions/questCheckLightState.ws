/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_CheckLightState_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_CheckLightState;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.lightSourceTag )
		{
			condition.FindEntity();
		}	
	}
}

class W3QuestCond_CheckLightState extends CQuestScriptedCondition
{
	editable var lightSourceTag : name;
	editable var targetState 	: bool;

	var lightEntity : CEntity;
	var component   : CGameplayLightComponent;	
	var listener	: W3QuestCond_CheckLightState_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_CheckLightState_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, lightSourceTag );
			FindEntity();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, lightSourceTag );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{	
		FindEntity();
		if ( !lightEntity )
		{
			RegisterListener( true );
		}			
	}

	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}
	
	function Evaluate() : bool
	{
		if ( !component )
		{
			if ( lightEntity )
			{
				component = (CGameplayLightComponent)lightEntity.GetComponentByClassName( 'CGameplayLightComponent' ); 
			}
			else if ( !listener )
			{
				RegisterListener( true );
			}
		}

		if ( component )
		{
			return component.IsLightOn() == targetState;
		}

		return false;
	}
	
	function FindEntity()
	{
		lightEntity = theGame.GetEntityByTag( lightSourceTag );
		if ( lightEntity && listener )
		{
			RegisterListener( false );
		}
	}
}
