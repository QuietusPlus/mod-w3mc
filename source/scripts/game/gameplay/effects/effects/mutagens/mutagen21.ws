/*
Copyright © CD Projekt RED 2015
*/




class W3Mutagen21_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen21;
	
	
	
	
	public final function Heal()
	{
		var vitality : float;
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'healingRatio', min, max);
		vitality = target.GetStatMax(BCS_Vitality);
		vitality *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		target.GainStat(BCS_Vitality, vitality);
	}
}