/*
Copyright © CD Projekt RED 2015
*/





class W3QuestCond_SelectedSign_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_SelectedSign;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && condition.factsNames.FindFirst( eventParam ) != -1 )
		{
			condition.EvaluateImpl();
		}	
	}	
}

class W3QuestCond_SelectedSign extends CQuestScriptedCondition
{
	editable var signType : ESignType;

	private var isFulfilled	: bool;
	private var listener	: W3QuestCond_SelectedSign_Listener;
	var factsNames			: array< string >;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_SelectedSign_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterStringArray( GEC_Fact, listener, factsNames );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterStringArray( GEC_Fact, listener, factsNames );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		factsNames.Clear();
		factsNames.PushBack( "CurrentlySelectedSign" );

		isFulfilled = false;
		EvaluateImpl();
		if ( !isFulfilled )
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
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}
		return isFulfilled;	
	}
	
	function EvaluateImpl()
	{			
		isFulfilled = (GetWitcherPlayer().GetEquippedSign() == signType);
	}
}