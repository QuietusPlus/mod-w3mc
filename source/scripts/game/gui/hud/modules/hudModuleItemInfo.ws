/*
Copyright © CD Projekt RED 2015
*/


enum HudItemInfoBinding
{
	HudItemInfoBinding_item1 = 0,
	HudItemInfoBinding_potion1 = 1,
	HudItemInfoBinding_potion2 = 2
};

class CR4HudModuleItemInfo extends CR4HudModuleBase
{
	private var m_currentItemSelected 	: SItemUniqueId;
	private var m_currentItemOnSlot1 	: SItemUniqueId;
	private var m_currentItemOnSlot2 	: SItemUniqueId;
	
	private var m_lastBoltItem : SItemUniqueId;

	private var m_currentItemSelectedAmmo	: int;
	private var m_currentItemOnSlot1Ammo	: int;
	private var m_currentItemOnSlot2Ammo	: int;

	private var m_fxEnableSFF : CScriptedFlashFunction;
	private var m_fxUpdateElementSFF : CScriptedFlashFunction;
	private var m_fxHideSlotsSFF : CScriptedFlashFunction;
	private var m_fxSetAlwaysDisplayed : CScriptedFlashFunction;
	private var m_flashValueStorage : CScriptedFlashValueStorage;
	private var m_fxSetItemInfo : CScriptedFlashFunction;
	private var m_IsPlayerCiri					: bool;
	default m_IsPlayerCiri = false;
	
	private var cached_item0, cached_item1, cached_item2 : SItemUniqueId;
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;

		m_anchorName = "mcAnchorItemInfo";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();

		flashModule 			= GetModuleFlash();	
		m_fxEnableSFF			= flashModule.GetMemberFlashFunction( "EnableElement" );
		m_fxUpdateElementSFF	= flashModule.GetMemberFlashFunction( "UpdateElement" );
		m_fxHideSlotsSFF		= flashModule.GetMemberFlashFunction( "HideSlots" );
		m_fxSetAlwaysDisplayed	= flashModule.GetMemberFlashFunction( "setAlwaysDisplayed" );
		m_fxSetItemInfo 		= flashModule.GetMemberFlashFunction( "setItemInfo" );

		ClearItems();
		
