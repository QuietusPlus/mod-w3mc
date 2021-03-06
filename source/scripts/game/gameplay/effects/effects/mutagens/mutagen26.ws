/*
Copyright © CD Projekt RED 2015
*/




class W3Mutagen26_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen26;
	
	public final function GetReturnedDamage(out points : float, out percents : float)
	{
		var min, max, dmg : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'returned_damage', min, max);
		dmg = GetAttributeRandomizedValue(min, max);
		
		points = dmg.valueAdditive;
		percents = dmg.valueMultiplicative;
	}
}