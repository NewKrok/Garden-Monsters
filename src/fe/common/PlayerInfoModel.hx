package fe.common;

import fe.game.Elem.ElemType;
import fe.game.Help.HelpType;
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class PlayerInfoModel
{
	public var helps:Map<HelpType, State<UInt>> = new Map<HelpType, State<UInt>>();
}