/*
Copyright © CD Projekt RED 2015
*/





class CR4ListBaseMenu extends CR4MenuBase
{	
	protected const var DATA_BINDING_NAME				:string; 		default DATA_BINDING_NAME 			= "alchemy.list";
	protected const var DATA_BINDING_NAME_SUBLIST		:string; 		default DATA_BINDING_NAME_SUBLIST	= "glossary.bestiary.sublist.items";
	protected const var DATA_BINDING_NAME_DESCRIPTION	:string; 		default DATA_BINDING_NAME_DESCRIPTION	= "glossary.bestiary.description";
	protected const var ITEMS_SIZE						:int; 			default ITEMS_SIZE 		= 4; 
	
	protected var m_journalManager		: CWitcherJournalManager;	
	var currentTag						: name;
	var lastSentTag						: name;
	var openedTabs 						: array<name>;

	var itemsNames 						: array< name >;
	
	event  OnConfigUI() 
	{	
		super.OnConfigUI();
		
		
		openedTabs = UISavedData.openedCategories;
		m_journalManager = theGame.GetJournalManager();
	}

	event  OnClosingMenu() 
	{
		SaveStateData();
		super.OnClosingMenu();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( GetMenuName() );
	}

	event  OnCloseMenu() 
	{
		var commonMenu : CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if(commonMenu)
		{
			commonMenu.ChildRequestCloseMenu();
		}
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
	}
	
	function SaveStateData()
	{
		m_guiManager.UpdateUISavedData( GetMenuName(), UISavedData.openedCategories, currentTag, UISavedData.selectedModule );
	}	

	event OnCategoryOpened( categoryName : name, opened : bool )
	{
		var i : int;
		if( categoryName == 'None' )
		{
			return false;
		}
		if( opened )
		{
			if( UISavedData.openedCategories.FindFirst(categoryName) == -1 )
			{
				UISavedData.openedCategories.PushBack(categoryName);
			}
		}
		else
		{
			i = UISavedData.openedCategories.FindFirst(categoryName);
			if( i > -1 )
			{
				UISavedData.openedCategories.Erase(i);
			}
		}
	}

	event OnEntryRead( tag : name ) 
	{
		var journalEntry : CJournalBase;
		journalEntry = m_journalManager.GetEntryByTag( tag );
		m_journalManager.SetEntryUnread( journalEntry, false );
	}

	event OnEntrySelected( tag : name ) 
	{
		var journalEntry : CJournalBase;
		var journalQuestObj : CJournalQuestObjective;
		
		currentTag = tag;
		
		journalEntry = m_journalManager.GetEntryByTag( tag );
		if ( journalEntry )
		{
			journalQuestObj = (CJournalQuestObjective)journalEntry;
			if (lastSentTag != tag && !journalQuestObj) 
			{
				lastSentTag = tag;
				UpdateDescription(tag);
				UpdateImage(tag);
				UpdateItems(tag);
			}
			
			theGame.NotifyOpeningJournalEntry( journalEntry );
		}
		else if (lastSentTag != tag)
		{
			lastSentTag = tag;
			UpdateDescription(tag);
			UpdateImage(tag);
			UpdateItems(tag);
		}
	}
	
	event OnEntryPress( tag : name ) 
	{
	}
	
	protected function HandleMenuLoaded():void
	{
		super.HandleMenuLoaded();
		OnEntrySelected(currentTag);
	}

	function PopulateData() 
	{
	}

	function CreateItems( itemsNames : array< name > ) : CScriptedFlashArray
	{
		var l_flashArray				: CScriptedFlashArray;
		var l_flashObject				: CScriptedFlashObject;
		var i 							: int;
		
		if( itemsNames.Size() < 1 )
		{
			m_flashValueStorage.SetFlashBool(DATA_BINDING_NAME_SUBLIST+".visible",false);
			return NULL;
		}
		m_flashValueStorage.SetFlashBool(DATA_BINDING_NAME_SUBLIST+".visible",true);
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
			
		for( i = 0; i < itemsNames.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			FillItemInformation(l_flashObject, i);
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		return l_flashArray;
	}
	
	public function FillItemInformation(flashObject : CScriptedFlashObject, index:int) : void
	{
		var itemName : name = itemsNames[index];
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();		
		
		flashObject.SetMemberFlashInt( "id", index + 1 ); 
		flashObject.SetMemberFlashInt( "quantity",  GetItemQuantity(index));
		flashObject.SetMemberFlashString( "iconPath",  dm.GetItemIconPath( itemName ) );
		flashObject.SetMemberFlashInt( "gridPosition", index );
		flashObject.SetMemberFlashInt( "gridSize", 1 );
		flashObject.SetMemberFlashInt( "slotType", 1 );	
		flashObject.SetMemberFlashBool( "isNew", false );
		flashObject.SetMemberFlashBool( "needRepair", false );
		flashObject.SetMemberFlashInt( "actionType", IAT_None );
		flashObject.SetMemberFlashInt( "price", 0 ); 		
		flashObject.SetMemberFlashString( "userData", "");
		flashObject.SetMemberFlashString( "category", "" );
	}
	
	function GetItemQuantity(id : int ) : int
	{
		var itemName : name = itemsNames[id];
		var playerInv : CInventoryComponent = thePlayer.GetInventory();
		return playerInv.GetItemQuantityByName(itemName);
	}
	
	event OnGetItemData(item : int, compareItemType : int) 
	{
		
		
		var itemName 			: string;
		var category			: name;
		var typeStr				: string;
		var weight 				: float;
		
		var resultData 			: CScriptedFlashObject;
		var statsList			: CScriptedFlashArray;		
		var dm 					: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		item = item - 1;
		
		resultData = m_flashValueStorage.CreateTempFlashObject();
		statsList = m_flashValueStorage.CreateTempFlashArray();
		
		itemName = dm.GetItemLocalisationKeyName( itemsNames[item]);
		itemName = GetLocStringByKeyExt(itemName);
		resultData.SetMemberFlashString("ItemName", itemName);
		
		
		
		
		
		resultData.SetMemberFlashString("PriceValue", dm.GetItemPrice(itemsNames[item]));
				
		category = dm.GetItemCategory(itemsNames[item]);
		
		if( dm.ItemHasTag(itemsNames[item], 'Quest') 
			|| dm.ItemHasTag(itemsNames[item], 'AlchemyIngredient') 
			|| dm.ItemHasTag(itemsNames[item], 'CraftingIngredient') 
			|| dm.ItemHasTag(itemsNames[item], 'Potion') 
			|| dm.ItemHasTag(itemsNames[item], 'SilverOil') 
			|| dm.ItemHasTag(itemsNames[item], 'SteelOil') 
			|| category == 'petard' 
			|| category == 'bolt' )
		{
			weight = 0;
		}
		else
		{
			weight = 1; 
		}
		
		resultData.SetMemberFlashString("WeightValue", NoTrailZeros(weight));
		resultData.SetMemberFlashString("ItemRarity", "" );
		
		typeStr = GetItemCategoryLocalisedString( category );
		resultData.SetMemberFlashString("ItemType", typeStr );
		
		resultData.SetMemberFlashString("DurabilityValue", "");

		resultData.SetMemberFlashString("IconPath", dm.GetItemIconPath(itemsNames[item]) );
		resultData.SetMemberFlashString("ItemCategory", category);
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	function UpdateDescription( entryName : name ) 
	{	
	}		

	function UpdateImage( entryName : name ) 
	{	
	}		

	function UpdateItems( tag : name )
	{	
	}	
}
