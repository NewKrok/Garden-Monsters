package fe.state;

import fe.Layout;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.GameModel;
import fe.asset.Level;
import fe.game.SkillHandler;
import fe.game.ui.GameUI;
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
	var gameUI:GameUI;

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
		gameUI = new GameUI(stage, gameModel);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		reset();

		//createRandomBoard(function(){ trace("Start Game!"); });

		loadLevel(Level.getLevelData(0));

		gameContainer.addChild(effectHandler.view);

		layout = new Layout(
			stage,
			gameContainer,
			interactiveArea,
			gameUI
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

	function loadLevel(data:LevelData)
	{
		board = new Board(
			gameContainer,
			interactiveArea,
			BoardHelper.createMap(data.rawMap),
			effectHandler,
			skillHandler
		);

		board.onSuccessfulSwap(function(){
			gameModel.remainingMoves.set(gameModel.remainingMoves.value - 1);
		});
		board.onElemCollect(function(e){
			if (gameModel.collectedElems.value.exists(e)) gameModel.collectedElems.value.set(e, gameModel.collectedElems.value.get(e) + 1);
			else gameModel.collectedElems.value.set(e, 1);
		});

		gameModel.remainingMoves.set(data.maxMovement);
		gameModel.elemGoals.set(data.elemGoals);
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