/*
Copyright © CD Projekt RED 2015
*/

class W3SE_ManageGate extends W3SwitchEvent
{
	editable var entityTag : name;
	editable var open : bool;
	editable var speedModifier : float;
	
	default open = true;
	default speedModifier = 1.0;
	
	public function Perform( parnt : CEntity )
	{	
		var entities : array<CEntity>;
		var i : int;
		var gate : CGateEntity;

		theGame.GetEntitiesByTag( entityTag, entities );
			
		if ( entities.Size() == 0 )
		{
			LogAssert( false, "No entities found with tag <" + entityTag + ">" );
			return;
		}
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			gate = (CGateEntity)entities[i];
			
			if( gate )
			{
				if( open )
					gate.OpenGate(speedModifier);
				else
					gate.CloseGate(speedModifier);
			}
		}
	}
}