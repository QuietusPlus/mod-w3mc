/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0.9 + RandF() / 5;	
		
		
		SetEffectValue();
	}
	
	
	protected function SetEffectValue()
	{
		effectValue = thePlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s11);
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	
			target.PlayEffect('yrden_shock');
		}
	}
}