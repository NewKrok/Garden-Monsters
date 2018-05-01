package fe.state;

import fe.game.GameLayout;
import fe.asset.Level;
import fe.game.Background;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.Elem;
import fe.game.Elem.ElemType;
import fe.game.GameModel;
import fe.game.SkillHandler;
import fe.game.dialog.GameDialog;
import fe.game.ui.GameUI;
import fe.game.util.BoardHelper;
import h2d.Interactive;
import h2d.Layers;
import haxe.Timer;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hxd.Cursor;
import hxd.Res;
import hxd.res.Sound;
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

	var layout:GameLayout;

	var now:Float;
	var isPaused:Bool;

	var board:Board;
	var boardCreationStartTime:Float = 0;

	var backgroundLoopMusic:Sound;

	public function new(stage:Base2dStage, levelId:UInt)
	{
		super(stage);

		trace('OPEN LEVEL $levelId');
	}

	override function build()
	{
		backgroundLoopMusic = if (Sound.supportedFormat(Mp3) || Sound.supportedFormat(OggVorbis)) Res.sound.game_loop else null;
		if (backgroundLoopMusic != null)
			backgroundLoopMusic.getData().load(function(){
				backgroundLoopMusic.play(true, AppConfig.MUSIC_VOLUME, AppConfig.CHANNEL_GROUP_MUSIC);
			});

		gameModel = new GameModel();

		interactiveArea = new Interactive(stage.width, stage.height, stage);
		interactiveArea.cursor = Cursor.Default;

		background = new Background(stage);
		gameContainer = new Layers(stage);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		reset();

		//createRandomBoard(function(){ trace("Start Game!"); });

		gameModel.levelId = 0;
		loadLevel(Level.getLevelData(gameModel.levelId));

		gameUI = new GameUI(stage, gameModel);
		gameDialog = new GameDialog(stage, gameModel);
		gameContainer.addChild(effectHandler.view);

		layout = new GameLayout(
			stage,
			background,
			gameContainer,
			interactiveArea,
			gameUI,
			gameDialog
		);

		gameModel.isPossibleToPlay.set(false);
		gameDialog.openGoalsDialog();
		Actuate.timer(3).onComplete(function()
		{
			gameModel.isPossibleToPlay.set(true);
			gameDialog.closeGoalsDialog();
		});

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
			board = new Board(gameContainer, interactiveArea, effectHandler, skillHandler, availableElemTypes, gameModel.isPossibleToPlay, map);

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

		createMap(data.rawMap, data.availableElemTypes, function(map)
		{
			board = new Board(
				gameContainer,
				interactiveArea,
				effectHandler,
				skillHandler,
				data.availableElemTypes,
				gameModel.isPossibleToPlay,
				map
			);

			board.onSuccessfulSwap(function(){
				gameModel.remainingMoves.set(gameModel.remainingMoves.value - 1);
				if (gameModel.remainingMoves.value == 0) gameModel.isPossibleToPlay.set(false);
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
		});
	}

	function createMap(rawMap:Array<Array<Int>>, availableElemTypes:Array<ElemType> = null, onComplete:Array<Array<Elem>>->Void):Void
	{
		var map = BoardHelper.createMap(rawMap, availableElemTypes);

		var mapData = BoardHelper.analyzeMap(map);
		if (mapData.matches.length > 0 || mapData.movePossibilities.length == 0) createMap(rawMap, availableElemTypes, onComplete);
		else onComplete(map);
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