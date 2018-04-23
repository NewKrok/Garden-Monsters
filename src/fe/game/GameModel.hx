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
	public var elemGoals:Map<ElemType, ElemGoalData> = new Map<ElemType, ElemGoalData>();
	public var score:State<UInt> = new State(0);
}

typedef ElemGoalData =
{
	var collected:State<UInt>;
	var expected:UInt;
}