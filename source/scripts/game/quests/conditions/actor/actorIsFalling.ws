/*
Copyright © CD Projekt RED 2015
*/

class W3QuestCond_IsFalling extends CQCActorScriptedCondition
{
	function Evaluate(act : CActor ) : bool
	{		
		return act.IsFalling();
	}
}