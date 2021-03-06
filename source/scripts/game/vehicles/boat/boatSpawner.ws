/*
Copyright © CD Projekt RED 2015
*/


import statemachine class W3BoatSpawner extends CGameplayEntity
{
	public saved var spawnedBoat : EntityHandle;	
	editable var respawnDistance : float;
	var isAttemptingBoatSpawn : bool;
	
	default autoState = 'Idle';
	default respawnDistance = 10.f;
	default isAttemptingBoatSpawn = false;
	
	hint respawnDistance = "Distance at which new boat is spawned, must be lower than spawner's streaming distance";
	
	event OnSpawned(spawndata : SEntitySpawnData)
	{
		if(!isAttemptingBoatSpawn)
		{
			if(!EntityHandleGet(spawnedBoat) && GetCurrentStateName() != 'SpawnBoatLatent' )
				GotoState('SpawnBoatLatent');
			else
				GotoStateAuto();
		}
	}
	
	event OnStreamIn()
	{
		var currentStateName : name;
		
		if(!isAttemptingBoatSpawn)
		{
			currentStateName = GetCurrentStateName();	
			if(!EntityHandleGet(spawnedBoat) && currentStateName != 'SpawnBoatLatent' )
				GotoState('SpawnBoatLatent');
			else
				GotoStateAuto();
		}
	}
	
	
	
	event OnStreamOut()
	{
		var boat : CEntity;
		var distToBoat : float;
		
		boat = EntityHandleGet(spawnedBoat);
		if(boat)
		{
			distToBoat =  VecDistance2D(GetWorldPosition(), boat.GetWorldPosition());
			
			
			if(distToBoat > respawnDistance)
			{
				theGame.AddDynamicallySpawnedBoatHandle(spawnedBoat);
				EntityHandleSet( spawnedBoat, NULL );
			}
		}
		
		GotoStateAuto();
	}
	
	timer function DelayedSpawnBoat( td : float , id : int)
	{
		RemoveTimer( 'DelayedSpawnBoat' );
		( ( W3BoatSpawnerStateSpawnBoatLatent )GetState( 'SpawnBoatLatent' ) ).OnDelayedSpawnedBoat();
	}
}

state Idle in W3BoatSpawner {}

state SpawnBoatLatent in W3BoatSpawner
{
	event OnEnterState(prevStateName : name)
	{
		if( !parent.isAttemptingBoatSpawn )
		{
			parent.isAttemptingBoatSpawn = true;
			parent.AddTimer( 'DelayedSpawnBoat', 0.1f );
		}
		else
		{	
			GotoStateAuto();
		}
	}
	
	event OnDelayedSpawnedBoat()
	{
		Entry_SpawnBoatLatent();
		parent.isAttemptingBoatSpawn = false;
		GotoStateAuto();
	}
	
	entry function Entry_SpawnBoatLatent()
	{
		var entityTemplate : CEntityTemplate;
		var boat : W3Boat;
		var pos : Vector;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync('boat');	
		if ( entityTemplate )
		{
			pos = virtual_parent.GetWorldPosition();
			pos.Z = theGame.GetWorld().GetWaterLevel(pos);
			boat = (W3Boat)theGame.CreateEntity(entityTemplate, pos, virtual_parent.GetWorldRotation(), , , , PM_Persist);
			if(boat)
			{
				EntityHandleSet(parent.spawnedBoat, boat);
			}
		}
	}
}
