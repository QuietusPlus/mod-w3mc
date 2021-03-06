/*
Copyright © CD Projekt RED 2015
*/




abstract class W3Mutagen_Effect extends CBaseGameplayEffect
{
	private saved var toxicityOffset : float;
	
	default isPositive = true;
	default isNegative = false;
	default isNeutral = false;
	default isPotionEffect = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var mutParams : W3MutagenBuffCustomParams;
		
		
		if(target != GetWitcherPlayer())
		{
			isActive = false;
			return false;
		}
		
		super.OnEffectAdded(customParams);
		
		mutParams = (W3MutagenBuffCustomParams)customParams;
		if(mutParams)
		{
			toxicityOffset = mutParams.toxicityOffset;
			GetWitcherPlayer().AddToxicityOffset(toxicityOffset);
		}
		else
		{
			toxicityOffset = 0;
		}
	}
	
	event OnEffectRemoved()
	{
		GetWitcherPlayer().RemoveToxicityOffset(toxicityOffset);
		super.OnEffectRemoved();
	}
}

class W3MutagenBuffCustomParams extends W3PotionParams
{
	var toxicityOffset : float;
}