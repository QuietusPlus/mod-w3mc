/*
Copyright © CD Projekt RED 2015
*/




class W3Potion_Fact_Params extends W3PotionParams
{
	var factName : name;
}


class W3Potion_Fact extends CBaseGameplayEffect
{
	protected saved var fact : name;				

	default isPotionEffect = true;
	default effectType = EET_Fact;
	default isPositive = false;
	default isNegative = false;
	default isNeutral = true;
		
	public function Init(params : SEffectInitInfo)
	{
		super.Init(params);
		
		
		isPositive = false;
		isNegative = false;
		isNeutral = true;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3Potion_Fact_Params;
	
		super.OnEffectAdded(customParams);
		
		params = (W3Potion_Fact_Params)customParams;
		fact = params.factName;
		effectNameLocalisationKey = "pot_name_" + fact;
		effectDescriptionLocalisationKey = "pot_desc_" + fact;
		FactsAdd(fact);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		FactsRemove(fact);
	}
	
	public function GetFactName() : name
	{
		return fact;
	}
	
	public function GetEffectNameLocalisationKey() : string
	{
		return "effect_" + NameToString(fact);
	}
	
	
	
	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var factPot : W3Potion_Fact;
		
		factPot = (W3Potion_Fact)e;
		if(factPot)
		{
			
			
			return EI_Cumulate;
		}
		
		return EI_Pass;
	}
}