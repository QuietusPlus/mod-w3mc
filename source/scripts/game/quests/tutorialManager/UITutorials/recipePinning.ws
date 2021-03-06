/*
Copyright © CD Projekt RED 2015
*/

state RecipePinning in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PIN, SHOP : name;
	private var isClosing : bool;
	
		default PIN 	= 'TutorialCraftingPin';
		default SHOP	= 'TutorialCraftingPin2';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(PIN, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(PIN);
		CloseHint(SHOP);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == PIN)
		{
			ShowHint(SHOP, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y);
		}		
	}	
}