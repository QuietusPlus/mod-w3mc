/*
Copyright © CD Projekt RED 2015
*/





class CR4PreparationPotionsAndBombsMenu extends CR4MenuBase 
{
	private var _gridInv : W3GuiPreparationPotionsAndBombsInventoryComponent;
	private var _currentInv : W3GuiBaseInventoryComponent;
	protected var _inv : CInventoryComponent;
	private var optionsItemActions : array<EInventoryActionType>;
	
	private var _currentQuickSlot : EEquipmentSlots;
	default _currentQuickSlot = EES_InvalidSlot;	
	
	
	private const var ITEMS_SIZE			:int; 			default ITEMS_SIZE 		= 4;

	event  OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		super.OnConfigUI();
		
		
		_inv = thePlayer.GetInventory();
		_gridInv = new W3GuiPreparationPotionsAndBombsInventoryComponent in this;
		_gridInv.Initialize( _inv );	
		_currentInv = _gridInv;
		
		UpdateData();
		m_flashValueStorage.SetFlashString("common.grid.name",GetLocStringByKeyExt("panel_preparation_potionsandbombs_grid_name"),-1);

		m_flashValueStorage.SetFlashString( "preparation.potionsandbombs.sublist.name", GetLocStringByKeyExt("panel_preparation_potionsandbombs_slots_description"), -1 );
		UpdatePlayerOrens();
		UpdatePlayerLevel();
		
