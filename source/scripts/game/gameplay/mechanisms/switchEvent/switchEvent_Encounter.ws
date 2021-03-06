/*
Copyright © CD Projekt RED 2015
*/





enum EEncounterOperation
{
	EO_Enable,
	EO_Disable,
	EO_Toggle
}

class W3SE_Encounter extends W3SwitchEvent
{
	editable var encounterTag	: name;
	editable var operation 		: EEncounterOperation;
	
	hint encounter = "Tag of the encounter";
	hint enable = "If the encounter is to be enabled or not";
	
	public function Perform( parnt : CEntity )
	{
		var entity		: CEntity;
		var encounter	: CEncounter;
		
		entity =  theGame.GetEntityByTag( encounterTag );
		if ( !entity )
		{
			return;
		}
		encounter = (CEncounter)entity;
		if ( !encounter )
		{
			return;
		}
		
		switch ( operation )
		{
		case EO_Enable:
			encounter.EnableEncounter( true );
			break;
		case EO_Disable:
			encounter.EnableEncounter( false );
			break;
		case EO_Toggle:
			encounter.EnableEncounter( !encounter.IsEnabled() );
			break;
		}
	}
}