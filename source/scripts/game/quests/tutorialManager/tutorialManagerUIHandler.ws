/*
Copyright © CD Projekt RED 2015
*/





state Tutorial_Idle in W3TutorialManagerUIHandler {}


statemachine class W3TutorialManagerUIHandler
{
	private saved var listeners : array<SUITutorial>;
	private var lastOpenedMenu : name;
	private var isMenuOpened : bool;
	private var postponedUnregisteredMenu : name;
	
	
	private function HandleListeners(menuName : name, isOpened : bool) : bool
	{
		var i, factVal, chosenIndex, minPriority : int;
		
		
		if(menuName == 'TutorialPopupMenu')
			return false;
			
		
		if(menuName == 'CommonMenu' && theGame.GameplayFactsQuerySum("shopMode") > 0)
			return false;
		
		if(isOpened)
			lastOpenedMenu = menuName;
			
		isMenuOpened = isOpened;
		minPriority = 1000000;
		chosenIndex = -1;
		for(i=0; i<listeners.Size(); i+=1)
		{
			if(listeners[i].menuName != menuName)
				continue;				
				
			if(listeners[i].triggerCondition == EUITTC_OnMenuOpen && !isOpened)
				continue;
				
			
			if(menuName == 'InventoryMenu' && theGame.GameplayFactsQuerySum("stashMode") > 0)
				continue;
				
			if(listeners[i].requiredGameplayFactName != "")
			{
				factVal = theGame.GameplayFactsQuerySum(listeners[i].requiredGameplayFactName);
				if(!ProcessCompare(listeners[i].requiredGameplayFactComparator, factVal, listeners[i].requiredGameplayFactValueInt))
					continue;
			}
			
			
			if(minPriority > listeners[i].priority)
			{
				minPriority = listeners[i].priority;
				chosenIndex = i;
			}
		}
		
		if(chosenIndex >= 0)
		{
			GotoState(listeners[chosenIndex].tutorialStateName);
			return true;
		}
		
		return false;
	}
		
	public function RegisterUIHint(data : SUITutorial)
	{
		listeners.PushBack(data);
	}
	
	
	public function UnregisterUIHint(tutorialStateName : name, optional sourceName : string) : bool
	{
		var i : int;
		var listenerMenu : name;
				
		for(i=0; i<listeners.Size(); i+=1)
		{
			if(listeners[i].tutorialStateName == tutorialStateName && (sourceName == "" || listeners[i].sourceName == sourceName) )
			{
				listenerMenu = listeners[i].menuName;
				
				listeners.EraseFast(i);
				
				
				if(tutorialStateName == 'Books' || tutorialStateName == 'RecipeReading')
				{
					postponedUnregisteredMenu = lastOpenedMenu;
					return false;
				}
				
				
				if(tutorialStateName == 'Crafting')
				{
					theGame.GameplayFactsAdd("tutorial_craft_finished");
				}
		
				
				if(lastOpenedMenu == listenerMenu && isMenuOpened)
				{
					return HandleListeners(lastOpenedMenu, true);
				}
				else
				{
					return false;
				}
			}
		}
		
		return false;
	}
	
	event OnOpeningMenu(menuName : name)
	{
		LogTutorial("UIHandler: OnOpeningMenu <<" + menuName + ">>");
	
		
		if(menuName == 'CommonMenu' || menuName == 'CommonIngameMenu')
			theGame.GetTutorialSystem().OnOpeningMenuHandleNonMenuTutorial();
				
		
		if(menuName == 'AlchemyMenu' && ShouldProcessTutorial('TutorialAlchemyCook'))
		{
			ProcessAlchemyTutorialFact();					
		}
		
		if(menuName == 'CraftingMenu' && ShouldProcessTutorial('TutorialCraftingSchematicsList'))
		{
			ProcessCraftingTutorialFact();					
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialRunesSelectRune'))
		{	
			ProcessRunesFact();
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialArmorSocketsSelectTab'))
		{	
			ArmorUpgradesTutorialCheck();
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialPotionCanEquip2'))
		{	
			ProcessPotionEquipFact();
		}		
		
		HandleListeners(menuName, true);
		
		
		OnMenuOpening(menuName);
	}
	
	private final function ProcessPotionEquipFact()
	{
		var witcher : W3PlayerWitcher;
		var isPot1, isPot2 : bool;
		var pot : SItemUniqueId;
		var n : name;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			isPot1 = false;
			isPot2 = false;
			if(witcher.GetItemEquippedOnSlot(EES_Potion1, pot))
			{
				isPot1 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			if(witcher.GetItemEquippedOnSlot(EES_Potion2, pot))
			{
				isPot2 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			
			if(!isPot1 && !isPot2)
				GameplayFactsAdd("tutorial_equip_potion");
		}		
	}
	
	private final function ProcessAlchemyTutorialFact()
	{
		var alchemyManager : W3AlchemyManager;
		var witcher : W3PlayerWitcher;
		var i : int;
		var recipes : array<name>;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			GameplayFactsRemove("tutorial_alch_has_ings");
			alchemyManager = new W3AlchemyManager in this;
			alchemyManager.Init();
			
			recipes = witcher.GetAlchemyRecipes();
			
			for(i=0; i<recipes.Size(); i+=1)
			{
				if(alchemyManager.CanCookRecipe(recipes[i]) == EAE_NoException)
				{
					GameplayFactsAdd("tutorial_alch_has_ings");
					break;
				}
			}
			
			delete alchemyManager;
		}	
	}
	
	private final function ProcessCraftingTutorialFact()
	{
		var craftingManager : W3CraftingManager;
		var i : int;
		var witcher : W3PlayerWitcher;
		var craftsmanComponent : W3CraftsmanComponent;
		var recipes : array<name>;
		var craftMenu : CR4CraftingMenu;
		var craftingError : ECraftingException;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			GameplayFactsRemove("tutorial_craft_has_ings");
			recipes = witcher.GetCraftingSchematicsNames();
			
			craftMenu = (CR4CraftingMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
			craftsmanComponent = craftMenu.GetCraftsmanComponent();

			if(!craftsmanComponent)
				return;
				
			craftingManager = new W3CraftingManager in this;
			craftingManager.Init(craftsmanComponent);
			
			for(i=0; i<recipes.Size(); i+=1)
			{
				craftingError = craftingManager.CanCraftSchematic(recipes[i], true);
				
				
				if(craftingError != ECE_WrongCraftsmanType)
				{
					GameplayFactsAdd("tutorial_craft_has_ings");
					break;
				}
			}
			
			delete craftingManager;
		}	
	}
	
	private final function ProcessRunesFact()
	{
		var i : int;
		var weapons : array<SItemUniqueId>;
		var item : SItemUniqueId;
		
		
		if(thePlayer.inv.GetItemQuantityByTag('WeaponUpgrade') > 0)
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
				weapons.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
				weapons.PushBack(item);
				
			for(i=0; i<weapons.Size(); i+=1)
			{
				
				if(thePlayer.inv.GetItemEnhancementSlotsCount(weapons[i]) > 0)
				{
					
					if(thePlayer.inv.GetItemEnhancementCount(weapons[i]) < thePlayer.inv.GetItemEnhancementSlotsCount(weapons[i]))
					{
						GameplayFactsAdd("tut_runes_start");
						return;
					}
				}
			}
		}
	}
	
	private final function ArmorUpgradesTutorialCheck()
	{
		var i : int;
		var items : array<SItemUniqueId>;
		var item : SItemUniqueId;
		
		
		if(thePlayer.inv.GetItemQuantityByTag('ArmorUpgrade') > 0)
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Armor, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Boots, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Pants, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Gloves, item))
				items.PushBack(item);
				
			for(i=0; i<items.Size(); i+=1)
			{
				
				if(thePlayer.inv.GetItemEnhancementSlotsCount(items[i]) > 0)
				{
					
					if(thePlayer.inv.GetItemEnhancementCount(items[i]) < thePlayer.inv.GetItemEnhancementSlotsCount(items[i]))
					{
						GameplayFactsAdd("tut_arm_upg_start");
						return;
					}
				}
			}
		}
	}
	
	event OnOpenedMenu(menuName : name)
	{
		LogTutorial("UIHandler: OnOpenedMenu <<" + menuName + ">>");
		
		
		OnMenuOpened(menuName);
	}
	
	event OnClosingMenu(menuName : name)
	{
		var stateName : name;
		var i : int;
		
		LogTutorial("UIHandler: OnClosingMenu <<" + menuName + ">>");
		
		
		if(menuName == 'PopupMenu' && IsNameValid(postponedUnregisteredMenu))
		{
			HandleListeners(postponedUnregisteredMenu, true);
			postponedUnregisteredMenu = '';
		}
		else
		{
			HandleListeners(menuName, false);
		}
		
		
		OnMenuClosing(menuName);
		
		
		
		stateName = GetCurrentStateName();
		if(IsNameValid(stateName))
		{
			for(i=0; i<listeners.Size(); i+=1)
			{
				if(listeners[i].tutorialStateName == stateName && listeners[i].abortOnMenuClose && (listeners[i].menuName == menuName || 'CommonMenu' == menuName))
				{
					GotoState('Tutorial_Idle');
					break;
				}
			}
		}
	}
	
	event OnClosedMenu(menuName : name)
	{
		LogTutorial("UIHandler: OnClosedMenu <<" + menuName + ">>");
		
		
		OnMenuClosed(menuName);
	}
	
	
	event OnMenuClosing(menuName : name) 	{}
	event OnMenuClosed(menuName : name) 	{}
	event OnMenuOpening(menuName : name) 	{}
	event OnMenuOpened(menuName : name) 	{}
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool) {}
	
	
	public final function LockLeaveMenu(locked:bool)
	{
		var guiManager : CR4GuiManager;
		var rootMenu : CR4CommonMenu;
			
		guiManager = theGame.GetGuiManager();
				
		if (guiManager && guiManager.IsAnyMenu())
		{
			rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
			
			if (rootMenu)
			{
				rootMenu.SetLockedInMenu(locked);
			}
		}
	}
	
	
	public final function LockCloseUIPanels(lock : bool)
	{
		var guiManager : CR4GuiManager;
		var rootMenu : CR4CommonMenu;
			
		guiManager = theGame.GetGuiManager();
				
		if (guiManager && guiManager.IsAnyMenu())
		{
			rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
			
			if (rootMenu)
			{
				rootMenu.SetLockedInHub(lock);
			}
		}
	}
}