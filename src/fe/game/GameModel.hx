package fe.game;

import fe.game.Elem.ElemType;
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel
{
	public var remainingMoves:State<UInt> = new State(0);
	public var starRequirements:Array<UInt> = null;
	public var elemGoals:Map<ElemType, ElemGoalData> = new Map<ElemType, ElemGoalData>();
	public var score:State<UInt> = new State(0);

	public var stars:Observable<UInt>;

	public function new()
	{
		stars = Observable.auto(function() {
			for (i in 0...starRequirements.length)
			{
				if (score.value == starRequirements[i]) return cast Math.min(i + 1, starRequirements.length);
				if (score.value < starRequirements[i]) return i;
			}

			return starRequirements.length;
		});
	}
}

typedef ElemGoalData =
{
	var collected:State<UInt>;
	var expected:UInt;
}