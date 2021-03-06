/*
Copyright © CD Projekt RED 2015
*/

class CR4HudModuleSubtitles extends CR4HudModuleBase
{
	private var m_fxAddSubtitleSFF		: CScriptedFlashFunction;
	private var m_fxRemoveSubtitleSFF	: CScriptedFlashFunction;
	private var m_fxUpdateWidthSFF		: CScriptedFlashFunction;

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var configValue : string;
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		m_anchorName = "ScaleOnly";
		
		flashModule = GetModuleFlash();	
		m_fxAddSubtitleSFF		= flashModule.GetMemberFlashFunction( "addSubtitle" );
		m_fxRemoveSubtitleSFF	= flashModule.GetMemberFlashFunction( "removeSubtitle" );
		m_fxUpdateWidthSFF		= flashModule.GetMemberFlashFunction( "updateWidth" );
		
		super.OnConfigUI();
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		configValue = inGameConfigWrapper.GetVarValue('Localization', 'Subtitles');
		SetEnabled(configValue == "true");
	}

	event  OnSubtitleAdded( id : int, speakerNameDisplayText : string, htmlString : string )
	{
		if( theGame.isDialogDisplayDisabled )
		{
			speakerNameDisplayText = "";
			htmlString = "";
		}
		m_fxAddSubtitleSFF.InvokeSelfThreeArgs( FlashArgInt( id ), FlashArgString( speakerNameDisplayText ), FlashArgString( htmlString ) );
	}
	
	event  OnSubtitleRemoved( id : int )
	{
		m_fxRemoveSubtitleSFF.InvokeSelfOneArg( FlashArgInt( id ) );
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{		
		m_fxUpdateWidthSFF.InvokeSelfOneArg( FlashArgNumber( theGame.GetUIHorizontalFrameScale() ) );
		
		return super.UpdateScale( scale, flashModule );
	}
}

exec function hud_addsub( speaker : string, text : string )
{
	var hud : CR4ScriptedHud;
	var subtitlesModule : CR4HudModuleSubtitles;

	hud = (CR4ScriptedHud)theGame.GetHud();
	subtitlesModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
	subtitlesModule.OnSubtitleAdded( 1, speaker, text );
}

exec function hud_remsub()
{
	var hud : CR4ScriptedHud;
	var subtitlesModule : CR4HudModuleSubtitles;

	hud = (CR4ScriptedHud)theGame.GetHud();
	subtitlesModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
	subtitlesModule.OnSubtitleRemoved( 1 );
}