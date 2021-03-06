/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_AutoSwimmingStaminaRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoSwimmingStaminaRegen;
	default regenStat = CRS_SwimmingStamina;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_SwimmingStamina ) >= 1.0f )
		{
			target.StopSwimmingStaminaRegen();
		}
	}
}