package fe.game;

import fe.game.Elem.ElemType;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel
{
	public function new() {}

	public var remainingMoves:State<UInt> = new State(0);
	public var elemGoals:State<Map<ElemType, UInt>> = new State(new Map<ElemType, UInt>());
	public var collectedElems:State<Map<ElemType, UInt>> = new State(new Map<ElemType, UInt>());
	public var score:State<Float> = new State(0.0);
}