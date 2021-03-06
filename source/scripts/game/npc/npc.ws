/*
Copyright © CD Projekt RED 2015
*/




enum EConverserType
{
	CT_General,
	CT_Nobleman,
	CT_Guard,
	CT_Mage,
	CT_Bandit,
	CT_Scoiatael,
	CT_Peasant,
	CT_Poor,
	CT_Child
};


statemachine import class CNewNPC extends CActor
{
	
	
	
	editable var isImmortal 		: bool;				
	editable var isInvulnerable 	: bool;				
	editable var willBeUnconscious 	: bool;				
	editable var minUnconsciousTime : float;    		default minUnconsciousTime = 20.f;
	
	editable var unstoppable		: bool;				hint unstoppable = "won't play hit reaction nor critical state reaction";
	
	editable var RemainsTags 		: array<name>;		hint RemainsTags="If set then the NPC's remains will be tagged with given tags";
	editable var level 				: int;				default level = 1;
			 var currentLevel		: int;
	editable saved var levelFakeAddon     : int;				default levelFakeAddon = 0;
			 var newGamePlusFakeLevelAddon : bool;		default newGamePlusFakeLevelAddon = false;
	editable var isMiniBossLevel    : bool;				default isMiniBossLevel = false;
	editable var suppressBroadcastingReactions		: bool;		default suppressBroadcastingReactions = false;
	editable saved var dontUseReactionOneLiners		: bool;		default dontUseReactionOneLiners = false;
	editable saved var disableConstrainLookat		: bool;		default disableConstrainLookat = false;
	
	editable var isMonsterType_Group   : bool;  		default isMonsterType_Group = false;
	
	editable var useSoundValue		: bool;				default useSoundValue = false;
	editable var soundValue			: int;	
	
	
	editable var clearInvOnDeath			: bool;	
	default clearInvOnDeath = false;
	
	editable var noAdaptiveBalance : bool;
	default noAdaptiveBalance = false;
	
	editable var grantNoExperienceAfterKill : bool;
	default grantNoExperienceAfterKill = false;
	
	hint disableConstrainLookat = "It will disable lookats form reactions and from QuestLookat block";
	hint useSoundValue = "If true it will add the SoundValue to the threat Rating used for combat music control";
	hint soundValue = "This value will be added or subtracted from sound system to achieve final threat Rating";
	
	
	
	import private saved var npcGroupType 		: ENPCGroupType;	default npcGroupType = ENGT_Enemy;
	
	
	private optional autobind 	horseComponent 		: W3HorseComponent = single;
	private var 		isHorse 			: bool;
	private saved var 	canFlee				: bool; 	default 	canFlee	= true;
	private var 		isFallingFromHorse 	: bool; 	default 	isFallingFromHorse = false;
	
	private var		immortalityInitialized	: bool;
	
	
	private var 	canBeFollowed 			: bool;		default 		canBeFollowed = false;

	
	private var 	bAgony					: bool;		default 		bAgony 	= false;
	private var		bFinisher 				: bool;		default 		bFinisher = false;
	private var		bPlayDeathAnim 			: bool;		default			bPlayDeathAnim = true;
	private var		bAgonyDisabled			: bool;		default			bAgonyDisabled = false;
	private var		bFinisherInterrupted	: bool;
	
	private var		bIsInHitAnim : bool;
	
	
	private var		threatLevel					: int;				default			threatLevel = 10;
	private var 	counterWindowStartTime 		: EngineTime;		
	private var		bIsCountering				: bool;
	private var		allowBehGraphChange			: bool;				default			allowBehGraphChange = true;
	private var		aardedFlight				: bool;				
	public var		lastMeleeHitTime			: EngineTime;		
	
	private saved var preferedCombatStyle : EBehaviorGraph;
	
	
	private var		previousStance				: ENpcStance;		default			previousStance	= NS_Normal;
	private var		regularStance				: ENpcStance;		default			regularStance	= NS_Normal;
	
	
	private var 	currentFightStage			: ENPCFightStage;
	
	
	private var 	currentState 				: CName;			default 		autoState = 'NewIdle';

	private var 	behaviorGraphEventListened	: array<name>;
	
	
	private var 	isTemporaryOffGround			: bool;
	
	
	private var		isUnderwater 				: bool;		default isUnderwater = false;
	
	
	private var isTranslationScaled 			: bool; 
	
	
	private var tauntedToAttackTimeStamp 		: float;
	
	private var hitCounter 						: int;		default hitCounter = 0;
	private var totalHitCounter 				: int;		default totalHitCounter = 0;
	public var customHits 						: bool;		default customHits = false;
	
	
	
	
	public var isTeleporting 					: bool;			default isTeleporting = false;
	
	
	
	
	
	
	
	public var itemToEquip 						: SItemUniqueId;
	
	
	private saved var wasBleedingBurningPoisoned 	: bool;		default wasBleedingBurningPoisoned = false;
	
	
	public 	var wasInTalkInteraction				: bool;
	private var wasInCutscene						: bool;
	public 	var shieldDebris 						: CItemEntity;
	public 	var lastMealTime						: float;	default lastMealTime = -1;
	public 	var packName							: name;		
	public 	var isPackLeader						: bool;		
	private var mac 								: CMovingPhysicalAgentComponent;
	
	
	private saved  var isTalkDisabled				: bool; default isTalkDisabled = false;
	private   	   var isTalkDisabledTemporary		: bool; default isTalkDisabledTemporary = false;
	
	event OnGameDifficultyChanged( previousDifficulty : int, currentDifficulty : int )
	{
		if ( HasAbility('difficulty_CommonEasy') ) RemoveAbility('difficulty_CommonEasy');
		if ( HasAbility('difficulty_CommonMedium') )  RemoveAbility('difficulty_CommonMedium');
		if ( HasAbility('difficulty_CommonHard') )  RemoveAbility('difficulty_CommonHard');
		if ( HasAbility('difficulty_CommonHardcore') )  RemoveAbility('difficulty_CommonHardcore');
		
		switch ( theGame.GetSpawnDifficultyMode() )
		{
		case EDM_Easy:
			AddAbility('difficulty_CommonEasy');
			break;
		case EDM_Medium:
			AddAbility('difficulty_CommonMedium');
			break;
		case EDM_Hard:
			AddAbility('difficulty_CommonHard');
			break;
		case EDM_Hardcore:
			AddAbility('difficulty_CommonHardcore');
			break;
		}	

		AddTimer('AddLevelBonuses', 0.1, true);	
	}
	
	timer function ResetTalkInteractionFlag( td : float , id : int)
	{
		if ( !IsSpeaking() )
		{
			wasInTalkInteraction = false;
			RemoveTimer('ResetTalkInteractionFlag');
		}
	}
		
	protected function OnCombatModeSet( toggle : bool )
	{
		super.OnCombatModeSet( toggle );
		
		if( toggle )
		{
			SetCombatStartTime();
			SetCombatPartStartTime();
			
			
			
			
			RecalcLevel();
		}
		else
		{
			ResetCombatStartTime();
			ResetCombatPartStartTime();
		}		
	}
	
	public function SetImmortalityInitialized(){ immortalityInitialized = true; }
	
	public function SetNPCType( type : ENPCGroupType ) { npcGroupType = type; }
	public function GetNPCType() : ENPCGroupType { return npcGroupType; }
	
	public function SetCanBeFollowed( val : bool ) { canBeFollowed = val; }
	public function CanBeFollowed() : bool { return canBeFollowed; }
	
	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
		var witcher : W3PlayerWitcher;
		var levelDiff : int;
	
		super.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
		
		if(animEventType == AET_DurationStart )
		{
			
			
			witcher = GetWitcherPlayer();
			
			
			
			if(GetTarget() == witcher )
			{
				levelDiff = GetLevel() - witcher.GetLevel();
				
				if ( levelDiff < theGame.params.LEVEL_DIFF_DEADLY )
					this.SetDodgeFeedback( true );
			}
			
			if ( IsCountering() )
			{
				
				if(GetTarget() == witcher && ( thePlayer.IsActionAllowed(EIAB_Dodge) || thePlayer.IsActionAllowed(EIAB_Roll) ) && witcher.GetStat(BCS_Toxicity) > 0 && witcher.CanUseSkill(S_Alchemy_s16))
					witcher.StartFrenzy();
			}
		}
		else if(animEventType == AET_DurationEnd )
		{
			witcher = GetWitcherPlayer();
			
			if(GetTarget() == witcher )
			{		
				this.SetDodgeFeedback( false );
			}
		}
	}
	
	public function SetDodgeFeedback( flag : bool )
	{
		
		if ( flag )
		{
			thePlayer.SetDodgeFeedbackTarget( this );
		}
		else
		{
			thePlayer.SetDodgeFeedbackTarget( NULL );
		}
	}
	
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		super.OnBlockingSceneEnded( output );
		wasInCutscene = true;
	}
	
	public function WasInCutscene() : bool
	{
		return wasInCutscene;
	}
	
	
	public function IsVIP() : bool
	{
		var tags : array<name>;
		var i : int;
		
		
		tags = GetTags();
		for ( i = 0; i < tags.Size(); i+=1 )
		{
			if ( tags[i] == 'vip' )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	
	
	
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var lvlDiff, playerLevel: int;
		var heading 		: float;
		var remainingDuration : float;
		var oldLevel : int;
		
		currentLevel = level;
		
		super.OnSpawned(spawnData);
		
		
		SetThreatLevel();
		
		
		GotoStateAuto();		
		
		
		isTalkDisabledTemporary = false;
		
		
		if(!spawnData.restored && !immortalityInitialized )
		{
			SetCanPlayHitAnim( true );
			
			if(isInvulnerable)
			{
				SetImmortalityMode(AIM_Invulnerable, AIC_Default);
			}
			else if(isImmortal)
			{
				SetImmortalityMode(AIM_Immortal, AIC_Default);
			}
			else if( willBeUnconscious )
			{
				SetImmortalityMode(AIM_Unconscious, AIC_Default);
				SignalGameplayEventParamFloat('ChangeUnconsciousDuration',minUnconsciousTime);
			}
			else if ( npcGroupType == ENGT_Commoner || npcGroupType == ENGT_Guard || npcGroupType == ENGT_Quest )
			{
				SetImmortalityMode(AIM_Unconscious, AIC_Default);	
			}
		}
		
		
		if( npcGroupType == ENGT_Guard )
		{
			SetOriginalInteractionPriority( IP_Prio_5 );
			RestoreOriginalInteractionPriority();
		}
		else if( npcGroupType == ENGT_Quest )
		{
			SetOriginalInteractionPriority( IP_Max_Unpushable );
			RestoreOriginalInteractionPriority();
		}
		
		
		
		mac = (CMovingPhysicalAgentComponent)GetMovingAgentComponent();
		if(mac && IsFlying() )
			mac.SetAnimatedMovement( true );
		
		
		RegisterCollisionEventsListener();		
		
		
		if (focusModeSoundEffectType == FMSET_None)
			SetFocusModeSoundEffectType( FMSET_Gray );
		
		heading	= AngleNormalize( GetHeading() );
		
		SetBehaviorVariable( 'requestedFacingDirection', heading );
		
		if ( disableConstrainLookat )
			SetBehaviorVariable( 'disableConstraintLookat', 1.f);
			
		
		SoundSwitch( "vo_3d", 'vo_3d_long', 'head' );
		
		AddAnimEventCallback('EquipItemL' ,			'OnAnimEvent_EquipItemL');
		AddAnimEventCallback('HideItemL' ,			'OnAnimEvent_HideItemL');
		AddAnimEventCallback('HideWeapons' ,		'OnAnimEvent_HideWeapons');
		AddAnimEventCallback('TemporaryOffGround' ,	'OnAnimEvent_TemporaryOffGround');
		AddAnimEventCallback('OwlSwitchOpen' ,		'OnAnimEvent_OwlSwitchOpen');
		AddAnimEventCallback('OwlSwitchClose' ,		'OnAnimEvent_OwlSwitchClose');
		AddAnimEventCallback('Goose01OpenWings' ,	'OnAnimEvent_Goose01OpenWings');
		AddAnimEventCallback('Goose01CloseWings' ,	'OnAnimEvent_Goose01CloseWings');
		AddAnimEventCallback('Goose02OpenWings' ,	'OnAnimEvent_Goose02OpenWings');
		AddAnimEventCallback('Goose02CloseWings' ,	'OnAnimEvent_Goose02CloseWings');
		AddAnimEventCallback('NullifyBurning' ,		'OnAnimEvent_NullifyBurning');
		AddAnimEventCallback('setVisible' ,			'OnAnimEvent_setVisible');
		AddAnimEventCallback('extensionWalk' ,		'OnAnimEvent_extensionWalk');
		AddAnimEventCallback('weaponSoundType' ,	'OnAnimEvent_weaponSoundType');
		
		if(HasAbility('_canBeFollower') && theGame.GetDifficultyMode() != EDM_Hardcore) 
			RemoveAbility('_canBeFollower');

		
			
			
		
		if(!spawnData.restored && (FactsQuerySum("NewGamePlus") > 0 || (!HasAbility('NoAdaptBalance') && currentLevel > 1 ) ) )
		{
			
			
			if ( theGame.IsActive() )
			{
				if( ( FactsQuerySum("NewGamePlus") > 0 ) && !HasTag('animal') )
				{
					if( !HasAbility('NPCDoNotGainBoost') && !HasAbility('NewGamePlusFakeLevel') )
					{
						currentLevel += theGame.params.GetNewGamePlusLevel();
					}
					else if ( !HasAbility('NPCDoNotGainNGPlusLevel') )
					{
						newGamePlusFakeLevelAddon = true;
					}
					
				}
				else
				{
					
					if ( ( theGame.GetDifficultyMode() == EDM_Easy || theGame.GetDifficultyMode() == EDM_Medium ) && playerLevel == 1 && npcGroupType != ENGT_Guard && !HasAbility('PrologModifier'))
					{
						AddAbility('PrologModifier');
					}
				}
			}	
		}		
	}
	
	
	protected function SetAbilityManager()
	{
		if(npcGroupType != ENGT_Commoner)
			abilityManager = new W3NonPlayerAbilityManager in this;		
	}
	
	protected function SetEffectManager()
	{
		if(npcGroupType != ENGT_Commoner)
			super.SetEffectManager();
	}
	
	public function  SetLevel ( _level : int )
	{
		currentLevel = _level;
		AddTimer('AddLevelBonuses', 0.1, true);
	}
	
	private function SetThreatLevel()
	{
		var temp : float;
		
		temp = CalculateAttributeValue(GetAttributeValue('threat_level'));
		if ( temp >= 0.f )
		{
			threatLevel = (int)temp;
		}
		else
		{
			LogAssert(false,"No threat_level attribute set. Threat level set to 0");
			threatLevel = 0;
		}
	}
	public function ChangeThreatLevel( newValue : int )
	{
		threatLevel = newValue;
	}
	
	 public function GetHorseUser() : CActor
	{
		if( horseComponent )
		{
			return horseComponent.GetCurrentUser();
		}
		
		return NULL;
	}
	
	
	
	
	public function GetPreferedCombatStyle() : EBehaviorGraph
	{
		return preferedCombatStyle;
	}
	
	public function SetPreferedCombatStyle( _preferedCombatStyle : EBehaviorGraph )
	{
		preferedCombatStyle = _preferedCombatStyle;
	}
	
	
	timer function WeatherBonusCheck(dt : float, id : int)
	{
		var curGameTime : GameTime;
		var dayPart : EDayPart;
		var bonusName : name;
		var curEffect : CBaseGameplayEffect;
		var moonState : EMoonState;
		var weather : EWeatherEffect;
		var params : SCustomEffectParams;
		
		if ( !IsAlive() )
		{
			return;
		}
		
		moonState = GetCurMoonState();
		
		curGameTime = GameTimeCreate();
		dayPart = GetDayPart(curGameTime);
		
		weather = GetCurWeather();
		
		bonusName = ((W3NonPlayerAbilityManager)abilityManager).GetWeatherBonus(dayPart, weather, moonState);
		
		curEffect = GetBuff(EET_WeatherBonus);
		if (curEffect)
		{
			if ( curEffect.GetAbilityName() == bonusName )
			{
				return;
			}
			else
			{
				RemoveBuff(EET_WeatherBonus);
			}
		}
		
		if (bonusName != 'None')
		{
			params.effectType = EET_WeatherBonus;
			params.creator = this;
			params.sourceName = "WeatherBonus";
			params.customAbilityName = bonusName;
			AddEffectCustom(params);
		}
	}
	
	public function IsFlying() : bool
	{
		var result : bool;
		result = ( this.GetCurrentStance() == NS_Fly );
		return result;
	}
	
	public function IsRanged() : bool
	{
		
		var weapon : SItemUniqueId;
		var weapon2 : SItemUniqueId;
	
		weapon = this.GetInventory().GetItemFromSlot( 'l_weapon' );
		weapon2 = this.GetInventory().GetItemFromSlot( 'r_weapon' );
		
		return ( this.GetInventory().GetItemCategory( weapon ) == 'bow' || this.GetInventory().GetItemCategory( weapon2 ) == 'crossbow' );
		
	}
	
	
	
	public function IsVisuallyOffGround() : bool
	{
		if( isTemporaryOffGround ) 
			return true;
		if( IsFlying() ) 
			return true;
			
		return false;
	}

	public function SetIsHorse()
	{
		if ( horseComponent )
			isHorse = true;
	}
	
	public function IsHorse() : bool
	{
		return isHorse;
	}
	
	public function GetHorseComponent() : W3HorseComponent
	{
		if ( isHorse )
			return horseComponent;
		else
			return NULL;
	}
	
	public function HideHorseAfter( time : float )
	{
		if( !isHorse )
			return;
		
		SetVisibility( false );
		SetGameplayVisibility( false );
		
		AddTimer( 'HideHorse', time );
	}
	
	private timer function HideHorse( delta : float , id : int )
	{
		Teleport( thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1000.0 );
		
		SetVisibility( true );
		SetGameplayVisibility( true );
	}
	
	public function KillHorseAfter( time : float )
	{
		if( !isHorse )
			return;
		AddTimer( 'KillHorse', time );
	}
	
	private timer function KillHorse( delta : float , id : int )
	{
		SetKinematic( false );
		Kill( true );
		SetAlive( false );
		GetComponentByClassName( 'CInteractionComponent' ).SetEnabled( false );
		PlayEffect( 'hit_ground' );
	}
	
	public timer function RemoveAxiiFromHorse( delta : float , id : int )
	{
		RemoveAbility( 'HorseAxiiBuff' );
	}
	
	public function ToggleCanFlee( val : bool ) { canFlee = val; }
	public function GetCanFlee() : bool 		{ return canFlee; }
	
	public function SetIsFallingFromHorse( val : bool ) 		
	{ 
		if( val )
		{
			AddBuffImmunity( EET_HeavyKnockdown, 'SetIsFallingFromHorse', true );
			isFallingFromHorse = true;
		}
		else
		{
			RemoveBuffImmunity( EET_HeavyKnockdown, 'SetIsFallingFromHorse' );
			isFallingFromHorse = false;
		}
	}
	public function GetIsFallingFromHorse() : bool 				{ return isFallingFromHorse; }
	
	public function SetCounterWindowStartTime(time : EngineTime)	{counterWindowStartTime = time;}
	public function GetCounterWindowStartTime() : EngineTime		{return counterWindowStartTime;}
	
	
	function GetThreatLevel() : int
	{
		return threatLevel;
	}
	
	function GetSoundValue() : int
	{
		return soundValue;
	}
		
	public function WasTauntedToAttack()
	{
		tauntedToAttackTimeStamp = theGame.GetEngineTimeAsSeconds();
	}
	
	
	
	timer function MaintainSpeedTimer( d : float , id : int)
	{
		this.SetBehaviorVariable( 'Editor_MovementSpeed', 0 );
	}
	timer function MaintainFlySpeedTimer( d : float , id : int)
	{
		this.SetBehaviorVariable( 'Editor_FlySpeed', 0 );
	}
	
	
	
	
	public function SetIsInHitAnim( toggle : bool )
	{
		bIsInHitAnim = toggle;
		if ( !toggle )
			this.SignalGameplayEvent('WasHit');
	}
	
	public function IsInHitAnim() : bool
	{
		return bIsInHitAnim;
	}
	
	public function CanChangeBehGraph() : bool
	{
		return allowBehGraphChange;
	}
	
	public function WeaponSoundType() : CItemEntity
	{
		var weapon : SItemUniqueId;
		weapon = GetInventory().GetItemFromSlot( 'r_weapon' );
		
		return GetInventory().GetItemEntityUnsafe(weapon);
	}

	
	
	
	function EnableCounterParryFor( time : float )
	{
		bCanPerformCounter = true;
		AddTimer('DisableCounterParry',time,false);
	}
	
	timer function DisableCounterParry( td : float , id : int)
	{
		bCanPerformCounter = false;
	}
	
	var combatStorage : CBaseAICombatStorage;
	
	public final function IsAttacking() : bool
	{
		if ( !combatStorage )
			combatStorage = (CBaseAICombatStorage)GetAIStorageObject('CombatData');
			
		if(combatStorage)
		{
			return combatStorage.GetIsAttacking();
		}
		
		return false;
	}
		
	public final function RecalcLevel()
	{
		if(!IsAlive())
			return;
			
		AddLevelBonuses(0, 0);
	}
	
	
	protected function PerformCounterCheck(parryInfo: SParryInfo) : bool
	{
		return false;
	}
	
	
	protected function PerformParryCheck(parryInfo : SParryInfo) : bool
	{
		var mult : float;
		var isHeavy : bool;
		var npcTarget : CNewNPC;
		var fistFightParry : bool;
		
		if ( !parryInfo.canBeParried )
			return false;
		
		if( this.IsHuman() && ((CHumanAICombatStorage)this.GetAIStorageObject('CombatData')).IsProtectedByQuen() )
			return false;
		if( !CanParryAttack() )
			return false;
		if( !FistFightCheck(parryInfo.target, parryInfo.attacker, fistFightParry) )
			return false;
		if( IsInHitAnim() && HasTag( 'imlerith' ) )
			return false;	
		
		npcTarget = (CNewNPC)parryInfo.target;
		
		if( npcTarget.IsShielded(parryInfo.attacker) || ( !npcTarget.HasShieldedAbility() && parryInfo.targetToAttackerAngleAbs < 90 ) )
		{	
			isHeavy = IsHeavyAttack(parryInfo.attackActionName);
						
			
			if( HasStaminaToParry( parryInfo.attackActionName ) && ( HasAbility( 'ablParryHeavyAttacks' ) || !isHeavy ) )
			{
				
				SetBehaviorVariable( 'parryAttackType', (int)PAT_Light );
				
				if( isHeavy )
					SignalGameplayEventParamInt( 'ParryPerform', 1 );
				else
					SignalGameplayEventParamInt( 'ParryPerform', 0 );
			}
			else
			{
				
				SetBehaviorVariable( 'parryAttackType', (int)PAT_Heavy );
			
				if( isHeavy )
					SignalGameplayEventParamInt( 'ParryStagger', 1 );
				else
					SignalGameplayEventParamInt( 'ParryStagger', 0 );
			}
			
			if( parryInfo.attacker == thePlayer && parryInfo.attacker.IsWeaponHeld( 'fist' ) && !parryInfo.target.IsWeaponHeld( 'fist' ) )
			{
				parryInfo.attacker.SetBehaviorVariable( 'reflectAnim', 1.f );
				parryInfo.attacker.ReactToReflectedAttack(this);				
			}
			else 
			{
				if( isHeavy )
				{
					ToggleEffectOnShield( 'heavy_block', true );
				}
				else
				{
					ToggleEffectOnShield( 'light_block', true );
				}
			}
			
			return true;
		}		
		
		return false;
	}
		
	public function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
	{		
		return GetPowerStatValue(CPS_SpellPower);
	}
	
	
	
	
	
	timer function AddLevelBonuses (dt : float, id : int)
	{
		var i : int;
		var lvlDiff : int;
		var ciriEntity  : W3ReplacerCiri;
		
		RemoveTimer('AddLevelBonuses');
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		
		if( ( ( GetNPCType() != ENGT_Guard ) && ( currentLevel + (int)CalculateAttributeValue(GetAttributeValue('level',,true)) < 2 ) ) ) return;
		if ( HasAbility('NPCDoNotGainBoost') ) return;
		
			
		if ( HasAbility(theGame.params.ENEMY_BONUS_DEADLY) ) RemoveAbility(theGame.params.ENEMY_BONUS_DEADLY); else
		if ( HasAbility(theGame.params.ENEMY_BONUS_HIGH) ) RemoveAbility(theGame.params.ENEMY_BONUS_HIGH); else
		if ( HasAbility(theGame.params.ENEMY_BONUS_LOW) ) RemoveAbility(theGame.params.ENEMY_BONUS_LOW); else
		if ( HasAbility(theGame.params.MONSTER_BONUS_DEADLY) ) RemoveAbility(theGame.params.MONSTER_BONUS_DEADLY); else
		if ( HasAbility(theGame.params.MONSTER_BONUS_HIGH) ) RemoveAbility(theGame.params.MONSTER_BONUS_HIGH); else
		if ( HasAbility(theGame.params.MONSTER_BONUS_LOW) ) RemoveAbility(theGame.params.MONSTER_BONUS_LOW);
			
		if ( IsHuman() && GetStat( BCS_Essence, true ) < 0 )
		{
			if ( GetNPCType() != ENGT_Guard )
			{
				if ( !HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL) ) AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, currentLevel-1);
		    } else
		    {
				if ( !HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL) ) AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, 1 + GetWitcherPlayer().GetLevel() + RandRange( 11, 13 ) );
		    }
		    
			if ( thePlayer.IsCiri() && theGame.GetDifficultyMode() == EDM_Hardcore && !HasAbility('CiriHardcoreDebuffHuman') ) AddAbility('CiriHardcoreDebuffHuman');
		        
			if ( !ciriEntity ) 
			{
				lvlDiff = (int)CalculateAttributeValue(GetAttributeValue('level',,true)) - thePlayer.GetLevel();
				if 		( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) { if ( !HasAbility(theGame.params.ENEMY_BONUS_DEADLY) ) { AddAbility(theGame.params.ENEMY_BONUS_DEADLY, true); AddBuffImmunity(EET_Blindness, 'DeadlyEnemy', true); AddBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy', true); } }	
				else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )  { if ( !HasAbility(theGame.params.ENEMY_BONUS_HIGH) ) AddAbility(theGame.params.ENEMY_BONUS_HIGH, true);}
				else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )  { }
				else 					  { if ( !HasAbility(theGame.params.ENEMY_BONUS_LOW) ) AddAbility(theGame.params.ENEMY_BONUS_LOW, true); }		
			}	 
		} 
		else
		{
			if ( GetStat( BCS_Vitality, true ) > 0 ) 
			{
				if ( !ciriEntity ) 
				{
					lvlDiff = (int)CalculateAttributeValue(GetAttributeValue('level',,true)) - thePlayer.GetLevel();
					if 		( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) { if ( !HasAbility(theGame.params.ENEMY_BONUS_DEADLY) ) { AddAbility(theGame.params.ENEMY_BONUS_DEADLY, true); AddBuffImmunity(EET_Blindness, 'DeadlyEnemy', true); AddBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy', true); } }	
					else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )  { if ( !HasAbility(theGame.params.ENEMY_BONUS_HIGH) ) AddAbility(theGame.params.ENEMY_BONUS_HIGH, true);}
					else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )  { }
					else 					  { if ( !HasAbility(theGame.params.ENEMY_BONUS_LOW) ) AddAbility(theGame.params.ENEMY_BONUS_LOW, true); }		
					
					if ( !HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL) ) AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, currentLevel-1);
				}
			} else
			{
			
			if ( (int)CalculateAttributeValue( GetAttributeValue('armor') ) > 0 )
			{
				if ( GetIsMonsterTypeGroup() )
				{
					if ( !HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED) ) AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED, currentLevel-1);
				} else
				{
					if ( !HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED) ) AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED, currentLevel-1);
				}
			}
			else
			{
				if ( GetIsMonsterTypeGroup() )
				{
					if ( !HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP) ) AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP, currentLevel-1);
				} else
				{
					if ( !HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL) ) AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL, currentLevel-1);
				}
			}
			
			
			if ( thePlayer.IsCiri() && theGame.GetDifficultyMode() == EDM_Hardcore && !HasAbility('CiriHardcoreDebuffMonster') ) AddAbility('CiriHardcoreDebuffMonster');
				
			if ( !ciriEntity ) 
			{
				lvlDiff = (int)CalculateAttributeValue(GetAttributeValue('level',,true)) - thePlayer.GetLevel();
				if 		( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) { if ( !HasAbility(theGame.params.MONSTER_BONUS_DEADLY) ) { AddAbility(theGame.params.MONSTER_BONUS_DEADLY, true); AddBuffImmunity(EET_Blindness, 'DeadlyEnemy', true); AddBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy', true); } }	
				else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )  { if ( !HasAbility(theGame.params.MONSTER_BONUS_HIGH) ) AddAbility(theGame.params.MONSTER_BONUS_HIGH, true); }
				else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )  { }
				else 					  { if ( !HasAbility(theGame.params.MONSTER_BONUS_LOW) ) AddAbility(theGame.params.MONSTER_BONUS_LOW, true); }		
			}
			}	 
			
		}
		
	}
	
	public function GainStat( stat : EBaseCharacterStats, amount : float )
	{
		
		if(stat == BCS_Panic && IsHorse() && thePlayer.GetUsedVehicle() == this && thePlayer.HasBuff(EET_Mutagen25))
		{
			return;
		}
		
		super.GainStat(stat, amount);
	}
	
	public function ForceSetStat(stat : EBaseCharacterStats, val : float)
	{
		
		if(stat == BCS_Panic && IsHorse() && thePlayer.GetUsedVehicle() == this && thePlayer.HasBuff(EET_Mutagen25) && val >= GetStat(BCS_Panic))
		{
			return;
		}
		
		super.ForceSetStat(stat, val);
	}
	
	
	
	
	
	timer function FundamentalsAchFailTimer(dt : float, id : int)
	{
		RemoveTag('failedFundamentalsAchievement');
	}
	
	
	
	
	protected function CriticalBuffInformBehavior(buff : CBaseGameplayEffect)
	{
		SignalGameplayEventParamInt('CriticalState',(int)GetBuffCriticalType(buff));
	}
	
	
	public function StartCSAnim(buff : CBaseGameplayEffect) : bool
	{
		if(super.StartCSAnim(buff))
		{
			CriticalBuffInformBehavior(buff);
			return true;
		}
		 
		return false;
	}
	
	public function CSAnimStarted(buff : CBaseGameplayEffect) : bool
	{
		return super.StartCSAnim(buff);
	}
	
	function SetCanPlayHitAnim( flag : bool )
	{
		if( !flag && this.IsHuman() && this.GetAttitude( thePlayer ) != AIA_Friendly )
		{
			super.SetCanPlayHitAnim( flag );
		}
		else
		{
			super.SetCanPlayHitAnim( flag );
		}
	}

	
	
	event OnStartFistfightMinigame()
	{
		super.OnStartFistfightMinigame();
		
		thePlayer.ProcessLockTarget( this );
		SignalGameplayEventParamInt('ChangePreferedCombatStyle',(int)EBG_Combat_Fists );
		SetTemporaryAttitudeGroup( 'fistfight_opponent', AGP_Fistfight );
		ForceVulnerableImmortalityMode();
		if ( !thePlayer.IsFistFightMinigameToTheDeath() )
			SetImmortalityMode(AIM_Unconscious, AIC_Fistfight);
		if(FactsQuerySum("NewGamePlus") > 0)
		{FistFightNewGamePlusSetup();}
		FistFightHealthSetup();
		
	}
	
	event OnEndFistfightMinigame()
	{	
		SignalGameplayEvent('ResetPreferedCombatStyle');
		ResetTemporaryAttitudeGroup( AGP_Fistfight );
		RestoreImmortalityMode();
		LowerGuard();
		if ( IsKnockedUnconscious() )
		{
			SignalGameplayEvent('ForceStopUnconscious');
		}
		if ( !IsAlive() )
		{
			Revive();
		}
		FistFightHealthSetup();
		
		super.OnEndFistfightMinigame();
	}
		
	private function FistFightHealthSetup()
	{
		
		if ( HasAbility( 'fistfight_minigame' ) )
		{
			FistFightersHealthDiff();
		}
		else return;

	}
	
	private function FistFightersHealthDiff()
	{
		var vitality 		: float;
		
		if ( HasAbility( 'StatsFistsTutorial' ) )
		{
			AddAbility( 'HealthFistFightTutorial', false );
		}
		else if ( HasAbility( 'StatsFistsEasy' ) )
		{
			AddAbility( 'HealthFistFightEasy', false );
		}
		else if ( HasAbility( 'StatsFistsMedium' ) )
		{
			AddAbility( 'HealthFistFightMedium', false );
		}
		else if ( HasAbility( 'StatsFistsHard' ) )
		{
			AddAbility( 'HealthFistFightHard', false );
		}
		vitality = abilityManager.GetStatMax( BCS_Vitality );
		SetHealthPerc( 100 );
	}
	
	private function FistFightNewGamePlusSetup()
	{
		if ( HasAbility( 'NPCLevelBonus' ) )
		{
			RemoveAbilityMultiple( 'NPCLevelBonus', theGame.params.GetNewGamePlusLevel() );
			newGamePlusFakeLevelAddon = true;
			currentLevel -= theGame.params.GetNewGamePlusLevel();
			RecalcLevel(); 
		}
	}
	
	private function ApplyFistFightLevelDiff()
	{
		var lvlDiff 	: int;
		var i 			: int;
		var attribute 	: SAbilityAttributeValue; 
		var min, max	: SAbilityAttributeValue;
		var ffHP, ffAP	: SAbilityAttributeValue;
		var dm 			: CDefinitionsManagerAccessor; 
		
		lvlDiff = (int)CalculateAttributeValue(GetAttributeValue('level',,true)) - thePlayer.GetLevel();
		
		if ( !HasAbility('NPC fists _Stats') )
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributeValue('NPC fists _Stats', 'vitality', min, max);
			ffHP = GetAttributeRandomizedValue(min, max);
			dm.GetAbilityAttributeValue('NPC fists _Stats', 'attack_power', min, max);
			ffAP = GetAttributeRandomizedValue(min, max);
		}
		
   		if ( lvlDiff < -theGame.params.LEVEL_DIFF_HIGH )
		{
			for (i=0; i < 5; i+=1)
			{
				AddAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, true);
				attribute = GetAttributeValue('vitality');
				attribute += ffHP;
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
				attribute = GetAttributeValue('attack_power');
				attribute += ffAP;
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
			}
		}
		else if ( lvlDiff < 0 )
		{
			for (i=0; i < -lvlDiff; i+=1)
			{
				AddAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, true);
				attribute = GetAttributeValue('vitality');
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
				attribute = GetAttributeValue('attack_power');
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
			}
		}
		else if ( lvlDiff > theGame.params.LEVEL_DIFF_HIGH )
			AddAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, 5);
		else if ( lvlDiff > 0  )
			AddAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, lvlDiff);
	}
	
	private function RemoveFistFightLevelDiff()
	{
		RemoveAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, 5);
		RemoveAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, 5);
	}

	
	
	
	
	private function IsThisStanceRegular( Stance : ENpcStance ) : bool
	{
		if( Stance == NS_Normal || 
			Stance == NS_Strafe ||
			Stance == NS_Retreat )
		{
			return true;
		}
		
		return false;
	}
	
	private function IsThisStanceDefensive( Stance : ENpcStance ) : bool
	{
		if( Stance == NS_Guarded || 
			Stance == NS_Guarded )
		{
			return true;
		}
		
		return false;
	}
	
	function GetCurrentStance() : ENpcStance
	{
		var l_currentStance : int;
		l_currentStance = (int)this.GetBehaviorVariable( 'npcStance');
		return l_currentStance;
	}
	
	function GetRegularStance() : ENpcStance
	{
		return this.regularStance;
	}
	
	function ReturnToRegularStance()
	{
		this.SetBehaviorVariable( 'npcStance',(int)this.regularStance);
	}
	
	function IsInRegularStance() : bool
	{
		if(	GetCurrentStance() == GetRegularStance() )
		{
			return true;
		}
		
		return false;
	}
	
	function ChangeStance( newStance : ENpcStance ) : bool
	{
		if ( IsThisStanceDefensive( newStance ) )
		{
			LogChannel('NPC ChangeStance', "You shouldn't use this function to change to this stance - " + newStance );
		}
		else if ( IsThisStanceRegular( newStance ) )
		{
			if ( this.SetBehaviorVariable( 'npcStance',(int)newStance) )
			{
				this.regularStance = newStance;
				return true;
			}
		}
		else
		{
			return this.SetBehaviorVariable( 'npcStance',(int)newStance);
		}
		return false;
	}
	
	function RaiseGuard() : bool
	{
		SetGuarded( true );
		return true;
	}
	
	function LowerGuard() : bool
	{
		SetGuarded( false );
		return true;
	}
	
	
	
	
	
	function IsInAgony() : bool
	{
		return bAgony;
	}
	
	function EnterAgony()
	{
		bAgony = true;
	}
	
	function EndAgony()
	{
		bAgony = false;
	}
	
	function EnableDeathAndAgony()
	{
		bPlayDeathAnim = true;
		bAgonyDisabled = false;
	}
	
	function EnableDeath()
	{
		bPlayDeathAnim = true;
	}
	
	function EnableAgony()
	{
		bAgonyDisabled = false;
	}
	
	function DisableDeathAndAgony()
	{
		bPlayDeathAnim = false;
		bAgonyDisabled = true;
	}
	function DisableAgony()
	{
		bAgonyDisabled = true;
	}
	
	function IsAgonyDisabled() : bool
	{
		return bAgonyDisabled;
	}
	
	function IsInFinisherAnim() : bool
	{
		return bFinisher;
	} 
	
	function FinisherAnimStart()
	{
		bPlayDeathAnim = false;		
		bFinisher = true;
		SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Death );
	}
	
	function FinisherAnimInterrupted()
	{
		bPlayDeathAnim 			= true;		
		bFinisher 				= false;
		bFinisherInterrupted 	= true;
	}
	
	function ResetFinisherAnimInterruptionState()
	{
		bFinisherInterrupted = false;
	}
	
	function WasFinisherAnimInterrupted() : bool
	{
		return bFinisherInterrupted;
	}
	
	function FinisherAnimEnd()
	{
		bFinisher = false;
	}
	
	function ShouldPlayDeathAnim() : bool
	{
		return bPlayDeathAnim;
	}
	
	function NPCGetAgonyAnim() : CName
	{
		var agonyType : float;
		agonyType = GetBehaviorVariable( 'AgonyType');
		
		if (agonyType == (int)AT_ThroatCut)
		{
			return 'man_throat_cut_start';
		}
		else if(agonyType == (int)AT_Knockdown)
		{
			return 'man_wounded_crawl_killed';
		}
		else
			return '';
	}
	
	function GeraltGetAgonyAnim() : CName
	{
		var agonyType : float;
		agonyType = GetBehaviorVariable( 'AgonyType');
		
		if (agonyType == (int)AT_ThroatCut)
		{
			return 'man_ger_throat_cut_attack_01';
		}
		else if(agonyType == (int)AT_Knockdown)
		{
			return 'man_ger_crawl_finish';
		}
		else
			return '';
	}
	
	
	
	
	
	protected function PlayHitAnimation(damageAction : W3DamageAction, animType : EHitReactionType)
	{
		var node : CNode;
				
		SetBehaviorVariable( 'HitReactionWeapon', ProcessSwordOrFistHitReaction( this, (CActor)damageAction.attacker ) );
		SetBehaviorVariable( 'HitReactionType',(int)animType);
		if ( damageAction.attacker )
		{
			node = (CNode)damageAction.causer;
			if (node)
			{
				SetHitReactionDirection(node);
			}
			else
			{
				SetHitReactionDirection(damageAction.attacker);
			}
			SetDetailedHitReaction(damageAction.GetSwingType(), damageAction.GetSwingDirection());
		}
		
		if ( this.customHits )
		{
			damageAction.customHitReactionRequested = true;
		}
		else
		{
			damageAction.hitReactionAnimRequested = true;
		}
	}
	
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
	{
		var ret 							: bool;
		var percentageLoss					: float;
		var totalHealth						: float;
		var damaveValue						: float;
		var healthLossToForceLand_perc		: SAbilityAttributeValue;
		var witcher							: W3PlayerWitcher;
		var node							: CNode;
		var boltCauser						: W3BoltProjectile;
		var attackAction					: W3Action_Attack;
		
		damaveValue 				 = damageAction.GetDamageDealt();
		totalHealth 				 = GetMaxHealth();
		percentageLoss 			 	= damaveValue / totalHealth;
		healthLossToForceLand_perc 	 = GetAttributeValue( 'healthLossToForceLand_perc' );
		
		
		if( percentageLoss >= healthLossToForceLand_perc.valueBase && ( GetCurrentStance() == NS_Fly || ( !IsUsingVehicle() && GetCurrentStance() != NS_Swim && !((CMovingPhysicalAgentComponent) GetMovingAgentComponent()).IsOnGround()) ) )
		{
			
			if( !((CBaseGameplayEffect) damageAction.causer ) )
			{
				damageAction.AddEffectInfo(	EET_Knockdown);
			}
		}
		
		
		boltCauser = (W3BoltProjectile)( damageAction.causer );
		if( boltCauser )
		{
			if( HasAbility( 'AdditiveHits' ) )
			{
				SetUseAdditiveHit( true, true, true );
				ret = super.ReactToBeingHit(damageAction, buffNotApplied);
				
				if( ret || damageAction.DealsAnyDamage())
					SignalGameplayDamageEvent('BeingHit', damageAction );
			}
			else if( HasAbility( 'mon_wild_hunt_default' ) )
			{
				ret = false;
			}
			else if( !boltCauser.HasTag( 'bodkinbolt' ) || this.IsUsingHorse() || RandRange(100) < 75.f ) 
			{
				ret = super.ReactToBeingHit(damageAction, buffNotApplied);
				
				if( ret || damageAction.DealsAnyDamage())
					SignalGameplayDamageEvent('BeingHit', damageAction );
			}
			else
			{
				ret = false;
			}
		}
		else
		{
			ret = super.ReactToBeingHit(damageAction, buffNotApplied);
			
			if( ret || damageAction.DealsAnyDamage() )
				SignalGameplayDamageEvent('BeingHit', damageAction );
		}
		
		if( damageAction.additiveHitReactionAnimRequested == true )
		{
			node = (CNode)damageAction.causer;
			if (node)
			{
				SetHitReactionDirection(node);
			}
			else
			{
				SetHitReactionDirection(damageAction.attacker);
			}
		}
		
		if(((CPlayer)damageAction.attacker || !((CNewNPC)damageAction.attacker)) && damageAction.DealsAnyDamage())
			theTelemetry.LogWithLabelAndValue( TE_FIGHT_ENEMY_GETS_HIT, damageAction.victim.ToString(), (int)damageAction.processedDmg.vitalityDamage + (int)damageAction.processedDmg.essenceDamage );
		
		
		witcher = GetWitcherPlayer();
		if ( damageAction.attacker == witcher && HasBuff( EET_AxiiGuardMe ) )
		{
			
			if(!witcher.CanUseSkill(S_Magic_s05) || witcher.GetSkillLevel(S_Magic_s05) < 3)
				RemoveBuff(EET_AxiiGuardMe, true);
		}
		
		if(damageAction.attacker == thePlayer && damageAction.DealsAnyDamage() && !damageAction.IsDoTDamage())
		{
			attackAction = (W3Action_Attack) damageAction;
			
		}
		
		return ret;
	}
	
	
	public function GetHitCounter(optional total : bool) : int
	{
		if ( total )
			return totalHitCounter;
		return hitCounter;
	}
	
	public function IncHitCounter()
	{
		hitCounter += 1;
		totalHitCounter += 1;
		AddTimer('ResetHitCounter',2.0,false);
	}
	
	private timer function ResetHitCounter( deta : float , id : int)
	{
		hitCounter = 0;
	}	
	
	
	
	
	function Kill(optional ignoreImmortalityMode : bool, optional attacker : CGameplayEntity, optional source : name )
	{
		var action : W3DamageAction;
		
		if ( theGame.CanLog() )
		{		
			LogDMHits("CActor.Kill: called for actor <<" + this + ">>");
		}
		
		action = GetKillAction(ignoreImmortalityMode, attacker, source);
		
		if ( this.IsKnockedUnconscious() )
		{
			DisableDeathAndAgony();
			OnDeath(action);
		}
		else if ( !abilityManager )
		{
			OnDeath(action);
		}
		else
		{
			if ( ignoreImmortalityMode )
				this.immortalityFlags = 0;
				
			theGame.damageMgr.ProcessAction(action);
		}
		
		delete action;
	}
	
	public final function GetLevel() : int
	{
		return (int)CalculateAttributeValue(GetAttributeValue('level',,true));
	}
	
	public final function GetLevelFromLocalVar() : int
	{
		return currentLevel;
	}
	
	function GetExperienceDifferenceLevelName( out strLevel : string ) : string
	{
		var lvlDiff : int;
		var currentLevel : int;
		var ciriEntity  : W3ReplacerCiri;

		currentLevel = GetLevel() + levelFakeAddon;
		if ( newGamePlusFakeLevelAddon )
		{
			currentLevel += theGame.params.GetNewGamePlusLevel();
		}
			
		if( GetAttitude( thePlayer ) != AIA_Hostile )
		{
			if( ( GetAttitudeGroup() != 'npc_charmed' ) )
			{
				strLevel = "";
				return "none";
			}
		}
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		if ( ciriEntity )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}
		
		lvlDiff = currentLevel - thePlayer.GetLevel();
		
		if ( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY )
		{
			strLevel = "";
			return "deadlyLevel";
		}	
		else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#FF1919\">" + currentLevel + "</font>"; 
			return "highLevel";
		}
		else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}
		else
		{
			strLevel = "<font color=\"#E6E6E6\">" + currentLevel + "</font>"; 
			return "lowLevel";
		}
		return "none";
	}
	
	
	private function ShouldGiveExp(attacker : CGameplayEntity) : bool
	{
		var actor : CActor;
		var npc : CNewNPC;
		var victimAt : EAIAttitude;
		var giveExp : bool;
		
		victimAt = GetAttitudeBetween(thePlayer, this);
		giveExp = false;
		
		
		if(victimAt == AIA_Hostile)
		{
			if(attacker == thePlayer && !((W3PlayerWitcher)thePlayer) )
			{
				
				giveExp = false;
			}
			else if(attacker == thePlayer)
			{
				
				giveExp = true;
			}
			
			else if(VecDistance(thePlayer.GetWorldPosition(), GetWorldPosition()) <= 20)
			{
				npc = (CNewNPC)attacker;
				if(!npc || npc.npcGroupType != ENGT_Guard)	
				{
					actor = (CActor)attacker;
					if(!actor)
					{
						
						giveExp = true;
					}
					else if(actor.HasTag(theGame.params.TAG_NPC_IN_PARTY) || actor.HasBuff(EET_AxiiGuardMe))
					{
						
						giveExp = true;
					}							
				}
			}
		}
		
		return giveExp;
	}
	
	function AddBestiaryKnowledge()
	{
		var manager : CWitcherJournalManager;
		manager = theGame.GetJournalManager();
		if ( GetSfxTag() == 'sfx_arachas' && HasAbility('mon_arachas_armored') )	activateBaseBestiaryEntryWithAlias("BestiaryArmoredArachas", manager); else
		if ( GetSfxTag() == 'sfx_arachas' && HasAbility('mon_poison_arachas')  )	activateBaseBestiaryEntryWithAlias("BestiaryPoisonousArachas", manager); else
		if ( GetSfxTag() == 'sfx_bear' )											activateBaseBestiaryEntryWithAlias("BestiaryBear", manager); else
		if ( GetSfxTag() == 'sfx_alghoul' )											activateBaseBestiaryEntryWithAlias("BestiaryAlghoul", manager); else
		if ( HasAbility('mon_greater_miscreant') )								activateBaseBestiaryEntryWithAlias("BestiaryMiscreant", manager); else
		if ( HasAbility('mon_basilisk') )										activateBaseBestiaryEntryWithAlias("BestiaryBasilisk", manager); else
		if ( GetSfxTag() == 'sfx_cockatrice' )										activateBaseBestiaryEntryWithAlias("BestiaryCockatrice", manager); else
		if ( GetSfxTag() == 'sfx_arachas' && !HasAbility('mon_arachas_armored') && !HasAbility('mon_poison_arachas') ) activateBaseBestiaryEntryWithAlias("BestiaryCrabSpider", manager); else
		if ( GetSfxTag() == 'sfx_katakan' && HasAbility('mon_ekimma') )				activateBaseBestiaryEntryWithAlias("BestiaryEkkima", manager); else
		if ( GetSfxTag() == 'sfx_elemental_dao' )									activateBaseBestiaryEntryWithAlias("BestiaryElemental", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_soldier_tailed') ) activateBaseBestiaryEntryWithAlias("BestiaryEndriaga", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_worker') )	activateBaseBestiaryEntryWithAlias("BestiaryEndriagaWorker", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_soldier_spikey') ) activateBaseBestiaryEntryWithAlias("BestiaryEndriagaTruten", manager); else
		if ( HasAbility('mon_forktail_young') || HasAbility('mon_forktail') || HasAbility('mon_forktail_mh') ) activateBaseBestiaryEntryWithAlias("BestiaryForktail", manager); else
		if ( GetSfxTag() == 'sfx_ghoul' )											activateBaseBestiaryEntryWithAlias("BestiaryGhoul", manager); else
		if ( GetSfxTag() == 'sfx_golem' )											activateBaseBestiaryEntryWithAlias("BestiaryGolem", manager); else
		if ( GetSfxTag() == 'sfx_katakan' && !HasAbility('mon_ekimma') )			activateBaseBestiaryEntryWithAlias("BestiaryKatakan", manager); else
		if ( GetSfxTag() == 'sfx_ghoul' && HasAbility('mon_greater_miscreant') )	activateBaseBestiaryEntryWithAlias("BestiaryMiscreant", manager); else
		if ( HasAbility('mon_nightwraith')|| HasAbility('mon_nightwraith_mh') )	activateBaseBestiaryEntryWithAlias("BestiaryMoonwright", manager); else
		if ( HasAbility('mon_noonwraith'))										activateBaseBestiaryEntryWithAlias("BestiaryNoonwright", manager); else
		if ( HasAbility('mon_lycanthrope') )									activateBaseBestiaryEntryWithAlias("BestiaryLycanthrope", manager); else
		if ( GetSfxTag() == 'sfx_werewolf' )										activateBaseBestiaryEntryWithAlias("BestiaryWerewolf", manager); else
		if ( GetSfxTag() == 'sfx_wyvern' )											activateBaseBestiaryEntryWithAlias("BestiaryWyvern", manager); else
		if ( HasAbility('mon_czart') )											activateBaseBestiaryEntryWithAlias("BestiaryCzart", manager); else
		if ( GetSfxTag() == 'sfx_bies' )											activateBaseBestiaryEntryWithAlias("BestiaryBies", manager); else
		if ( GetSfxTag() == 'sfx_wild_dog' )										activateBaseBestiaryEntryWithAlias("BestiaryDog", manager); else
		if ( GetSfxTag() == 'sfx_drowner' )											activateBaseBestiaryEntryWithAlias("BestiaryDrowner", manager); 
		if ( GetSfxTag() == 'sfx_elemental_ifryt' )									activateBaseBestiaryEntryWithAlias("BestiaryFireElemental", manager); else
		if ( GetSfxTag() == 'sfx_fogling' )											activateBaseBestiaryEntryWithAlias("BestiaryFogling", manager); else
		if ( GetSfxTag() == 'sfx_gravehag' )										activateBaseBestiaryEntryWithAlias("BestiaryGraveHag", manager); else
		if ( GetSfxTag() == 'sfx_gryphon' )											activateBaseBestiaryEntryWithAlias("BestiaryGriffin", manager); else
		if ( HasAbility('mon_erynia') )											activateBaseBestiaryEntryWithAlias("BestiaryErynia", manager); else
		if ( GetSfxTag() == 'sfx_harpy' )											activateBaseBestiaryEntryWithAlias("BestiaryHarpy", manager); else
		if ( GetSfxTag() == 'sfx_ice_giant' )										activateBaseBestiaryEntryWithAlias("BestiaryIceGiant", manager); else
		if ( GetSfxTag() == 'sfx_lessog' )											activateBaseBestiaryEntryWithAlias("BestiaryLeshy", manager); else
		if ( GetSfxTag() == 'sfx_nekker' )											activateBaseBestiaryEntryWithAlias("BestiaryNekker", manager); else
		if ( GetSfxTag() == 'sfx_siren' )											activateBaseBestiaryEntryWithAlias("BestiarySiren", manager); else
		if ( HasTag('ice_troll') )												activateBaseBestiaryEntryWithAlias("BestiaryIceTroll", manager); else
		if ( GetSfxTag() == 'sfx_troll_cave' )										activateBaseBestiaryEntryWithAlias("BestiaryCaveTroll", manager); else
		if ( GetSfxTag() == 'sfx_waterhag' )										activateBaseBestiaryEntryWithAlias("BestiaryWaterHag", manager); else
		if ( GetSfxTag() == 'sfx_wildhunt_minion' )									activateBaseBestiaryEntryWithAlias("BestiaryWhMinion", manager); else
		if ( GetSfxTag() == 'sfx_wolf' )											activateBaseBestiaryEntryWithAlias("BestiaryWolf", manager); else
		if ( GetSfxTag() == 'sfx_wraith' )											activateBaseBestiaryEntryWithAlias("BestiaryWraith", manager); else
		if ( HasAbility('mon_cyclops') ) 										activateBaseBestiaryEntryWithAlias("BestiaryCyclop", manager); else
		if ( HasAbility('mon_ice_golem') )										activateBaseBestiaryEntryWithAlias("BestiaryIceGolem", manager); else
		if ( HasAbility('mon_gargoyle') )										activateBaseBestiaryEntryWithAlias("BestiaryGargoyle", manager); else
		if ( HasAbility('mon_rotfiend') || HasAbility('mon_rotfiend_large')) 	activateBaseBestiaryEntryWithAlias("BestiaryGreaterRotFiend", manager);
		
		
	}
	
	
	public function CalculateExperiencePoints(optional skipLog : bool) : int
	{
		var finalExp : int;
		var exp : float;
		var lvlDiff : int;
		var modDamage, modArmor, modVitality, modOther : float;
		
		if ( grantNoExperienceAfterKill || HasAbility('Zero_XP' ) || GetNPCType() == ENGT_Guard ) return 0;
		
		modDamage = CalculateAttributeValue(GetAttributeValue('RendingDamage',,true));
		modDamage += CalculateAttributeValue(GetAttributeValue('BludgeoningDamage',,true));
		modDamage += CalculateAttributeValue(GetAttributeValue('FireDamage',,true));
		modDamage += CalculateAttributeValue(GetAttributeValue('ElementalDamage',,true));
		modDamage += CalculateAttributeValue(GetPowerStatValue(CPS_AttackPower, , true));
		modDamage *= 5;
		
		modArmor = CalculateAttributeValue(GetTotalArmor()) * 100;
		
		modVitality = GetStatMax(BCS_Essence) + 3 * GetStatMax(BCS_Vitality);

		if ( HasAbility('AcidSpit' ) ) modOther = modOther + 2;
		if ( HasAbility('Aggressive' ) ) modOther = modOther + 2;
		if ( HasAbility('Charge' ) ) modOther = modOther + 3;
		if ( HasAbility('ContactBlindness' ) ) modOther = modOther + 2;
		if ( HasAbility('ContactSlowdown' ) ) modOther = modOther + 2;
		if ( HasAbility('Cursed' ) ) modOther = modOther + 2;
		if ( HasAbility('BurnIgnore' ) ) modOther = modOther + 2;
		if ( HasAbility('DamageBuff' ) ) modOther = modOther + 2;
		if ( HasAbility('Draconide' ) ) modOther = modOther + 2;
		if ( HasAbility('Fireball' ) ) modOther = modOther + 2;
		if ( HasAbility('Flashstep' ) ) modOther = modOther + 2;
		if ( HasAbility('Flying' ) ) modOther = modOther + 10;
		if ( HasAbility('Frost' ) ) modOther = modOther + 4;
		if ( HasAbility('EssenceRegen' ) ) modOther = modOther + 2;
		if ( HasAbility('Gargoyle' ) ) modOther = modOther + 2;
		if ( HasAbility('Hypnosis' ) ) modOther = modOther + 2;
		if ( HasAbility('IceArmor' ) ) modOther = modOther + 5;
		if ( HasAbility('InstantKillImmune' ) ) modOther = modOther + 2;
		if ( HasAbility('JumpAttack' ) ) modOther = modOther + 2;
		if ( HasAbility('Magical' ) ) modOther = modOther + 2;
		if ( HasAbility('MistForm' ) ) modOther = modOther + 2;
		if ( HasAbility('MudTeleport' ) ) modOther = modOther + 2;
		if ( HasAbility('MudAttack' ) ) modOther = modOther + 2;
		if ( HasAbility('PoisonCloud' ) ) modOther = modOther + 2;
		if ( HasAbility('PoisonDeath' ) ) modOther = modOther + 2;
		if ( HasAbility('Rage' ) ) modOther = modOther + 2;
		if ( HasAbility('Relic' ) ) modOther = modOther + 5;
		if ( HasAbility('Scream' ) ) modOther = modOther + 2;
		if ( HasAbility('Shapeshifter' ) ) modOther = modOther + 5;
		if ( HasAbility('Shout' ) ) modOther = modOther + 2;
		if ( HasAbility('Spikes' ) ) modOther = modOther + 2;
		if ( HasAbility('StaggerCounter' ) ) modOther = modOther + 2;
		if ( HasAbility('StinkCloud' ) ) modOther = modOther + 2;
		if ( HasAbility('Summon' ) ) modOther = modOther + 2;
		if ( HasAbility('Tail' ) ) modOther = modOther + 5;
		if ( HasAbility('Teleport' ) ) modOther = modOther + 5;
		if ( HasAbility('Thorns' ) ) modOther = modOther + 2;
		if ( HasAbility('Throw' ) ) modOther = modOther + 2;
		if ( HasAbility('ThrowFire' ) ) modOther = modOther + 2;
		if ( HasAbility('ThrowIce' ) ) modOther = modOther + 2;
		if ( HasAbility('Vampire' ) ) modOther = modOther + 2;
		if ( HasAbility('Venom' ) ) modOther = modOther + 2;
		if ( HasAbility('VitalityRegen' ) ) modOther = modOther + 5;
		if ( HasAbility('Wave' ) ) modOther = modOther + 2;
		if ( HasAbility('WeakToAard' ) ) modOther = modOther - 2;
		if ( HasAbility('TongueAttack' ) ) modOther = modOther + 2;
		
		exp = ( modDamage + modArmor + modVitality + modOther ) / 99;
		
		if( ( FactsQuerySum("NewGamePlus") > 0 ) ) currentLevel -= theGame.params.GetNewGamePlusLevel();
		
		if  ( IsHuman() ) 
		{
			if ( exp > 1 + ( currentLevel * 2 ) ) { exp = 1 + ( currentLevel * 2 ); }
		} else
		{
			if ( exp > 5 + ( currentLevel * 4 ) ) { exp = 5 + ( currentLevel * 4 ); } 
		}
				
		
		exp += 1;
		
		if( ( FactsQuerySum("NewGamePlus") > 0 ) )
		{
			if ( thePlayer.GetLevel() - theGame.params.GetNewGamePlusLevel() < 30 ) exp = ( exp / 4 ); else exp = ( exp / 2 );
		}
		else if ( thePlayer.GetLevel() < 30 ) exp = ( exp / 4 ); else exp = ( exp / 2 );
				
		
		
		if( ( FactsQuerySum("NewGamePlus") > 0 ) )
			lvlDiff = currentLevel - thePlayer.GetLevel() + theGame.params.GetNewGamePlusLevel();
		else
			lvlDiff = currentLevel - thePlayer.GetLevel();
		if 		( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) { exp = 25 + exp * 1.5; }	
		else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )  { exp = exp * 1.05; }
		else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )  { }
		else { exp = 2; }
		if ( exp > 50 ) exp = 50; 
		if ( theGame.GetDifficultyMode() == EDM_Easy ) exp = exp * 1.2; else
		if ( theGame.GetDifficultyMode() == EDM_Hard ) exp = exp * 0.9; else
		if ( theGame.GetDifficultyMode() == EDM_Hardcore ) exp = exp * 0.8;
		finalExp = RoundF( exp );
		
		if(!skipLog)
		{
			LogStats("--------------------------------");
			LogStats("-      [CALCULATED EXP]        -");
			LogStats("- base, without difficulty and -");
			LogStats("-   level difference bonuses   -");
			LogStats("--------------------------------");
			LogStats(" -> for entity : " + GetName());
			LogStats("--------------------------------");
			LogStats("* modDamage : " + modDamage);
			LogStats("* modArmor : " + modArmor);
			LogStats("* modVitality : " + modVitality);
			LogStats("+ modOther : " + modOther);
			LogStats("--------------------------------");
			LogStats(" BASE EXPERIENCE POINTS = [ " + finalExp + " ]");
			LogStats("--------------------------------");
		}
		
		return finalExp;
	}
	
	event OnDeath( damageAction : W3DamageAction  )
	{		
		var inWater, fists, tmpBool : bool;		
		var attackAction : W3Action_Attack;
		var expPoints, npcLevel, lvlDiff : int;
		var weaponID : SItemUniqueId;
		var actor : CActor;
		var abilityName, tmpName : name;
		var abilityCount, maxStack, itemExpBonus : float;
		var addAbility : bool;
		var min, max, bonusExp : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var monsterCategory : EMonsterCategory;
		var allItems : array<SItemUniqueId>;
		var attitudeToPlayer : EAIAttitude;
		var i : int;
		var ciriEntity  : W3ReplacerCiri;
		var blizzard : W3Potion_Blizzard;
		
		ciriEntity = (W3ReplacerCiri)thePlayer;		
		
		super.OnDeath( damageAction );
		
		if (!IsHuman() && damageAction.attacker == thePlayer && !ciriEntity ) AddBestiaryKnowledge();
		
		if ( !WillBeUnconscious() )
		{
			if ( theGame.GetWorld().GetWaterDepth( this.GetWorldPosition() ) > 0 )
			{
				if ( this.HasEffect( 'water_death' ) ) this.PlayEffectSingle( 'water_death' );
			}
			else
			{
				if ( this.HasEffect( 'blood_spill' ) ) this.PlayEffectSingle( 'blood_spill' );
			}
		}
		
		
		if ( ( ( CMovingPhysicalAgentComponent ) this.GetMovingAgentComponent() ).HasRagdoll() )
		{
			SetBehaviorVariable('HasRagdoll', 1 );
		}
		
		
		SignalGameplayEventParamObject( 'OnDeath', damageAction );
		theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'BattlecryGroupDeath', 1.0f, 20.0f, -1.0f, 1 );
		
		attackAction = (W3Action_Attack)damageAction;
		
		
		if ( ((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).GetSubmergeDepth() < 0 )
		{
			inWater = true;
			DisableAgony();
		}
		
		
		if( IsUsingHorse() )
		{
			SoundEvent( "cmb_play_hit_heavy" );
			SoundEvent( "grunt_vo_death" );
		}
						
		if(damageAction.attacker == thePlayer && ((W3PlayerWitcher)thePlayer) && thePlayer.GetStat(BCS_Toxicity) > 0 && thePlayer.CanUseSkill(S_Alchemy_s17))
		{
			thePlayer.AddAbility(SkillEnumToName(S_Alchemy_s17), true);
			if (thePlayer.GetSkillLevel(S_Alchemy_s17) > 1)
				thePlayer.AddAbility(SkillEnumToName(S_Alchemy_s17), true);
			if (thePlayer.GetSkillLevel(S_Alchemy_s17) > 2)
				thePlayer.AddAbility(SkillEnumToName(S_Alchemy_s17), true);
		}
		
		OnChangeDyingInteractionPriorityIfNeeded();
		
		actor = (CActor)damageAction.attacker;
		
		
		if(ShouldGiveExp(damageAction.attacker))
		{
			npcLevel = (int)CalculateAttributeValue(GetAttributeValue('level',,true));
			lvlDiff = npcLevel - GetWitcherPlayer().GetLevel();
			expPoints = CalculateExperiencePoints();
			
			
			if(expPoints > 0)
			{				
				theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
				if(MonsterCategoryIsMonster(monsterCategory))
				{
					bonusExp = thePlayer.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
				}
				else
				{
					bonusExp = thePlayer.GetAttributeValue('human_exp_bonus_when_fatal');
				}				
				
				expPoints = RoundMath( expPoints * (1 + CalculateAttributeValue(bonusExp)) );
				
				GetWitcherPlayer().AddPoints(EExperiencePoint, RoundF( expPoints * theGame.expGlobalMod_kills ), false );
			}			
		}
				
		
		attitudeToPlayer = GetAttitudeBetween(this, thePlayer);
		
		if(attitudeToPlayer == AIA_Hostile && !HasTag('AchievementKillDontCount'))
		{
			
			if(actor && actor.HasBuff(EET_AxiiGuardMe))
			{
				theGame.GetGamerProfile().IncStat(ES_CharmedNPCKills);
				FactsAdd("statistics_cerberus_sign");
			}
			
			
			if( aardedFlight && damageAction.GetBuffSourceName() == "FallingDamage" )
			{
				theGame.GetGamerProfile().IncStat(ES_AardFallKills);
			}
				
			
			if(damageAction.IsActionEnvironment())
			{
				theGame.GetGamerProfile().IncStat(ES_EnvironmentKills);
				FactsAdd("statistics_cerberus_environment");
			}
		}
		
		
		if ( damageAction.attacker == thePlayer )
		{
			theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
			
			
			if(thePlayer.HasBuff(EET_Mutagen18))
			{
				
				
				if(monsterCategory != MC_Animal || IsRequiredAttitudeBetween(this, thePlayer, true))
				{			
					abilityName = thePlayer.GetBuff(EET_Mutagen18).GetAbilityName();
					abilityCount = thePlayer.GetAbilityCount(abilityName);
					
					if(abilityCount == 0)
					{
						addAbility = true;
					}
					else
					{
						theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen18_max_stack', min, max);
						maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
						
						if(maxStack >= 0)
						{
							addAbility = (abilityCount < maxStack);
						}
						else
						{
							addAbility = true;
						}
					}
					
					if(addAbility)
					{
						thePlayer.AddAbility(abilityName, true);
					}
				}
			}
			
			
			if (thePlayer.HasBuff(EET_Mutagen06))
			{
				
				if(monsterCategory != MC_Animal || IsRequiredAttitudeBetween(this, thePlayer, true))
				{	
					mutagen = thePlayer.GetBuff(EET_Mutagen06);
					thePlayer.AddAbility(mutagen.GetAbilityName(), true);
				}
			}
			
			
			if(IsRequiredAttitudeBetween(this, thePlayer, true))
			{
				blizzard = (W3Potion_Blizzard)thePlayer.GetBuff(EET_Blizzard);
				if(blizzard)
					blizzard.KilledEnemy();
			}
			
			if(!HasTag('AchievementKillDontCount'))
			{
				if (damageAction.GetIsHeadShot() && monsterCategory == MC_Human )		
					theGame.GetGamerProfile().IncStat(ES_HeadShotKills);
					
				
				if( (W3SignEntity)damageAction.causer || (W3SignProjectile)damageAction.causer)
				{
					FactsAdd("statistics_cerberus_sign");
				}
				else if( (CBaseGameplayEffect)damageAction.causer && ((CBaseGameplayEffect)damageAction.causer).IsSignEffect())
				{
					FactsAdd("statistics_cerberus_sign");
				}
				else if( (W3Petard)damageAction.causer )
				{
					FactsAdd("statistics_cerberus_petard");
				}
				else if( (W3BoltProjectile)damageAction.causer )
				{
					FactsAdd("statistics_cerberus_bolt");
				}				
				else
				{
					if(!attackAction)
						attackAction = (W3Action_Attack)damageAction;
						
					fists = false;
					if(attackAction)
					{
						weaponID = attackAction.GetWeaponId();
						if(damageAction.attacker.GetInventory().IsItemFists(weaponID))
						{
							FactsAdd("statistics_cerberus_fists");
							fists = true;
						}						
					}
					
					if(!fists && damageAction.IsActionMelee())
					{
						FactsAdd("statistics_cerberus_melee");
					}
				}
			}
		}
		
		
		if( damageAction.attacker == thePlayer || !((CNewNPC)damageAction.attacker) )
		{
			theTelemetry.LogWithLabelAndValue(TE_FIGHT_ENEMY_DIES, this.ToString(), GetLevel());
		}
		
		
		if(damageAction.attacker == thePlayer && !HasTag('AchievementKillDontCount'))
		{
			if ( attitudeToPlayer == AIA_Hostile )
			{
				
				if(!HasTag('AchievementSwankDontCount'))
				{
					if(FactsQuerySum("statistic_killed_in_10_sec") >= 4)
						theGame.GetGamerProfile().AddAchievement(EA_Swank);
					else
						FactsAdd("statistic_killed_in_10_sec", 1, 10);
				}
				
				
				if(GetWitcherPlayer() && !thePlayer.ReceivedDamageInCombat() && !GetWitcherPlayer().UsedQuenInCombat())
				{
					theGame.GetGamerProfile().IncStat(ES_FinesseKills);
				}
			}
			
			
			if((W3PlayerWitcher)thePlayer)
			{
				if(!thePlayer.DidFailFundamentalsFirstAchievementCondition() && HasTag(theGame.params.MONSTER_HUNT_ACTOR_TAG) && !HasTag('failedFundamentalsAchievement'))
				{
					theGame.GetGamerProfile().IncStat(ES_FundamentalsFirstKills);
				}
			}
		}
					
		
		if(!inWater && RandF() < 0.3 && !WillBeUnconscious() && (W3IgniProjectile)damageAction.causer)
		{
			AddEffectDefault(EET_Burning, this, 'IgniKill', true);
			EnableAgony();
			SignalGameplayEvent('ForceAgony');			
		}
		
		
		if(attackAction && IsWeaponHeld('fist') && damageAction.attacker == thePlayer && !thePlayer.ReceivedDamageInCombat() && !HasTag('AchievementKillDontCount'))
		{
			weaponID = attackAction.GetWeaponId();
			if(thePlayer.inv.IsItemFists(weaponID))
				theGame.GetGamerProfile().AddAchievement(EA_FistOfTheSouthStar);
		}
	}
	
	event OnChangeDyingInteractionPriorityIfNeeded()
	{
		if ( WillBeUnconscious() )
			return true;
		if ( HasTag('animal') )
		{
			return true;
		}
			
		
		this.SetInteractionPriority(IP_Max_Unpushable);
	}
	
	event OnFireHit(source : CGameplayEntity)
	{	
		super.OnFireHit(source);
		
		if ( HasTag('animal') )
		{
			Kill();
		}
		
		if ( !IsAlive() && IsInAgony() )
		{
			
			SignalGameplayEvent('AbandonAgony');
			
			SetKinematic(false);
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		SignalGameplayEvent( 'AardHitReceived' );
		
		aardedFlight = true;
		
		RemoveAllBuffsOfType(EET_Frozen);
		
		
		
		
		super.OnAardHit(sign);
		
		if ( HasTag('small_animal') )
		{
			Kill();
		}
		if ( IsShielded(sign.GetCaster()) )
		{
			ToggleEffectOnShield('aard_cone_hit', true);
		}
		else if ( HasAbility('ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable( 'bIgnoreSigns',1.f );
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
		
		if ( !IsAlive() )
		{
			
			SignalGameplayEvent('AbandonAgony');
			
			
			
			if( !HasAbility( 'mon_bear_base' )
				&& !HasAbility( 'mon_golem_base' )
				&& !HasAbility( 'mon_endriaga_base' )
				&& !HasAbility( 'mon_gryphon_base' )
				&& !IsAnimal()	)
			{			
				
				SetKinematic(false);
			}
		}
	}
	
	event OnAxiiHit( sign : W3AxiiProjectile )
	{
		super.OnAxiiHit(sign);
		
		if ( HasAbility('ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable( 'bIgnoreSigns',1.f );
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
	}
	
	private const var SHIELD_BURN_TIMER : float;
	default SHIELD_BURN_TIMER = 1.0;
	
	private var beingHitByIgni : bool;
	private var firstIgniTick, lastIgniTick : float;
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		var horseComponent : W3HorseComponent;
		super.OnIgniHit( sign );
		
		SignalGameplayEvent( 'IgniHitReceived' );
		
		if ( HasAbility( 'ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable('bIgnoreSigns',1.f);
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
		
		if ( HasAbility( 'IceArmor') )
		{
			this.RemoveAbility( 'IceArmor' );
			this.StopEffect( 'ice_armor' );
			this.PlayEffect( 'ice_armor_hit' );
		}
		
		if( IsShielded( sign.GetCaster() ) )
		{
			if( sign.IsProjectileFromChannelMode() )
			{
				SignalGameplayEvent( 'BeingHitByIgni' );
				
				if( !beingHitByIgni )
				{
					beingHitByIgni = true;
					firstIgniTick = theGame.GetEngineTimeAsSeconds();
					ToggleEffectOnShield( 'burn', true );
					RaiseShield();
				}
				
				if( firstIgniTick + SHIELD_BURN_TIMER < theGame.GetEngineTimeAsSeconds() )
				{
					ProcessShieldDestruction();
					return false;
				}

				AddTimer( 'IgniCleanup', 0.2, false );
			}
			else
			{
				ToggleEffectOnShield( 'igni_cone_hit', true );
			}
		}
		
		horseComponent = GetHorseComponent();
		if ( horseComponent )
			horseComponent.OnIgniHit(sign);
		else
		{
			horseComponent = GetUsedHorseComponent();
			if ( horseComponent )
				horseComponent.OnIgniHit(sign);
		}
	}
	
	public function IsBeingHitByIgni() : bool
	{
		return beingHitByIgni;
	}
	
	function ToggleEffectOnShield(effectName : name, toggle : bool)
	{
		var itemID : SItemUniqueId;
		var inv : CInventoryComponent;
		
		inv = GetInventory();
		itemID = inv.GetItemFromSlot('l_weapon');
		if ( toggle )
			inv.PlayItemEffect(itemID,effectName);
		else
			inv.StopItemEffect(itemID,effectName);
	}
	
	timer function IgniCleanup( dt : float , id : int)
	{
		if( beingHitByIgni )
		{
			ToggleEffectOnShield( 'burn', false );
			AddTimer( 'LowerShield', 0.5 );
			beingHitByIgni = false;
		}
	}
	
	timer function IgnoreSignsTimeOut( dt : float , id : int)
	{
		this.SignalGameplayEvent( 'IgnoreSignsEnd' );
		this.SetBehaviorVariable( 'bIgnoreSigns',0.f);
	}
	
		
	
	function SetIsTeleporting( b : bool )
	{
		isTeleporting = b;
		
	}
	
	function IsTeleporting() : bool
	{
		return isTeleporting;
	}

	function SetUnstoppable( toggle : bool )
	{
		unstoppable = toggle;
	}
	
	function IsUnstoppable() : bool
	{
		return unstoppable;
	}
	
	function SetIsCountering( toggle : bool )
	{
		bIsCountering = toggle;
	}
	
	function IsCountering() : bool
	{
		return bIsCountering;
	}
	
	
	timer function Tick(deltaTime : float, id : int)
	{
		
		
	}
	
	private function UpdateBumpCollision()
	{
		var npc				: CNewNPC;
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		
		
		
		
		
		if( mac )
		{
			
			collisionNum	= mac.GetCollisionCharacterDataCount();
			for( i = 0; i < collisionNum; i += 1 )
			{
				collisionData	= mac.GetCollisionCharacterData( i );
				npc	= ( CNewNPC ) collisionData.entity;
				if( npc ) 
				{
					this.SignalGameplayEvent( 'AI_GetOutOfTheWay' ); 					
					this.SignalGameplayEventParamObject( 'CollideWithPlayer', npc );	
					theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'BumpAction', 1, 1, 1, 1, false );
					
					
					break;
				}
			}
		}
	}


	public function SetIsTranslationScaled(b : bool)						{isTranslationScaled = b;}
	public function GetIsTranslationScaled() : bool						{return isTranslationScaled;}	
	
	
	import final function GetActiveActionPoint() : SActionPointId;


	
	
	

	
	
	
	import final function IsInInterior() : bool;	
	
	
	import final function IsInDanger() : bool;
	
	
	import final function IsSeeingNonFriendlyNPC() : bool;

	
	import final function IsAIEnabled() : bool;
	
	
	import final function FindActionPoint( out apID : SActionPointId, out category : name );
			
	
	import final function GetDefaultDespawnPoint( out spawnPoint : Vector ) : bool;
	

	
	import final function NoticeActor( actor : CActor );
	
	
	import final function ForgetActor( actor : CActor );
	
	
	import final function ForgetAllActors();
	
	
	import final function GetNoticedObject( index : int) : CActor;
	
	

	import final function GetPerceptionRange() : float;
		
	
	
	import final function PlayDialog( optional forceSpawnedActors : bool ) : bool;
 
	
	
	
	import final function GetReactionScript( index : int ) : CReactionScript;
	
	import final function IfCanSeePlayer() : bool;
	
	import final function GetGuardArea() : CAreaComponent;
	import final function SetGuardArea( areaComponent : CAreaComponent );
	
	import final function IsConsciousAtWork() : bool;
	import final function GetCurrentJTType() : int;
	import final function IsInLeaveAction() : bool;
	import final function IsSittingAtWork() : bool;
	import final function IsAtWork() : bool;
	import final function IsPlayingChatScene() : bool;
	import final function CanUseChatInCurrentAP() : bool;
	
	
	import final function NoticeActorInGuardArea( actor : CActor );
	
	
	
	
	event OnAnimEvent_EquipItemL( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		GetInventory().MountItem( itemToEquip, true );
	}
	event OnAnimEvent_HideItemL( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		GetInventory().UnmountItem( itemToEquip, true );
	}
	event OnAnimEvent_HideWeapons( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var inventory 	: CInventoryComponent = GetInventory();
		var ids 		: array<SItemUniqueId>;
		var i 			: int;
		
		ids = inventory.GetAllWeapons();
		for( i = 0; i < ids.Size() ; i += 1 )
		{
			if( inventory.IsItemHeld( ids[i] ) || inventory.IsItemMounted( ids[i] ) )
				inventory.UnmountItem( ids[i], true );
		}
	}
	
	event OnAnimEvent_TemporaryOffGround( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd )
		{
			isTemporaryOffGround = false;
		}
		else
		{
			isTemporaryOffGround = true;
		}
	}
	event OnAnimEvent_weaponSoundType( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		WeaponSoundType().SetupDrawHolsterSounds();
	}
	
	
	event OnAnimEvent_OwlSwitchOpen( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('owl_01');
	}
	
	event OnAnimEvent_OwlSwitchClose( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('owl_02');
	}
	
	event OnAnimEvent_Goose01OpenWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_01_wings');
	}
	
	event OnAnimEvent_Goose01CloseWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_01');
	}
	
	event OnAnimEvent_Goose02OpenWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_02_wings');
	}
	
	event OnAnimEvent_Goose02CloseWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_02');
	}

	event OnAnimEvent_NullifyBurning( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		RemoveAllBuffsOfType(EET_Burning);
	}

	event OnAnimEvent_setVisible( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetVisibility( true );
		SetGameplayVisibility( true );
	}
	
	event OnAnimEvent_extensionWalk( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'UsesExtension', 1 );
	}
	
	
	
	event OnEquippedItem( category : name, slotName : name )
	{
		if ( slotName == 'r_weapon' )
		{
			switch( category )
			{			
				case 'axe1h':
				case 'axe2h':
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Axe );
					break;		
				case 'halberd2h':
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Halberd );
					break;
				case 'steelsword' :
				case 'silversword' :
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Sword );
					break;
				case 'crossbow' :
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Crossbow );
					break;
				default:
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_None );
					break;
			}
		}
		else if ( slotName == 'l_weapon' )
		{
			switch( category )
			{
				case 'shield' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Shield );
					break;
				case 'bow' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Bow );
					break;
				case 'usable' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Torch );
					break;
				default:
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_None );
					break;
			}
		}
		
		if ( category != 'fist' && category != 'work' && category != 'usable' && IsInCombat() && GetTarget() == thePlayer && thePlayer.GetTarget() == this )
			thePlayer.OnTargetWeaponDrawn();
	}
	
	event OnHolsteredItem( category : name, slotName : name )
	{
		if ( slotName == 'r_weapon' )
		{
			SetBehaviorVariable( 'EquippedItemR', (int) RIT_None );
		}
		else if ( slotName == 'l_weapon' )
		{
			SetBehaviorVariable( 'EquippedItemL', (int) LIT_None );
		}
	}
	
	function IsTalkDisabled () : bool
	{
		return isTalkDisabled || isTalkDisabledTemporary;
	}
	
	public function DisableTalking( disable : bool, optional temporary : bool )
	{		
		if ( temporary )
		{
			isTalkDisabledTemporary = disable;
		}
		else
		{
			isTalkDisabled = disable;
		}
	}

	public function CanStartTalk() : bool
	{
		
		if( IsAtWork() && !IsConsciousAtWork() || IsTalkDisabled () )
			return false;
			
		if(HasBuff(EET_AxiiGuardMe) || HasBuff(EET_Confusion))
			return false;
			
		return !IsFrozen() && CanTalk( true );
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var horseComponent		: W3HorseComponent;
		var ciriEntity  		: W3ReplacerCiri;
		var isAtWork			: bool;
		var isConciousAtWork 	: bool;
		
		LogChannel( 'DialogueTest', "Event Interaction Used" );
		if ( actionName == "Talk" )
		{	
			LogChannel( 'DialogueTest', "Activating TALK Interaction - PLAY DIALOGUE" );
			
			if ( !PlayDialog() )
			{
				
				
				EnableDynamicLookAt( thePlayer, 5 );
				ciriEntity = (W3ReplacerCiri)thePlayer;
				if ( ciriEntity )
				{
				}
				else
				{
					
					if( !IsAtWork() || IsConsciousAtWork() )
					{
						PlayVoiceset(100, "greeting_geralt" );
					}
					else
						PlayVoiceset(100, "sleeping" );
					
					wasInTalkInteraction = true;
					AddTimer( 'ResetTalkInteractionFlag', 1.0, true, , , true);
				}
			}
		}
		if ( actionName == "Finish" )
		{
			
		}
		else if( actionName == "AxiiCalmHorse" )
		{
			SignalGameplayEvent( 'HorseAxiiCalmDownStart' );
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		var stateName : name;
		var horseComp : W3HorseComponent;
		
		if( interactionComponentName == "talk" )
		{
			if( activator == thePlayer && thePlayer.CanStartTalk() && CanStartTalk() )
			{	
				return true;
			}
		}
		else if( interactionComponentName == "Finish" && activator == thePlayer )
		{
			stateName = thePlayer.GetCurrentStateName();
			if( stateName == 'CombatSteel' || stateName == 'CombatSilver' )
				return true;
		}
		else if( interactionComponentName == "horseMount" && activator == thePlayer )
		{
			if( !thePlayer.IsActionAllowed( EIAB_MountVehicle ) || thePlayer.IsInAir() )
				return false;
			if ( horseComponent.IsInHorseAction() || !IsAlive() )
				return false;
			if ( GetAttitudeBetween(this,thePlayer) == AIA_Hostile && !( HasBuff(EET_Confusion) || HasBuff(EET_AxiiGuardMe) ) )
				return false;
			
			if( mac.IsOnNavigableSpace() )
			{
				if( theGame.GetWorld().NavigationLineTest( activator.GetWorldPosition(), this.GetWorldPosition(), 0.05, false, true ) ) 
				{
					
					if( theGame.TestNoCreaturesOnLine( activator.GetWorldPosition(), this.GetWorldPosition(), 0.4, (CActor)activator, this, true ) ) 
					{
						return true;
					}
					
					return false;
				}
			}
			else
			{
				horseComp = this.GetHorseComponent();
				
				if( horseComp )
				{
					horseComp.mountTestPlayerPos = activator.GetWorldPosition();
					horseComp.mountTestPlayerPos.Z += 0.5;
					horseComp.mountTestHorsePos = this.GetWorldPosition();
					horseComp.mountTestHorsePos.Z += 0.5;
					
					if( !theGame.GetWorld().StaticTrace( horseComp.mountTestPlayerPos, horseComp.mountTestHorsePos, horseComp.mountTestEndPos, horseComp.mountTestNormal, horseComp.mountTestCollisionGroups ) )
					{
						return true;
					}
				}
				
				return false;
			}
		}
		
		
		
		return false;	
	}
	
	event OnInteractionTalkTest()
	{
		return CanStartTalk();		
	}

	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		
		
		
		
		
		
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		
		
		
		
	}

	
	
	
	
	
		
		
		
	
	
	event OnBehaviorGraphNotification( notificationName : name, stateName : name )
	{
		var i: int;		
		for ( i = 0; i < behaviorGraphEventListened.Size(); i += 1 )
		{
			if( behaviorGraphEventListened[i] == notificationName )
			{
				SignalGameplayEventParamCName( notificationName, stateName );
			}
		}
		super.OnBehaviorGraphNotification( notificationName, stateName );
	}
	
	public function ActivateSignalBehaviorGraphNotification( notificationName : name )
	{
		if( !behaviorGraphEventListened.Contains( notificationName ) )
		{
			behaviorGraphEventListened.PushBack( notificationName );
		}
	}
	
	public function DeactivateSignalBehaviorGraphNotification( notificationName : name )
	{
		behaviorGraphEventListened.Remove( notificationName );
	}
	
	
	
	
	
	function IsShielded( target : CNode ) : bool
	{
		var targetToSourceAngle	: float;
		var protectionAngleLeft, protectionAngleRight : float;
		
		if( target )
		{
			if( HasShieldedAbility() && IsGuarded() )
			{
				targetToSourceAngle = NodeToNodeAngleDistance(target, this);
				protectionAngleLeft = CalculateAttributeValue( this.GetAttributeValue( 'protection_angle_left' ) );
				protectionAngleRight = CalculateAttributeValue( this.GetAttributeValue( 'protection_angle_right' ) );
				
				
				if( targetToSourceAngle < protectionAngleRight && targetToSourceAngle > protectionAngleLeft )
				{
					return true;
				}
			}
			return false;
		}
		else
			return HasShieldedAbility() && IsGuarded();
	}
	
	function HasShieldedAbility() : bool
	{
		var attval : float;
		attval = CalculateAttributeValue( this.GetAttributeValue( 'shielded' ) );
		if( attval >= 1.f )
			return true;
		else
			return false;
	}
	
	function RaiseShield()
	{
		SetBehaviorVariable( 'bShieldUp', 1.f );
	}
	
	timer function LowerShield( td : float , id : int)
	{
		SetBehaviorVariable( 'bShieldUp', 0.f );
	}
		
	public function ProcessShieldDestruction()
	{	
		var shield : CEntity;
		
		if( HasTag( 'imlerith' ) )
			return;
			
		SetBehaviorVariable( 'bShieldbreak', 1.0 );
		AddEffectDefault( EET_Stagger, thePlayer, "ParryStagger" );
		shield = GetInventory().GetItemEntityUnsafe( GetInventory().GetItemFromSlot( 'l_weapon' ) );
		ToggleEffectOnShield( 'heavy_block', true );
		DropItemFromSlot( 'l_weapon', true );
	}

	event OnIncomingProjectile( isBomb : bool ) 
	{
		if( IsShielded( thePlayer ) )
		{
			RaiseShield();
			AddTimer( 'LowerShield', 3.0 );
		}
	}
	
	function ShouldAttackImmidiately() : bool
	{
		return  tauntedToAttackTimeStamp > 0 && ( tauntedToAttackTimeStamp + 10 > theGame.GetEngineTimeAsSeconds() );
	}
	
	function CanAttackKnockeddownTarget() : bool
	{
		var attval : float;
		attval = CalculateAttributeValue(this.GetAttributeValue('attackKnockeddownTarget'));
		if ( attval >= 1.f )
			return true;
		else
			return false;
	}
	
	event OnProcessRequiredItemsFinish()
	{
		var inv : CInventoryComponent = this.GetInventory();
		var heldItems, heldItemsNames, mountedItems : array<name>;
		
		if ( thePlayer.GetTarget() == this )
			thePlayer.OnTargetWeaponDrawn();
		
		
		SetBehaviorVariable( 'bIsGuarded', (int)IsGuarded() );
		
		inv.GetAllHeldAndMountedItemsCategories(heldItems, mountedItems);
				
		
		if ( this.HasShieldedAbility() )
		{
			RaiseGuard();
		}
		
		inv.GetAllHeldItemsNames( heldItemsNames );
		
		if ( heldItemsNames.Contains('fists_lightning') || heldItemsNames.Contains('fists_fire') )
		{
			this.PlayEffect('hand_fx');
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'FireDanger', -1, 5.0f, 1, -1, true, true );
		}
		else
		{
			this.StopEffect('hand_fx');
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'FireDanger' );
		}
		
		if ( mountedItems.Contains('shield') )
		{
			this.AddAbility('CannotBeAttackedFromBehind', false);
			LowerGuard();
		}
		else
		{
			this.RemoveAbility('CannotBeAttackedFromBehind');
		}
	}
	
	public function ProcessSpearDestruction() : bool 
	{
		var appearanceName : name;
		var shouldDrop : bool;
		var spear : CEntity;
		
		appearanceName = 'broken';
		spear = GetInventory().GetItemEntityUnsafe( GetInventory().GetItemFromSlot( 'r_weapon' ) );
		spear.ApplyAppearance( appearanceName );
		DropItemFromSlot('r_weapon', true);
		return true;
		
	}	
	
	
	
	
	
	function PlayVitalSpotAmbientSound( soundEvent : string )
	{
		SoundEvent( soundEvent, 'pelvis' );
	}
	
	function StopVitalSpotAmbientSound( soundEvent : string)
	{
		SoundEvent( soundEvent, 'pelvis' );
	}
	
	event OnScriptReloaded()
	{
		
	}
		

	
	
	
	
	
	public function ChangeFightStage( fightStage : ENPCFightStage )
	{
		currentFightStage =  fightStage;
		SetCurrentFightStage();
	}
	
	public function SetCurrentFightStage()
	{
		SetBehaviorVariable( 'npcFightStage', (float)(int)currentFightStage, true );
	}
	
	public function GetCurrentFightStage() : ENPCFightStage
	{
		return currentFightStage;
	}
	
	
	public function SetBleedBurnPoison()
	{
		wasBleedingBurningPoisoned = true;
	}
	
	public function WasBurnedBleedingPoisoned() : bool
	{
		return wasBleedingBurningPoisoned;
	}
	
	
	public function HasAlternateQuen() : bool
	{
		var npcStorage : CHumanAICombatStorage;
		
		npcStorage = (CHumanAICombatStorage)GetAIStorageObject('CombatData');
		if(npcStorage && npcStorage.IsProtectedByQuen() )
		{
			return true;
		}		
		
		return false;
	}
	
	
	public function GetIsMonsterTypeGroup() : bool	{ return isMonsterType_Group; }

	
	
	
	function UpdateAIVisualDebug()
	{	
	}

	
	event OnAllowBehGraphChange()
	{
		allowBehGraphChange = true;
	}
	
	event OnDisallowBehGraphChange()
	{
		allowBehGraphChange = false;
	}

	event OnObstacleCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		
		if ( (CActor)ent != this )
		{
			
			this.SignalGameplayEventParamObject('CollisionWithObstacle',ent);
		}
	}
	
	event OnActorCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithActor', ent );
			
			
			if( horseComponent )
			{
				horseComponent.OnCharacterCollision( ent );
			}
		}
	}
	
	event OnActorSideCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var horseComp : W3HorseComponent;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithActor', ent );
			
			
			if( horseComponent )
			{
				horseComponent.OnCharacterSideCollision( ent );
			}
		}
	}
	
	event OnStaticCollision( component : CComponent )
	{
		SignalGameplayEventParamObject('CollisionWithStatic',component);
	}
	
	event OnBoatCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithBoat', ent );
		}
	}
	
	
	
	
	
	public function IsUnderwater() : bool { return isUnderwater; }
	public function ToggleIsUnderwater ( toggle : bool ) { isUnderwater = toggle; }
	
	event OnOceanTriggerEnter()
	{
		SignalGameplayEvent('EnterWater');
	}
	
	event OnOceanTriggerLeave()
	{
		SignalGameplayEvent('LeaveWater');
	}
	
	
	
	
		
	var isRagdollOn : bool; default isRagdollOn = false;
	
	event OnInAirStarted()
	{		
		
	}
	
	event OnRagdollOnGround()
	{		
		var params : SCustomEffectParams;
		
		if( GetIsFallingFromHorse() )
		{
			params.effectType = EET_Ragdoll;
			params.creator = this;
			params.sourceName = "ragdoll_dismount";
			params.duration = 0.5;
			AddEffectCustom( params );
			SignalGameplayEvent( 'RagdollFromHorse' ); 
			SetIsFallingFromHorse( false );
		}
		else if( IsInAir() )
		{
			SetIsInAir(false);
		}
	}
	
	var m_storedInteractionPri : EInteractionPriority;
	default	m_storedInteractionPri = IP_NotSet;
	
	event OnRagdollStart()
	{
		var currentPri : EInteractionPriority;
	
		
		currentPri = GetInteractionPriority();
		if ( currentPri != IP_Max_Unpushable && IsAlive() )
		{
			m_storedInteractionPri = currentPri;
			SetInteractionPriority( IP_Max_Unpushable );
		}
	}
	
	event OnNoLongerInRagdoll()
	{
		aardedFlight = false;
		
		
		if ( m_storedInteractionPri != IP_NotSet && IsAlive() )
		{
			SetInteractionPriority( m_storedInteractionPri );
			m_storedInteractionPri = IP_NotSet;
		}
	}
	
	timer function DelayRagdollSwitch( td : float , id : int)
	{
		var params : SCustomEffectParams;
	
		if( IsInAir() )
		{
			isRagdollOn = true;
			params.effectType = EET_Ragdoll;
			params.duration = 5;
			
			AddEffectCustom(params);
		}
	}

	event OnRagdollIsAwayFromCapsule( ragdollPosition : Vector, entityPosition : Vector )
	{
	}
	
	event OnRagdollCloseToCapsule( ragdollPosition : Vector, entityPosition : Vector )
	{
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		var witcher : W3PlayerWitcher;
		
		super.OnTakeDamage(action);
		
		
		if(action.IsActionMelee() && action.DealsAnyDamage())
		{
			witcher = (W3PlayerWitcher)action.attacker;
			if(witcher && witcher.HasBuff(EET_Mutagen10))
			{
				abilityName = thePlayer.GetBuff(EET_Mutagen10).GetAbilityName();
				abilityCount = thePlayer.GetAbilityCount(abilityName);
				
				if(abilityCount == 0)
				{
					addAbility = true;
				}
				else
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen10_max_stack', min, max);
					maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					
					if(maxStack >= 0)
					{
						addAbility = (abilityCount < maxStack);
					}
					else
					{
						addAbility = true;
					}
				}
				
				if(addAbility)
				{
					thePlayer.AddAbility(abilityName, true);
				}
			}
		}
		
		if(action.IsActionMelee())
			lastMeleeHitTime = theGame.GetEngineTime();
	}
	
	public function GetInteractionData( out actionName : name, out text : string ) : bool
	{
		if ( CanStartTalk() && !IsInCombat() )
		{
			actionName	= 'Talk';
			text		= "panel_button_common_talk";
			return true;
		}
		return false;
	}
	
	public function IsAtWorkDependentOnFireSource() : bool
	{
		if ( IsAPValid(GetActiveActionPoint()) )
		{
			return theGame.GetAPManager().IsFireSourceDependent( GetActiveActionPoint() );
		}
		
		return false;
	}
	
	public function FinishQuen(skipVisuals : bool)
	{
		SignalGameplayEvent('FinishQuen');
	}

	public function IsAxiied() : Bool
	{
		return HasBuff( EET_AxiiGuardMe ) || HasBuff( EET_Confusion );
	}
}

exec function IsFireSource( tag : name )
{
	var npc : CNewNPC;

	npc = ( CNewNPC )theGame.GetEntityByTag( tag );	
	
	LogChannel('SD', "" + npc.IsAtWorkDependentOnFireSource() );
}	

