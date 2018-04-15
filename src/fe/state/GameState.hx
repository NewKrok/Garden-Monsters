package fe.state;

import fe.game.Elem;
import fe.game.SkillHandler;
import h2d.Bitmap;
import h2d.Layers;
import haxe.Timer;
import hpp.heaps.Base2dState;
import hxd.Res;
import motion.Actuate;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.GameModel;
import fe.game.util.BoardHelper;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var gameModel:GameModel;

	var gameContainer:Layers;

	var effectHandler:EffectHandler;
	var skillHandler:SkillHandler;

	var now:Float;

	var isPaused:Bool;

	var board:Board;
	var boardCreationStartTime:Float = 0;

	override function build()
	{
		gameModel = new GameModel();

		new Bitmap(Res.image.game.background.toTile(), stage);

		gameContainer = new Layers(stage);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		resizeGameContainer();
		reset();

		//createRandomBoard(function(){ trace("Start Game!"); });

		loadBoard();

		effectHandler.view.x = 25 + Elem.SIZE / 2;
		effectHandler.view.y = 25 + Elem.SIZE / 2;
		gameContainer.addChild(effectHandler.view);
	}

	function createRandomBoard(onComplete:Void->Void)
	{
		if (boardCreationStartTime == 0) boardCreationStartTime = Date.now().getTime();

		var map = BoardHelper.createRandomPlayableMap(10, 8, 5, 5);
		if (map == null)
			Timer.delay(function(){ createRandomBoard(onComplete); }, 200);
		else
		{
			board = new Board(gameContainer, map, effectHandler, skillHandler);

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
		board = new Board(gameContainer, map, effectHandler, skillHandler);
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

	override public function onStageResize(width:Float, height:Float)
	{
		super.onStageResize(width, height);

		resizeGameContainer();
	}

	function resizeGameContainer()
	{
		/*var ratio:Float = stage.width / AppConfig.APP_WIDTH;
		if (stage.height < AppConfig.APP_HEIGHT * ratio)
			ratio = stage.height / AppConfig.APP_HEIGHT;

		gameContainer.scaleX = gameContainer.scaleY = ratio;
		gameContainer.x = stage.width / 2 - gameContainer.getSize().width / 2;
		gameContainer.y = stage.height / 2 - gameContainer.getSize().height / 2;*/
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