		UpdateNavigationTitles();
	}
	
	function UpdateData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		_gridInv.GetInventoryFlashArray(l_flashArray,l_flashObject);
		
		m_flashValueStorage.SetFlashArray( "common.grid", l_flashArray );
		UpdatePotions();
		UpdateBombs();
	}	

	function UpdateBombs()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var rewardItems				: array<SItemUniqueId>;
		var item 					: SItemUniqueId;
		var i 						: int;
		var _inv					: CInventoryComponent;
		
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		_inv = GetWitcherPlayer().GetInventory();
				
		for(i = EES_Petard1; i < EES_Petard2 + 1; i += 1 )
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(i, item);
			rewardItems.PushBack(item);
		}
		
		for( i = 0; i < ITEMS_SIZE; i += 1 )
		{
			item = rewardItems[i];
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			l_flashObject.SetMemberFlashInt( "id", ItemToFlashUInt(item) );
			if(_inv.IsItemSingletonItem(item))
			{
				l_flashObject.SetMemberFlashInt( "quantity", thePlayer.inv.SingletonItemGetAmmo(item) );
			}
			else
			{
				l_flashObject.SetMemberFlashInt( "quantity", _inv.GetItemQuantity( item ) );
			}
			l_flashObject.SetMemberFlashString( "iconPath",  _inv.GetItemIconPathByUniqueID(item) );
			l_flashObject.SetMemberFlashInt( "gridPosition", i );
			l_flashObject.SetMemberFlashInt( "gridSize", 1 );
			l_flashObject.SetMemberFlashInt( "slotType", 1 );	
			l_flashObject.SetMemberFlashBool( "isNew", false );
			l_flashObject.SetMemberFlashBool( "needRepair", false );
			l_flashObject.SetMemberFlashInt( "actionType", IAT_None );
			l_flashObject.SetMemberFlashInt( "price", 0 ); 		
			l_flashObject.SetMemberFlashString( "userData", "");
			l_flashObject.SetMemberFlashString( "category", "" );
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
				
		m_flashValueStorage.SetFlashArray( "preparation.bombs.equipped.items", l_flashArray ); 
	}

	function UpdatePotions()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var rewardItems				: array<SItemUniqueId>;
		var item 					: SItemUniqueId;
		var i 						: int;
		var _inv					: CInventoryComponent;
		
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		_inv = GetWitcherPlayer().GetInventory();
				
		for(i = EES_Potion1; i < EES_Potion2 + 1; i += 1 ) 
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(i, item);
			rewardItems.PushBack(item);
		}
		
		for( i = 0; i < ITEMS_SIZE; i += 1 )
		{
			item = rewardItems[i];
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			l_flashObject.SetMemberFlashInt( "id", ItemToFlashUInt(item) );
			if(_inv.IsItemSingletonItem(item))
			{
				l_flashObject.SetMemberFlashInt( "quantity", thePlayer.inv.SingletonItemGetAmmo(item) );
			}
			else
			{
				l_flashObject.SetMemberFlashInt( "quantity", _inv.GetItemQuantity( item ) );
			}
			l_flashObject.SetMemberFlashString( "iconPath",  _inv.GetItemIconPathByUniqueID(item) );
			l_flashObject.SetMemberFlashInt( "gridPosition", i );
			l_flashObject.SetMemberFlashInt( "gridSize", 1 );
			l_flashObject.SetMemberFlashInt( "slotType", 1 );	
			l_flashObject.SetMemberFlashBool( "isNew", false );
			l_flashObject.SetMemberFlashBool( "needRepair", false );
			l_flashObject.SetMemberFlashInt( "actionType", IAT_None );
			l_flashObject.SetMemberFlashInt( "price", 0 ); 		
			l_flashObject.SetMemberFlashString( "userData", "");
			l_flashObject.SetMemberFlashString( "category", "" );
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		m_flashValueStorage.SetFlashArray( "preparation.potions.equipped.items", l_flashArray ); 
	}
	
	private function UpdatePlayerOrens()
	{
		var orens:int;
		orens = thePlayer.GetMoney();
		
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.money",orens,-1);
	}

	private function UpdatePlayerLevel()
	{
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.level",GetCurrentLevel(),-1);
		m_flashValueStorage.SetFlashString("inventory.playerdetails.experience",GetCurrentExperience(),-1);
	}
	
	private function GetCurrentLevel() : int
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetLevel();
	}	

	private function GetCurrentExperience() : string
	{
		var levelManager : W3LevelManager;
		var str : string;
		levelManager = GetWitcherPlayer().levelManager;
		
		str = (string)levelManager.GetPointsTotal(EExperiencePoint) + "/" +(string)levelManager.GetTotalExpForNextLevel(); 
		return str;
	}
	
	function UpdateTooltipCompareData( item : SItemUniqueId, compareItem : SItemUniqueId, tooltipInv : CInventoryComponent , tooltipName : string ) 
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		var compareItemStats : array<SAttributeTooltip>;
		var itemStats : array<SAttributeTooltip>;
		var i,j, price : int;
		var nam, descript, fluff, category : string;
		var itemName : string;
		var attributeVal : SAbilityAttributeValue;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		if( tooltipInv.IsIdValid( item ) )
		{
			itemName = tooltipInv.GetItemLocalizedNameByUniqueID(item);
			itemName = GetLocStringByKeyExt(itemName);
			m_flashValueStorage.SetFlashString(tooltipName+".title", itemName, -1 );
		}
		else
		{
			m_flashValueStorage.SetFlashString(tooltipName+".title", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".price", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".weight", "", -1 );
			m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
			m_flashValueStorage.SetFlashString(tooltipName+".description", "", -1 );
			if( theGame.IsPadConnected() )
			{
				m_flashValueStorage.SetFlashString(tooltipName+".icon", "", -1 );
				m_flashValueStorage.SetFlashString(tooltipName+".category", "", -1 );
			}
			return;
		}
		
		if( tooltipInv.GetItemName(item) != _inv.GetItemName(compareItem) ) 
		{
			_inv.GetTooltipData(compareItem, nam, descript, price, category, compareItemStats, fluff );
		}
		tooltipInv.GetTooltipData(item, nam, descript, price, category, itemStats, fluff);
		
		
		itemName = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);

			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				itemName = "positive";
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					if( itemStats[j].value < compareItemStats[i].value )
					{
						itemName = "negative";
					}
					else if( itemStats[j].value == compareItemStats[i].value )
					{
						itemName = "neutral";
					}	
					break;
				}
			}
			l_flashObject.SetMemberFlashString("icon",itemName);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				l_flashObject.SetMemberFlashString("value","+"+(int)NoTrailZeros(itemStats[i].value));
			}
			l_flashArray.PushBackFlashObject(l_flashObject);
		}	
		
		m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
		m_flashValueStorage.SetFlashString(tooltipName+".price", tooltipInv.GetItemPrice(item), -1 );
							
		attributeVal = _inv.GetItemAttributeValue( item , 'weight');			
		m_flashValueStorage.SetFlashString(tooltipName+".weight", attributeVal.valueAdditive, -1  );
		m_flashValueStorage.SetFlashString(tooltipName+".description", GetLocStringByKeyExt("panel_inventory_tooltip_description_selected"), -1 ); 
		m_flashValueStorage.SetFlashBool(tooltipName+".display", true, -1 );
		if( theGame.IsPadConnected() )
		{
			m_flashValueStorage.SetFlashString(tooltipName+".icon", tooltipInv.GetItemIconPathByUniqueID(item), -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".category", tooltipInv.GetItemCategory( item ), -1 );
		}
	}
		
	function UpdateNavigationTitles() 
	{
		m_flashValueStorage.SetFlashString("inventory.navigation.title", GetLocStringByKeyExt("panel_title_preapration"), -1 );
		m_flashValueStorage.SetFlashString("inventory.navigation.previous", "", -1 );
		m_flashValueStorage.SetFlashString("inventory.navigation.next", "", -1 );
		
	}
	
	function GetItemDefaultAction( item : SItemUniqueId ) : string
	{
		
		return "[[panel_button_inventory_equip]]";
	}
	
	event  OnCloseMenu()
	{
		
		var parentMenu : CR4MenuBase;
		CloseMenu();
		parentMenu =  (CR4MenuBase)GetMenuInitData();
		parentMenu.OnCloseMenu();
		parentMenu.CloseMenu();
	}
	
	
	
	event  OnEquipItem( item : SItemUniqueId, slot : int, quantity : int )
	{
		var i : int;
		var itemOnSlot : SItemUniqueId;

		if(  slot == EES_Quickslot1 )
		{
			
			for(i = EES_Quickslot1; i < EES_Quickslot2 + 1; i += 1 )
			{
				GetWitcherPlayer().GetItemEquippedOnSlot(i, itemOnSlot);
						
				if( !_inv.IsIdValid(itemOnSlot) )
				{
					slot = i;
					_currentQuickSlot = slot;
					break;
				}
			}
		}	
		if( slot == EES_Potion1 )
		{
			
			for(i = EES_Potion1; i < EES_Potion2 + 1; i += 1 )
			{
				GetWitcherPlayer().GetItemEquippedOnSlot(i, itemOnSlot);
						
				if( !_inv.IsIdValid(itemOnSlot) )
				{
					slot = i;
							
					GetWitcherPlayer().EquipItemInGivenSlot(item, slot, false);		
					break;
				}
			}
		}

		if( slot == EES_Petard1 )
		{
			
			for(i = EES_Petard1; i < EES_Petard2 + 1; i += 1 )
			{
				GetWitcherPlayer().GetItemEquippedOnSlot(i, itemOnSlot);
						
				if( !_inv.IsIdValid(itemOnSlot) )
				{
					slot = i;
					
					break;
				}
			}
		}
		
		_gridInv.EquipItem( item, slot );
		UpdateData(); 
	}
		

	

	event  OnUpdateTooltipCompareData( item : SItemUniqueId, compareItemType : int, tooltipName : string )
	{
		var itemName : string;
		var compareItem : SItemUniqueId;

		itemName = _inv.GetItemName(item);
		
		UpdateTooltipCompareData(item,compareItem,_inv,tooltipName);
	}	
}
