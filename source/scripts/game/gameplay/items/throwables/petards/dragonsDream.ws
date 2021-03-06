/*
Copyright © CD Projekt RED 2015
*/




class W3DragonsDream extends W3Petard
{
	editable var gasEntityTemplate : CEntityTemplate;	
	private var gasEntity : W3ToxicCloud;
	private var burningChance : float;
	
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{
		if(isImpact)
		{
			super.ProcessMechanicalEffect(targets, isImpact, dt);
			
			gasEntity = (W3ToxicCloud)theGame.CreateEntity(gasEntityTemplate, GetWorldPosition());
			gasEntity.explosionDamage.valueAdditive = loopParams.damages[0].dmgVal;
			gasEntity.SetBurningChance(CalculateAttributeValue(GetOwner().GetInventory().GetItemAttributeValue(itemId, 'burning_chance')));
			gasEntity.SetExplodingTargetDamages(GetExplodingTargetDamages());
			gasEntity.SetFromBomb();
		}
	}
	
	protected function OnTimeEndedFunction(dt : float)
	{
		if( gasEntity )
		{
			gasEntity.PermanentlyDisable();
		}
		
		super.OnTimeEndedFunction(dt);
	}
	
	protected function DestroyWhenNoFXPlayedFunction(dt : float) : bool
	{
		var ret : bool;
		
		ret = super.DestroyWhenNoFXPlayedFunction(dt);
		
		if( ret && gasEntity )
		{
			gasEntity.PermanentlyDisable();
		}
			
		return ret;
	}
	
	
	private function GetExplodingTargetDamages() : array<SRawDamage>
	{
		var dmg : SRawDamage;
		var inv : CInventoryComponent;
		var i : int;
		var atts : array<name>;
		var attStr, dmgStr : string;
		var dmgName : name;
		var damages : array<SRawDamage>;
		
		inv = GetOwner().GetInventory();
		inv.GetItemAttributes(itemId, atts);
		for(i=0; i<atts.Size(); i+=1)
		{
			attStr = NameToString(atts[i]);
			dmgStr = StrAfterFirst(attStr, "explosion");
			dmgName = DamageTypeStringToName(dmgStr);
			if(IsNameValid(dmgName))
			{
				dmg.dmgType = dmgName;
				dmg.dmgVal = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[i]));
				damages.PushBack(dmg);
			}
		}
		
		return damages;
	}
}