		SetTickInterval( 0.25 );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('ItemInfoModule', true);
		}
	}
	
	event OnTick( timeDelta : float )
	{
		var item0, item1, item2 : SItemUniqueId;
		
		if ( !CanTick( timeDelta ) )
		{
			return true;
		}
		
		if( m_IsPlayerCiri != thePlayer.IsCiri() )
		{
			m_IsPlayerCiri = thePlayer.IsCiri();
			if( m_IsPlayerCiri )
			{
				ClearItems();
			}
			m_fxHideSlotsSFF.InvokeSelfOneArg(FlashArgBool(!m_IsPlayerCiri));
		}
		
		if( m_IsPlayerCiri )
		{
			item0 = GetCiriItem();
			UpdateItem( item0, m_currentItemSelected, m_currentItemSelectedAmmo, HudItemInfoBinding_item1, 0 );
		}
		else
		{
			item0 = GetWitcherPlayer().GetSelectedItemId();
			GetWitcherPlayer().GetItemEquippedOnSlot( EES_Potion1, item1 );
			GetWitcherPlayer().GetItemEquippedOnSlot( EES_Potion2, item2 );
			
			
			
			
			
				UpdateItem( item0, m_currentItemSelected, m_currentItemSelectedAmmo, HudItemInfoBinding_item1, 0 );
				cached_item0 = item0;
			
			
			
			
				UpdateItem( item1, m_currentItemOnSlot1,  m_currentItemOnSlot1Ammo, HudItemInfoBinding_potion1, 1 );
			
			
			
			
				UpdateItem( item2, m_currentItemOnSlot2,  m_currentItemOnSlot2Ammo, HudItemInfoBinding_potion2, 2 );
				cached_item2 != item2;
			
		}
		
		
		if ( thePlayer.IsCombatMusicEnabled() || thePlayer.GetHealthPercents() < 1.f )
			SetAlwaysDisplayed( true );
		else
			SetAlwaysDisplayed( false );
	}
	
	function GetCiriItem() : SItemUniqueId
	{
		var ret : array<SItemUniqueId>;
		
		ret = thePlayer.GetInventory().GetItemsByName('q403_ciri_meteor');
		
		return ret[0];
	}
	
	public function ResetItems()
	{
		var invalidGUID 	: SItemUniqueId;
		
		m_currentItemSelected = invalidGUID;
		m_currentItemOnSlot1 = invalidGUID;
		m_currentItemOnSlot2 = invalidGUID;
	}
	
	public function UpdateItem( out currItem : SItemUniqueId, out prevItem : SItemUniqueId, out prevItemAmmo : int, bindingID : HudItemInfoBinding, slotId : int )
	{
		var updateItem : bool;
		var ammo : int;
		var tempItem : SItemUniqueId;
		var dummy : SItemUniqueId;
		
		updateItem = false;
		ammo = 0;

		if ( prevItem != currItem )
		{
			updateItem = true;
			prevItem = currItem;
		}
		if ( thePlayer.GetInventory().IsIdValid( currItem ) )
		{
			if ( thePlayer.GetInventory().IsItemSingletonItem( currItem ) )
			{
				ammo = thePlayer.inv.SingletonItemGetAmmo( currItem );
				if ( prevItemAmmo != ammo )
				{
					updateItem = true;
					prevItemAmmo = ammo;
				}
			}
			else if( thePlayer.GetInventory().IsItemCrossbow( currItem ) )
			{				
				GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, tempItem);
				ammo = thePlayer.GetInventory().GetItemQuantity( tempItem );
				if ( prevItemAmmo != ammo )
				{
					updateItem = true;
					prevItemAmmo = ammo;
					
				}
				
				if (!updateItem && m_lastBoltItem != tempItem)
				{
					updateItem = true;
				}
				
				m_lastBoltItem = tempItem;
			}
			else if( thePlayer.GetInventory().ItemHasTag( currItem, 'Edibles' ) )
			{				
				ammo = thePlayer.GetInventory().GetItemQuantity( currItem );
				if ( prevItemAmmo != ammo )
				{
					updateItem = true;
					prevItemAmmo = ammo;
				}
			}
			else
			{
				prevItemAmmo = -1;
				if ( slotId == 1 ) UpdateItemData( dummy, HudItemInfoBinding_potion1 );
				if ( slotId == 2 ) UpdateItemData( dummy, HudItemInfoBinding_potion2 );				
			}
		}
		else
		{
			prevItemAmmo = -1;
			if ( slotId == 1 ) UpdateItemData( dummy, HudItemInfoBinding_potion1 );
			if ( slotId == 2 ) UpdateItemData( dummy, HudItemInfoBinding_potion2 );				
		}
		if ( updateItem )
		{
			UpdateItemData( currItem, bindingID );
		}
	}

	public function ClearItems()
	{
		var dummy : SItemUniqueId;
		
		UpdateItemData( dummy, HudItemInfoBinding_item1 );
		UpdateItemData( dummy, HudItemInfoBinding_potion1 );
		UpdateItemData( dummy, HudItemInfoBinding_potion2 );
		m_currentItemSelected = dummy;
		m_currentItemOnSlot1 = dummy;
		m_currentItemOnSlot2 = dummy;
	}
	
	public function UpdateItemData(item : SItemUniqueId, bindingID : HudItemInfoBinding)
	{
		var ammo : int;
		var ammoStr : string;
		var itemName : string;
		var fontColor : string;
		var icon : string;
		var category : string;
		var btn:int;
		var pcBtn : int;
		var inventory : CInventoryComponent;
		
		if( !thePlayer.GetInventory().IsIdValid( item ) )
		{
			icon = "";
			category = "";
			itemName = "";
			ammoStr = "";
			btn = 0;
			pcBtn = -1;
		}
		else
		{
			inventory = thePlayer.GetInventory();
			icon = inventory.GetItemIconPathByUniqueID(item);
			category = inventory.GetItemCategory(item);
			
			itemName = inventory.GetItemLocalizedNameByUniqueID(item);
			itemName = GetLocStringByKeyExt( itemName );
			fontColor = "<font color=\"#FFFFFF\">";
			
			if( inventory.ItemHasTag(item, 'Edibles' ) )
			{
				ammo = thePlayer.inv.GetItemQuantity(item);
				ammoStr = fontColor + ammo + "</font>";
			}
			else if( inventory.IsItemSingletonItem(item) )
			{
				ammo = thePlayer.inv.SingletonItemGetAmmo(item);
				if( ammo == 0 )
				{
					fontColor = "<font color=\"#FF0000\">";
				}
				ammoStr = fontColor+ammo+"/"+thePlayer.inv.SingletonItemGetMaxAmmo(item)+"</font>";
			}
			else
			{
				if( inventory.IsItemCrossbow(item) )
				{				
					GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, item);
					ammo = inventory.GetItemQuantity( item );
					
					if( inventory.ItemHasTag(item, theGame.params.TAG_INFINITE_AMMO) )
					{
						ammoStr = fontColor + "∞" + "</font>";
					}
					else
					{
						if( ammo == 0 )
						{
							fontColor = "<font color=\"#FF0000\">";
						}
						
						ammoStr = fontColor + ammo + "</font>";
					}
				}
				else
				{
					ammoStr = "";
				}
			}	
			
			itemName = fontColor+itemName+"</font>";
			
			if( theInput.GetContext() == 'RadialMenu' )
			{
				btn = GetKeyByBinding( bindingID );
				pcBtn = GetPCKeyByBinding( bindingID );
			}
			else
			{
				btn = 0;
				pcBtn = 0;
			}
		}
		
		
		m_fxSetItemInfo.InvokeSelfSevenArgs(FlashArgInt(bindingID), FlashArgString(icon), FlashArgString(category), FlashArgString(itemName), FlashArgString(ammoStr), FlashArgInt(btn), FlashArgInt(pcBtn));
	}
	
	private function GetKeyByBinding(bindingName : HudItemInfoBinding) : int
	{
		var outKeys : array< EInputKey >;
		switch(bindingName)
		{
			case HudItemInfoBinding_item1 :
				theInput.GetPadKeysForAction('ThrowItem',outKeys);
				
				break;
			case HudItemInfoBinding_potion1 :
				theInput.GetPadKeysForAction('DrinkPotion1',outKeys);
				
				break;
			case HudItemInfoBinding_potion2 :
				theInput.GetPadKeysForAction('DrinkPotion2',outKeys);
				
				break;
		}
		return outKeys[0];
	}
	
	private function GetPCKeyByBinding(bindingName : HudItemInfoBinding) : int
	{
		var outKeys : array< EInputKey >;
		switch(bindingName)
		{
			case HudItemInfoBinding_item1 :
				theInput.GetPCKeysForAction('ThrowItem',outKeys);
				
				break;
			case HudItemInfoBinding_potion1 :
				theInput.GetPCKeysForAction('DrinkPotion1',outKeys);
				
				break;
			case HudItemInfoBinding_potion2 :
				theInput.GetPCKeysForAction('DrinkPotion2',outKeys);
				
				break;
		}
		return outKeys[0];
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX + (300.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY - (200.0 * (1.0 - theGame.GetUIVerticalFrameScale())); 
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}
		
	public function ForceShowElement() : void
	{
		m_fxUpdateElementSFF.InvokeSelf();
	}	
	
	public function EnableElement( enable : bool ) : void
	{
		
	}	
	
	public function ShowElementIgnoreState( show : bool, optional bImmediately : bool ) : void
	{
		if( m_bEnabled )
		{
			m_fxShowElementSFF.InvokeSelfThreeArgs( FlashArgBool( show ), FlashArgBool( bImmediately ), FlashArgBool( true ) );
		}
	}	
	
	public function SetAlwaysDisplayed( value : bool )
	{
		m_fxSetAlwaysDisplayed.InvokeSelfOneArg(FlashArgBool(value));
	}
}

exec function eitem( enable : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleItemInfo;

	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		module = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
		module.EnableElement( enable );
	}
}