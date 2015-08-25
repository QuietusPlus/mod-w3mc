/*
Copyright © CD Projekt RED 2015
*/




class W3WhiteFrost extends W3Petard
{
	editable var waveProjectileTemplate : CEntityTemplate;
	editable var freezeNPCFadeInTime : float;
	editable var waveSpeedModifier : float;
	editable var waveRadius : float;

	private var collisionMask : array<name>;
	private var shaderSpeed : float;							
	private var totalTime : float;								
	private var collidedEntities : array<CGameplayEntity>;		
	private var waveProjectile : W3WhiteFrostWaveProjectile;	
	
	default waveRadius = 6.f;
	
		hint waveSpeedModifier = "Multiplier for wave progression speed - freezing effect on actors";
		hint waveRadius = "NOTE - surface fx radius is not properly calculated - fixed max radius";

	protected function ProcessLoopEffect()
	{
		
		SnapComponents(false);
		
		
		LoopComponentsEnable(true);		
		
		
		ProcessEffectPlayFXs(false);
		
		
		totalTime = 0;
		
		
		shaderSpeed = waveRadius / impactParams.surfaceFX.fxFadeInTime * waveSpeedModifier;
		
		AddTimer('OnTimeEnded', loopDuration, false, , , true);
		AddTimer('WaveProjectile', 0.3, true, , , true);
		
		
		WaveProjectile(0.3);
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var customParam : W3FrozenEffectCustomParams;
		var i : int;
		
		super.LoadDataFromItemXMLStats();
		
		
		customParam = new W3FrozenEffectCustomParams in this;
		customParam.freezeFadeInTime = freezeNPCFadeInTime;
		for(i=0; i<impactParams.buffs.Size(); i+=1)
		{
			if(impactParams.buffs[i].effectType == EET_Frozen)
			{
				impactParams.buffs[i].effectCustomParam = customParam;
				break;
			}
		}
	}
	
	
	timer function WaveProjectile(dt : float, optional id : int)
	{
		totalTime += dt;
		
		
		if(!waveProjectile)
		{
			waveProjectile = (W3WhiteFrostWaveProjectile)theGame.CreateEntity(waveProjectileTemplate, GetWorldPosition());			
			waveProjectile.Init(this);
			waveProjectile.SetWhiteFrost(this);
			
			collisionMask.PushBack('Character');
			collisionMask.PushBack('Static');
			collisionMask.PushBack('RigidBody');
			collisionMask.PushBack('Corpse');
		}
		
		waveProjectile.SphereOverlapTest( totalTime * shaderSpeed, collisionMask );
		
		
		thePlayer.GetVisualDebug().AddSphere(EffectTypeToName(RandRange(EnumGetMax('EEffectType'))), totalTime * shaderSpeed, GetWorldPosition(), true, Color(0,0,255), 0.15);
		
		
		if(totalTime >= impactParams.surfaceFX.fxFadeInTime)
		{
			RemoveTimer('WaveProjectile');			
			waveProjectile.Destroy();
		}
	}
	
	
	public function Collided(ent : CGameplayEntity)
	{
		var ents : array<CGameplayEntity>;
		var owner : CEntity;
	
		if(collidedEntities.Contains(ent))
			return;
			
		owner = EntityHandleGet(ownerHandle);
		if(owner && IsRequiredAttitudeBetween(ent, owner, false, false, true))
			return;
			
		collidedEntities.PushBack(ent);
		ents.PushBack(ent);
		ProcessMechanicalEffect(ents, true);
		ent.OnFrostHit(this);
	}
}


class W3WhiteFrostWaveProjectile extends CProjectileTrajectory
{
	private var frostEntity : W3WhiteFrost;
	
	public function SetWhiteFrost(f : W3WhiteFrost)
	{
		frostEntity = f;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var ent : CGameplayEntity;
	
		if(collidingComponent)
		{
			ent = (CGameplayEntity)collidingComponent.GetEntity();
			if(ent)
				frostEntity.Collided(ent);
		}
	}
}