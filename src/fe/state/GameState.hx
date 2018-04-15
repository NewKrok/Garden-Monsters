package fe.state;

import fe.Layout;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.GameModel;
import fe.game.SkillHandler;
import fe.game.util.BoardHelper;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import haxe.Timer;
import hpp.heaps.Base2dState;
import hxd.Cursor;
import hxd.Res;
import motion.Actuate;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var gameModel:GameModel;

	var gameContainer:Layers;
	var interactiveArea:Interactive;
	var background:Bitmap;

	var effectHandler:EffectHandler;
	var skillHandler:SkillHandler;

	var layout:Layout;

	var now:Float;

	var isPaused:Bool;

	var board:Board;
	var boardCreationStartTime:Float = 0;

	override function build()
	{
		gameModel = new GameModel();

		interactiveArea = new Interactive(stage.width, stage.height, stage);
		interactiveArea.cursor = Cursor.Default;

		background = new Bitmap(Res.image.game.background.toTile(), stage);

		gameContainer = new Layers(stage);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		reset();

		//createRandomBoard(function(){ trace("Start Game!"); });

		loadBoard();

		gameContainer.addChild(effectHandler.view);

		layout = new Layout(
			stage,
			gameContainer,
			interactiveArea
		);
		onStageResize(stage.width, stage.height);
	}

	function createRandomBoard(onComplete:Void->Void)
	{
		if (boardCreationStartTime == 0) boardCreationStartTime = Date.now().getTime();

		var map = BoardHelper.createRandomPlayableMap(10, 8, 5, 5);
		if (map == null)
			Timer.delay(function(){ createRandomBoard(onComplete); }, 200);
		else
		{
			board = new Board(gameContainer, interactiveArea, map, effectHandler, skillHandler);

			trace("Board created, time: " + (Date.now().getTime() - boardCreationStartTime) + "ms, possibilities: " + board.foundPossibilities.length + ", match: " + board.foundMatch.length);
			onComplete();
		}
	}

	function loadBoard()
	{
		var map = BoardHelper.createMap([
			[ -3, -3, -2, -2, -2, -2, -2, -2, -3, -3 ],
			[ -3, -2, -2, -2, -2, -2, -2, -2, -2, -3 ],
			[ -2, -2, -2, -2, -2, -2, -2, -2, -2, -2 ],
			[ -2, -2, -2, -2, -2, -2, -2, -2, -2, -2 ],
			[ -2, -2, -2, -2, -2, -2, -2, -2, -2, -2 ],
			[ -2, -2, -2, -2, -2, -2, -2, -2, -2, -2 ],
			[ -3, -2, -2, -2, -2, -2, -2, -2, -2, -3 ],
			[ -3, -3, -2, -2, -2, -2, -2, -2, -3, -3 ]
		]);
		board = new Board(gameContainer, interactiveArea, map, effectHandler, skillHandler);
	}

	override public function update(delta:Float)
	{
		if (isPaused) return;

		now = Date.now().getTime();
	}

	function reset()
	{
		pauseRequest();
	}

	override public function onStageResize(width:UInt, height:UInt)
	{
		super.onStageResize(width, height);

		layout.update(width, height);

		background.tile.scaleToSize(cast width, cast height);
	}

	function resumeRequest()
	{
		isPaused = false;
		Actuate.resumeAll();
	}

	function pauseRequest()
	{
		isPaused = true;
		Actuate.pauseAll();
	}

	override public function onFocus()
	{
		resumeRequest();
	}

	override public function onFocusLost()
	{
		pauseRequest();
	}

	override public function dispose()
	{

	}
}