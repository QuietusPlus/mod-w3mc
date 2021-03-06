/*
Copyright © CD Projekt RED 2015
*/

class W3GuiSocketsInventoryComponent extends W3GuiPlayerInventoryComponent
{
	public var merchantInv			 : CInventoryComponent;
	protected var m_upgradeItem      : SItemUniqueId;
	protected var m_useSocketsFilter : bool;
	
	
	public function SetUpgradableFilter(item : SItemUniqueId) :void
	{
		m_upgradeItem = item;
	}
	
	
	public function SetSocketsFilter(value:bool):void
	{
		m_useSocketsFilter = value;
	}

	protected  function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var upgradeFilter : bool;
		var socketFilter  : bool;
		
		if (_inv.IsIdValid(m_upgradeItem))
		{
			upgradeFilter = CanBeUpgradedBy(item, m_upgradeItem);
		}
		else
		{
			upgradeFilter = true;
		}
		
		if (m_useSocketsFilter)
		{
			socketFilter = HasFilledSockets(item);
		}
		else
		{
			socketFilter = true;
		}
		
		return upgradeFilter && socketFilter;
	}
	
	public  function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var invItem : SInventoryItem;
		
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		invItem = _inv.GetItem( item );
		addSocketsListInfo( item, flashObject );
		flashObject.SetMemberFlashBool( "enableComparison", _inv.CanBeCompared(item) );
		flashObject.SetMemberFlashInt("actionPrice", merchantInv.GetItemPriceRemoveUpgrade( invItem ));
		flashObject.SetMemberFlashInt( "gridPosition", -1 );
	}
	
	private function addSocketsListInfo(item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var idx				  : int;
		var socketsCount	  : int;
		var usedSocketsCount  : int;
		var socketItems		  : array<name>;
		var socketList		  : CScriptedFlashArray;
		var socketData 		  : CScriptedFlashObject;
		
		_inv.GetItemEnhancementItems(item, socketItems);
		socketsCount = _inv.GetItemEnhancementSlotsCount( item );
		usedSocketsCount = _inv.GetItemEnhancementCount( item );
		socketList = flashObject.CreateFlashArray();
		
		for (idx = 0; idx < usedSocketsCount; idx+=1)
		{
			socketData = flashObject.CreateFlashObject();
			socketData.SetMemberFlashString("name", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(socketItems[idx])));
			socketData.SetMemberFlashString("iconPath", _inv.GetItemIconPathByName(socketItems[idx]));
			socketList.PushBackFlashObject(socketData);
		}
		flashObject.SetMemberFlashArray("socketsData", socketList);
		flashObject.SetMemberFlashInt("socketsCount", socketsCount);
	}
	
	private function HasFilledSockets(targetItem:SItemUniqueId):bool
	{
		var usedSocketsCount : int;
		usedSocketsCount = _inv.GetItemEnhancementCount( targetItem );
		return usedSocketsCount > 0;
	}
}