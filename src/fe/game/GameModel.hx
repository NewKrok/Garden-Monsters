package fe.game;

import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel
{
	public function new() {}

	public var remainingMoves:State<UInt> = new State(0);
	public var score:State<Float> = new State(0.0);
}