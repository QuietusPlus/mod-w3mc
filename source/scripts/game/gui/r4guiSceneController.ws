/*
Copyright © CD Projekt RED 2015
*/

class CR4GuiSceneController
{
	private var _isEntitySpawning			: bool;				default _isEntitySpawning = false;

	private var _entityTemplateAlias		: string;
	private var _entityAppearance			: name;
	private var _environmentAlias			: string;
	private var _environmentSunRotation		: EulerAngles;
	private var _cameraUpdate  				: bool;
	private var _cameraLookAt				: Vector;
	private var _cameraRotation				: EulerAngles;
	private var _cameraDistance				: float;
	private var _fov						: float;
	private var _updateItems				: bool;
	
	private var _entityPosition 			: Vector;
	private var _entityRotation 			: EulerAngles;
	private var _entityScale				: Vector;
	private var _updateEntityTransform		: bool; default _updateEntityTransform = false;

	function OnGuiSceneEntitySpawned()
	{
		_isEntitySpawning = false;
		
		if ( _entityTemplateAlias != "" )
		{
			SetEntityTemplate( _entityTemplateAlias );
			_entityTemplateAlias = "";
		}
		else
		{
			if ( _entityAppearance != '' )
			{
				SetEntityAppearance( _entityAppearance );
				_entityAppearance = '';
			}
			if ( _environmentAlias != "" )
			{
				SetEnvironmentAndSunRotation( _environmentAlias, _environmentSunRotation );
				_environmentAlias = "";
			}
			
			if ( _cameraUpdate )
			{
				_cameraUpdate = false;
				SetCamera( _cameraLookAt, _cameraRotation, _cameraDistance, _fov );
			}
			
			if ( _updateItems )
			{
				_updateItems = false;
				SetEntityItems( _updateItems );
			}
			
			if (_updateEntityTransform)
			{
				_updateEntityTransform = false;
				SetEntityTransform( _entityPosition, _entityRotation, _entityScale );
			}
		}
	}

	function OnGuiSceneEntityDestroyed()
	{
	}
	
	public function SetEntityTemplate( entityTemplateAlias : string )
	{
		var templateResource : CEntityTemplate;

		if ( _isEntitySpawning )
		{
			_entityTemplateAlias = entityTemplateAlias;
		}
		else
		{
			templateResource = ( CEntityTemplate )LoadResource( entityTemplateAlias );
			if ( templateResource )
			{
				_isEntitySpawning = true;
				theGame.GetGuiManager().SetSceneEntityTemplate( templateResource );
			}
		}
	}
	
	public function SetEntityAppearance( appearance : name )
	{
		if ( _isEntitySpawning )
		{
			_entityAppearance = appearance;
		}
		else
		{
			theGame.GetGuiManager().ApplyAppearanceToSceneEntity( appearance );
		}
	}

	public function SetEnvironmentAndSunRotation( environmentAlias : string, environmentSunRotation : EulerAngles )
	{
		var environment : CEnvironmentDefinition;

		if ( _isEntitySpawning )
		{
			_environmentAlias = environmentAlias;
			_environmentSunRotation = environmentSunRotation;
		}
		else
		{
			environment = ( CEnvironmentDefinition )LoadResource( environmentAlias );
			if ( environment )
			{
				theGame.GetGuiManager().SetSceneEnvironmentAndSunPosition( environment, environmentSunRotation );
			}
		}
	}
	
	public function SetCamera( cameraLookAt : Vector, cameraRotation : EulerAngles, cameraDistance : float, fov : float )
	{
		if ( _isEntitySpawning )
		{
			_cameraUpdate   = true;
			_cameraLookAt   = cameraLookAt;
			_cameraRotation = cameraRotation;
			_cameraDistance = cameraDistance;
			_fov = fov;
		}
		else
		{
			theGame.GetGuiManager().SetupSceneCamera( cameraLookAt, cameraRotation, cameraDistance, fov );
		}
	}
	
	public function SetEntityTransform(position : Vector, rotation : EulerAngles, scale : Vector)
	{
		if ( _isEntitySpawning )
		{
			_updateEntityTransform = true;
			_entityPosition = position;
			_entityRotation = rotation;
			_entityScale = scale;
		}
		else
		{
			theGame.GetGuiManager().SetEntityTransform(position, rotation, scale);
		}
	}
	
	public function SetEntityItems( updateItems : bool )
	{
		var inventory : CInventoryComponent;
		var items : array< name >;
		var witcher : W3PlayerWitcher;

		if ( _isEntitySpawning )
		{
			_updateItems = updateItems;
		}
		else
		{
			inventory = thePlayer.GetInventory();
			if ( inventory )
			{
				inventory.GetHeldAndMountedItems( items );
				
				witcher = (W3PlayerWitcher) thePlayer;
				if ( witcher )
				{
					witcher.GetMountableItems( items );
				}
				
				theGame.GetGuiManager().UpdateSceneEntityItems( items );
			}
		}
	}

}