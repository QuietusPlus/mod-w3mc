/*
Copyright © CD Projekt RED 2015
*/





class W3ActorIdleTrigger extends CEntity
{
	protected var affectedActor : CActor;			
	editable var affectedEntityTag : name;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		affectedActor = (CActor)(activator.GetEntity());
		AddTimer( 'SignalIsInsideArea', 2.0, true, , , true );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)(activator.GetEntity());
		if(actor)
		{
			if ( (IsNameValid(affectedEntityTag) && actor.HasTag( affectedEntityTag )) || !IsNameValid(affectedEntityTag))
			{
				actor.SignalGameplayEvent('LeftIdleTrigger');
				RemoveTimer( 'SignalIsInsideArea' );
			}
		}
	}
	
	timer function SignalIsInsideArea( t: float , id : int)
	{
		if(affectedActor)
		{
			if( (IsNameValid(affectedEntityTag) && affectedActor.HasTag(affectedEntityTag) ) || !IsNameValid(affectedEntityTag) )
			{
				affectedActor.SignalGameplayEvent('InIdleTrigger');
			}
		}
	}
}