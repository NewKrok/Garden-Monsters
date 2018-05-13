package fe.game;

import fe.game.Elem.ElemType;
import fe.game.Help.HelpType;
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel
{
	public var remainingMoves:State<UInt> = new State(0);
	public var elemGoals:Map<ElemType, ElemGoalData> = new Map<ElemType, ElemGoalData>();
	public var helps:Map<HelpType, State<UInt>> = new Map<HelpType, State<UInt>>();
	public var score:State<UInt> = new State(0);
	public var playersBestScore:State<UInt> = new State(0);
	public var isPossibleToPlay:State<Bool> = new State(false);
	public var starPercentage:State<Float> = new State<Float>(0);

	public var stars:Observable<UInt>;

	public var starRequirements:Array<UInt> = null;
	public var levelId:UInt = 0;

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

		score.observe().bind(function(v){
			if (v != 0)
			{
				if (stars.value == 0) starPercentage.set(v / starRequirements[stars.value]);
				else starPercentage.set((v - starRequirements[stars.value - 1]) / (starRequirements[stars.value] - starRequirements[stars.value - 1]));
			}
		});
	}
}

typedef ElemGoalData =
{
	var collected:State<UInt>;
	var expected:UInt;
}