/*
Copyright © CD Projekt RED 2015
*/



class W3BehTreeValNameArray extends IScriptable
{
	editable var nameArray : array<name>;
	
	public function GetArray() : array<name>
	{
		return nameArray;
	}
}