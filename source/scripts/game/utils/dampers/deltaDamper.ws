/*
Copyright © CD Projekt RED 2015
*/


class DeltaDamper
{
	protected var destValue : float;
	protected var currValue : float;
	protected var dampFactor : float;
	
	default destValue = 0.f;
	default currValue = 0.f;
	default dampFactor = 0.1f;
	
	public final function SetDamp( factor : float )
	{
		dampFactor = ClampF( factor, 0.f, 10000.f );
	}
	
	public final function Init( curr : float, dest : float )
	{
		currValue = curr;
		destValue = dest;
	}
	
	public final function Reset()
	{
		destValue = 0.f;
		currValue = 0.f;
	}
	
	public final function SetValue( value : float )
	{
		destValue = value;
	}
	
	public final function GetValue() : float
	{
		return currValue;
	}
	
	public function Update( dt : float )
	{
		currValue = currValue + ClampF( dt * dampFactor, 0.f, 1.f ) * ( destValue - currValue );
	}
	
	public final function UpdateAndGet( dt : float, value : float ) : float
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
}

class DeltaAngularDamper
{
	protected var destValue : float;
	protected var currValue : float;
	protected var dampFactor : float;
	
	default destValue = 0.f;
	default currValue = 0.f;
	default dampFactor = 0.1f;
	
	public final function SetDamp( factor : float )
	{
		dampFactor = ClampF( factor, 0.f, 10000.f );
	}
	
	public final function Init( curr : float, dest : float )
	{
		currValue = curr;
		destValue = dest;
	}
	
	public final function Reset()
	{
		destValue = 0.f;
		currValue = 0.f;
	}
	
	public final function SetValue( value : float )
	{
		destValue = value;
	}
	
	public final function GetValue() : float
	{
		return currValue;
	}
	
	public function Update( dt : float )
	{
		currValue = currValue + ClampF( dt * dampFactor, 0.f, 1.f ) * AngleDistance( destValue, currValue );
	}
	
	public final function UpdateAndGet( dt : float, value : float ) : float
	{
		SetValue( value );
		Update( dt );
		return GetValue();
	}
}