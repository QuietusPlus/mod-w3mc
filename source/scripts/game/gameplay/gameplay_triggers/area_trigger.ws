/*
Copyright © CD Projekt RED 2015
*/





class W3GameZoneTrigger extends CEntity
{
	var playerEntity 	: CPlayer;
	var zoneName		: name;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var tags 		: array< name >;
		var i 			: int;
		
		playerEntity = (CPlayer)activator.GetEntity();
		if( playerEntity )
		{
			tags = this.GetTags();
			if ( tags.Size() > 0 )
			{
				
				for ( i = 0; i < tags.Size(); i+=1 )
				{
					zoneName = tags[i];
					theGame.SetCurrentZone( zoneName );
					break;
				}
			}
			else
			{
				Log( "Zone Area tag is not set!" );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		zoneName = '';
	}
}