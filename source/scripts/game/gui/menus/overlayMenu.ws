/*
Copyright © CD Projekt RED 2015
*/





class CR4OverlayMenu extends CR4MenuBase
{
	var m_BlurBackground : bool;
	var m_PauseGame		 : bool;

	event  OnConfigUI()
	{
		super.OnConfigUI();
		
		if (m_BlurBackground)
		{
			BlurBackground(this, true);
		}
	}
	
	event  OnCloseMenu()
	{
		RequestClose();
	}
	
	event  OnClosingMenu()
	{
		if (m_BlurBackground)
		{
			BlurBackground(this, false);
		}
		super.OnClosingMenu();
	}
	
	public function RequestClose():void
	{
		CloseMenu();
	}
	
	protected function BlurBackground(firstLayer : CR4MenuBase, value : bool) : void
	{
		if (firstLayer.m_parentMenu)
		{
			BlurBackground(firstLayer.m_parentMenu, value);
			firstLayer.m_parentMenu.BlurLayer(value);
		}
	}

}