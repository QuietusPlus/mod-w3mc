/*
Copyright © CD Projekt RED 2015
*/





class CBTTaskHitReactionDecorator extends CBTTaskPlayAnimationEventDecorator
{
	public var createHitReactionEvent 	: name;
	public var increaseHitCounterOnlyOnMeleeDmg : bool;
	
	private var hitsToRaiseGuard 		: int;
	private var raiseGuardChance 		: int;
	
	private var hitsToCounter	 		: int;	
	private var counterChance	 		: int;
	private var counterStaminaCost		: float;
	
	private var damageData 				: CDamageData;
	private var damageIsMelee 			: bool;
	private var rotateNode 				: CNode;
	private var lastAttacker 			: CGameplayEntity;

	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return (GetActor().CanPlayHitAnim() && !GetNPC().IsUnstoppable() );
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		GetStats();
		
		npc.SetIsInHitAnim(true);
		
		InitializeReactionDataStorage();
		reactionDataStorage.ChangeAttitudeIfNeeded( npc, (CActor)lastAttacker );
		
		if (  CheckGuardOrCounter() )
		{
			npc.DisableHitAnimFor(0.1);
			npc.SetIsInHitAnim(false);
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetIsTranslationScaled( false );
		npc.SetIsInHitAnim(false);
	}
	
	function GetStats()
	{
		var raiseGuardMultiplier : int;
		var counterMultiplier : int;
		
		hitsToRaiseGuard = (int)CalculateAttributeValue(GetActor().GetAttributeValue('hits_to_raise_guard'));
		raiseGuardChance = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('raise_guard_chance')));
		raiseGuardMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('raise_guard_chance_mult_per_hit')));
		
		hitsToCounter = (int)CalculateAttributeValue(GetActor().GetAttributeValue('hits_to_roll_counter'));
		counterChance = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('counter_chance')));
		counterMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('counter_chance_per_hit')));
		
		counterStaminaCost = CalculateAttributeValue(GetNPC().GetAttributeValue( 'counter_stamina_cost' ));
		
		raiseGuardChance += Max( 0, GetNPC().GetHitCounter() - 1 ) * raiseGuardMultiplier;
		counterChance += Max( 0, GetNPC().GetHitCounter() - 1 ) * counterMultiplier;
		
		if ( hitsToRaiseGuard < 0 )
		{
			hitsToRaiseGuard = 65536;
		}
	}
	
	function CheckGuardOrCounter() : bool
	{
		var npc : CNewNPC = GetNPC();
		var hitCounter : int;
		
		hitCounter = npc.GetHitCounter();
		if ( hitCounter >= hitsToRaiseGuard && npc.CanGuard() )
		{
			GetStats();
			if( Roll( raiseGuardChance ) )
			{		
				if ( npc.RaiseGuard() )
				{
					npc.SignalGameplayEvent('HitReactionTaskCompleted');
					return true;
				}
			}
		}
		if ( !npc.IsHuman() && GetActor().GetMovingAgentComponent().GetName() != "wild_hunt_base" && hitCounter >= hitsToCounter  )
		{
			if( Roll( counterChance ) && npc.GetStat( BCS_Stamina ) >= counterStaminaCost )
			{
				npc.SignalGameplayEvent('LaunchCounterAttack');
				return true;
			}
		}
		
		return false;
	}
	
	function CheckDistanceToAttacker( attacker : CActor ) : bool
	{
		var dist : float;
		
		dist = VecDistanceSquared(GetActor().GetWorldPosition(), attacker.GetWorldPosition() );
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( eventName == 'BeingHit' )
		{			
			damageData 		= (CDamageData) GetEventParamBaseDamage();
			damageIsMelee 	= damageData.isActionMelee;
			
			lastAttacker = damageData.attacker;
			
			if ( !npc.IsInFistFightMiniGame() && (CActor)lastAttacker )
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( lastAttacker, 'CombatNearbyAction', 5.f, 10.f, 999.0f, -1, true); 
			
			rotateNode = GetRotateNode();
			
			if ( !increaseHitCounterOnlyOnMeleeDmg || (increaseHitCounterOnlyOnMeleeDmg && damageIsMelee) )
				npc.IncHitCounter();			
			
			
			if ( isActive && CheckGuardOrCounter() )
			{
				npc.DisableHitAnimFor(0.1);
				Complete(true);
				return false;
			}
			
			
			
			if ( damageData.hitReactionAnimRequested  )
				return true;
			else
				return false;
		}
		else if ( eventName == 'CriticalState' )
		{
			if ( isActive )
			{
				Complete(true);
			}
			else
				npc.DisableHitAnimFor(0.1);
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'RotateEventStart'  )
		{
			GetNPC().SetRotationAdjustmentRotateTo( rotateNode );
			return true;
		}
		else if ( eventName == 'RotateAwayEventStart' )
		{
			GetNPC().SetRotationAdjustmentRotateTo( rotateNode, 180.0 );
			return true;
		}
		else if ( eventName == 'WantsToPerformDodge' )
		{
			Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent(eventName);
	}
	
	function GetRotateNode() : CNode
	{
		
		if ( lastAttacker )
			return lastAttacker;
		
		return GetCombatTarget();
	}
	
	var cachedPos : Vector;
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner 			: CNewNPC;
		var player			: CR4Player;
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		
		player = thePlayer;
		
		
		return super.OnAnimEvent(animEventName,animEventType,animInfo);
	}
	
	function InitializeReactionDataStorage()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
}

class CBTTaskHitReactionDecoratorDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskHitReactionDecorator';

	editable var createHitReactionEvent : CBehTreeValCName;
	editable var increaseHitCounterOnlyOnMeleeDmg : CBehTreeValBool;
	
	default rotateOnRotateEvent 		= false;
	default disableHitOnActivation 		= false;
	default disableLookatOnActivation 	= true;
	
	public function Initialize()
	{
		SetValCName(createHitReactionEvent,'BeingHitAction');
		SetValBool(increaseHitCounterOnlyOnMeleeDmg,true);
		super.Initialize();
	}
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CriticalState' );
		listenToGameplayEvents.PushBack( 'BeingHit' );
	}
}



class CBTCondBeingHit extends IBehTreeTask
{	
	var timeOnLastHit 	: float;
	var beingHit 		: bool;
	
	default timeOnLastHit 	= 0.0;
	default beingHit		= false;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		if ( timeOnLastHit + 2.0 < GetLocalTime() )
		{
			beingHit = false;
		}
		if ( beingHit )
		{
			return true;
		}
		return false;
	}
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( eventName == 'BeingHit' )
		{
			beingHit 		= true;
			timeOnLastHit 	= GetLocalTime(); 
			return true;
		}
		return false;
	}
}

class CBTCondBeingHitDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondBeingHit';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
	}
}




class CBTCompleteOnHit extends IBehTreeTask
{	
	public var onlyIfCanPlayHitAnim : bool;
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( onlyIfCanPlayHitAnim && !npc.CanPlayHitAnim() )
			return false;
		
		if ( eventName == 'BeingHit' )
		{
			Complete(true);
			return true;
		}
		return false;
	}
}

class CBTCompleteOnHitDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCompleteOnHit';
	
	private editable var onlyIfCanPlayHitAnim : bool;
	
}




