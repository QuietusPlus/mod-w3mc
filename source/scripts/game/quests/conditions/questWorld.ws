/*
Copyright © CD Projekt RED 2015
*/





class W3QuestCond_World extends CQuestScriptedCondition
{
	editable var currentArea : EAreaName;		default currentArea = AN_Undefined;
	
	function Evaluate() : bool
	{
		return currentArea == theGame.GetCommonMapManager().GetCurrentArea();
	}
}