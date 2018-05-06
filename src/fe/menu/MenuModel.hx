package fe.menu;

import fe.game.Elem.ElemType;
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuModel
{
	public var selectedLevelId:State<UInt> = new State<UInt>(0);
	public var selectedRawMap:State<Array<Array<Int>>> = new State<Array<Array<Int>>>([]);

	public function new()
	{
	}
}