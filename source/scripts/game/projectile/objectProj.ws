/*
Copyright © CD Projekt RED 2015
*/

class W3ObjectProjectile extends CProjectileTrajectory
{
	private var action : W3DamageAction;
	private var owner : CActor;
	
	function SetOwner( actor : CActor )
	{
		owner = actor;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim : CGameplayEntity;
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		if ( victim )
		{
			
			action = new W3DamageAction in this;
			action.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, 20.f );
			action.attacker = owner;
			action.victim = victim;
			theGame.damageMgr.ProcessAction( action );
			
			delete action;
		}		
	}
	
	event OnRangeReached()
	{
		StopAllEffects();
		StopProjectile();
		
		Destroy();
	}
	
	timer function TimeDestroy( deltaTime : float, id : int )
	{
		Destroy();
	}	
}