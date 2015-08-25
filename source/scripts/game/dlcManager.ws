/*
Copyright © CD Projekt RED 2015
*/





import class CDLCManager extends CObject
{
	import final function GetDLCs(names : array<name>) : void;
	import final function EnableDLC(id : name, isEnabled : bool) : void;
	import final function IsDLCEnabled(id : name) : bool;
	import final function IsDLCAvailable(id : name) : bool;
	import final function GetDLCName(id : name) : string;
	import final function GetDLCDescription(id : name) : string;
	import final function SimulateDLCsAvailable(shouldSimulate : bool) : void;
	
	public function IsNewGamePlusAvailable():bool
	{
		return IsDLCAvailable('dlc_009_001') && hasSaveDataToLoad();
	}
	
	public function IsAnyDLCAvailable():bool
	{
		var dlcList : array<name>;
		var i:int;
		
		GetDLCs(dlcList);
		
		for (i = 0; i < dlcList.Size(); i += 1)
		{
			if (IsDLCAvailable(dlcList[i]))
			{
				return true;
			}
		}
		
		return false;
	}
}