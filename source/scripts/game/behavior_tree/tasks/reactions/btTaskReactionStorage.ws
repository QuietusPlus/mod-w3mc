/*
Copyright © CD Projekt RED 2015
*/

class CBTTaskReactionStorage extends IBehTreeTask
{
	protected var storageHandler 		: CAIStorageHandler;
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	public var onActivate 		: bool;
	public var onDeactivate 	: bool;
	public var onCompletion 	: bool;
	public var setIsAlarmed 	: bool;
	public var setTaunted 		: bool;
	public var reset 			: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			DoStuff();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			DoStuff();
		}
	}
	function OnCompletion( success : bool )
	{
		if ( onDeactivate )
		{
			DoStuff();
		}
	}
	
	function DoStuff()
	{
		if (setIsAlarmed) 	reactionDataStorage.SetAlarmed( GetLocalTime() );
		if (setTaunted) 	reactionDataStorage.IncreaseTauntCounter( GetLocalTime(), GetNPC() );
		if (reset) 			reactionDataStorage.Reset();
	}
	
	function Initialize()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
	
}

class CBTTaskReactionStorageDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskReactionStorage';

	editable var onActivate 	: bool;
	editable var onDeactivate 	: bool;
	editable var onCompletion 	: bool;
	
	editable var setIsAlarmed 	: bool;
	editable var setTaunted		: bool;
	editable var reset			: bool;
}



class CBehTreeTaskReactionStorageCleanup extends IBehTreeTask
{
	protected var storageHandler 		: CAIStorageHandler;
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		reactionDataStorage.Reset();
		reactionDataStorage.ResetAttitudes(GetActor());
	}

	function Initialize()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
}

class CBehTreeTaskReactionStorageCleanupDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBehTreeTaskReactionStorageCleanup';
}