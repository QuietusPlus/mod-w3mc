/*
Copyright © CD Projekt RED 2015
*/





class W3ReplacerCommoner extends W3Replacer
{
		default explorationInputContext = 'Exploration_Replacer_Commoner';
		default combatInputContext = 'Combat_Replacer_Warrior';

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		
		BlockAction( EIAB_Signs, 'being_replacer' );
		BlockAction( EIAB_OpenInventory, 'being_replacer' );
		BlockAction( EIAB_CallHorse, 'being_replacer' );
		BlockAction( EIAB_FastTravel, 'being_replacer' );
		BlockAction( EIAB_OpenMeditation, 'being_replacer' );
		BlockAction( EIAB_OpenMap, 'being_replacer' );
		BlockAction( EIAB_OpenCharacterPanel, 'being_replacer' );
		BlockAction( EIAB_OpenJournal, 'being_replacer' );
		BlockAction( EIAB_OpenAlchemy, 'being_replacer' );
		BlockAction( EIAB_Dive, 'being_replacer' );
		
		
		GotoStateAuto();
	}
}