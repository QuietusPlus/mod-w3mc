/*
Copyright © CD Projekt RED 2015
*/




class W3Potion_Cat extends CBaseGameplayEffect
{
	private saved var highlightObjectsRange, highlightEnemiesRange : float;
	private var witcher : W3PlayerWitcher;				
	private var isScreenFxActive : bool;
	private var timeSinceLastHighlight, timeSinceLastEnemyHighlight : float;
	private const var HIGHLIGHT_REFRESH_DT, ENEMY_HIGHLIGHT_DT : float;
	
	default effectType = EET_Cat;
	default HIGHLIGHT_REFRESH_DT = 0.5;
	default ENEMY_HIGHLIGHT_DT = 1.0f;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			LogAssert(false, "W3Potion_Cat.OnEffectAdded: added not on player character!");
			timeLeft = 0;
			return true;
		}
	
		witcher = GetWitcherPlayer();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'highlightObjectsRange', min, max);
		highlightObjectsRange = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'highlightEnemiesRange', min, max);
		highlightEnemiesRange = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		timeSinceLastHighlight = 0;
		timeSinceLastEnemyHighlight = 0;
		
		
		EnableScreenFx(true);
	}
		
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
			
		if(highlightObjectsRange > 0)			
		{
			timeSinceLastHighlight += dt;
			
			if(timeSinceLastHighlight >= HIGHLIGHT_REFRESH_DT)
			{
				timeSinceLastHighlight = 0;
				witcher.HighlightObjects(highlightObjectsRange, 1);
			}
		}
		
		
		if(highlightEnemiesRange > 0)			
		{
			timeSinceLastEnemyHighlight += dt;
			
			if(timeSinceLastEnemyHighlight >= ENEMY_HIGHLIGHT_DT)
			{
				timeSinceLastEnemyHighlight = 0;
				witcher.HighlightEnemies(highlightEnemiesRange, 1);
			}
		}
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		EnableScreenFx(false);			
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		EnableScreenFx(true);			
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);		
		witcher = GetWitcherPlayer();		
		timeSinceLastHighlight = 0;
		timeSinceLastEnemyHighlight = 0;
		
		if(!IsPaused())
			EnableScreenFx(true);
	}
	
	event OnEffectRemoved()
	{
		EnableScreenFx(false);
		super.OnEffectRemoved();
	}
	
	private final function EnableScreenFx(en : bool)
	{
		if(en)
		{
			EnableCatViewFx( 1.0f );	
			SetTintColorsCatViewFx(Vector(0.1f,0.12f,0.13f,0.6f),Vector(0.075f,0.1f,0.11f,0.6f),0.2f);
			SetBrightnessCatViewFx(350.0f);
			SetViewRangeCatViewFx(200.0f);
			SetPositionCatViewFx( Vector(0,0,0,0) , true );	
			SetHightlightCatViewFx( Vector(0.3f,0.1f,0.1f,0.1f),0.05f,1.5f);
			SetFogDensityCatViewFx( 0.5 );
			isScreenFxActive = true;
		}
		else
		{
			isScreenFxActive = false;
			DisableCatViewFx( 1.0f );
		}
	}
}
