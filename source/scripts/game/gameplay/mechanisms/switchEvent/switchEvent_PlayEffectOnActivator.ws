/*
Copyright © CD Projekt RED 2015
*/






class W3SE_PlayEffectOnActivator extends W3SwitchEvent
{
	editable var effectName	: name;
	editable var play		: bool;		default play = true;
		
	hint effectName = "Effect name (defined in entity), use 'all' and play=no to stop all effects";
	hint play 		= "if set to true then plays effect, else stops it";
	
	public function PerformArgNode( parnt : CEntity, node : CNode )
	{
		var activator : CActor;
		
		LogChannel('Switch',"W3SE_PlayEffectOnActivator.Activate: called for actor <<"+activator.GetReadableName()+">>, effect <<"+effectName+">>, isPlay="+play);

		activator  = ( CActor )node;
		if ( !activator )
		{
			return;
		}
			
		if ( play )
		{
			activator.PlayEffect( effectName );
		}
		else
		{
			if ( effectName == 'all' )
			{
				activator.StopAllEffects();
			}
			else
			{
				activator.StopEffect( effectName );
			}
		}
	}
}