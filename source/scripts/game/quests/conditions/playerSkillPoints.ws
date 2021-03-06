/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_PlayerSkillPoints extends CQuestScriptedCondition
{
	editable var freeSkillPoints : int;
	editable var comparator : ECompareOp;

	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
		{
			return false;
		}
		
		return ProcessCompare( comparator, witcher.levelManager.GetPointsFree(ESkillPoint), freeSkillPoints );
	}
}