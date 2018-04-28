package fe.state;

import fe.Layout;
import fe.game.Background;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.Elem.ElemType;
import fe.game.GameModel;
import fe.asset.Level;
import fe.game.SkillHandler;
import fe.game.dialog.GameDialog;
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
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var gameModel:GameModel;

	var gameContainer:Layers;
	var interactiveArea:Interactive;
	var background:Background;
	var gameUI:GameUI;
	var gameDialog:GameDialog;

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

		background = new Background(stage);
		gameContainer = new Layers(stage);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		reset();

		//createRandomBoard(function(){ trace("Start Game!"); });

		loadLevel(Level.getLevelData(0));

		gameUI = new GameUI(stage, gameModel);
		gameDialog = new GameDialog(stage, gameModel);
		gameContainer.addChild(effectHandler.view);

		layout = new Layout(
			stage,
			background,
			gameContainer,
			interactiveArea,
			gameUI,
			gameDialog
		);
		onStageResize(stage.width, stage.height);
	}

	function createRandomBoard(onComplete:Void->Void)
	{
		if (boardCreationStartTime == 0) boardCreationStartTime = Date.now().getTime();

		var availableElemTypes = [ElemType.Elem1, ElemType.Elem2, ElemType.Elem3, ElemType.Elem4, ElemType.Elem5, ElemType.Elem6, ElemType.Elem7];
		var map = BoardHelper.createRandomPlayableMap(10, 8, 5, 5, availableElemTypes);
		if (map == null)
			Timer.delay(function(){ createRandomBoard(onComplete); }, 200);
		else
		{
			board = new Board(gameContainer, interactiveArea, effectHandler, skillHandler, availableElemTypes, map);

			trace("Board created, time: " + (Date.now().getTime() - boardCreationStartTime) + "ms, possibilities: " + board.foundPossibilities.length + ", match: " + board.foundMatch.length);
			onComplete();
		}
	}

	function loadLevel(data:LevelData)
	{
		gameModel.remainingMoves.set(data.maxMovement);
		gameModel.starRequirements = data.starRequirements.concat([]);

		for (key in data.elemGoals.keys())
		{
			gameModel.elemGoals.set(
				key,
				{
					expected: data.elemGoals.get(key),
					collected: new State<UInt>(0)
				}
			);
		}

		board = new Board(
			gameContainer,
			interactiveArea,
			effectHandler,
			skillHandler,
			data.availableElemTypes,
			BoardHelper.createMap(data.rawMap, data.availableElemTypes)
		);

		board.onSuccessfulSwap(function(){
			gameModel.remainingMoves.set(gameModel.remainingMoves.value - 1);
		});
		board.onElemCollect(function(e){
			if (gameModel.elemGoals.exists(e))
				gameModel.elemGoals.get(e).collected.set(gameModel.elemGoals.get(e).collected.value + 1);

			// TODO add to config + multiplier
			gameModel.score.set(gameModel.score.value + 50);
		});
		board.onNoMoreMoves(function(){
			gameDialog.openNoMoreMovesDialog();
		});
		board.onTurnEnd(function(){
			gameDialog.closeNoMoreMovesDialog();
		});
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