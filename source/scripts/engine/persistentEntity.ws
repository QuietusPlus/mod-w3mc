/*
Copyright © CD Projekt RED 2015
*/




import class CPeristentEntity extends CEntity
{
	event OnBehaviorSnaphot() { return false; }
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
}