package fe.menu.substate;

import hpp.heaps.Base2dSubState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WelcomePage extends Base2dSubState
{
	public function new()
	{
		super();
	}

	override function build()
	{
	}

	override public function onOpen()
	{
		rePosition();
	}

	function rePosition()
	{
	}

	override public function onStageResize(width:Float, height:Float)
	{
		rePosition();
	}
}