package fe.state;

import fe.game.GameLayout;
import fe.asset.Level;
import fe.game.Background;
import fe.game.Board;
import fe.game.EffectHandler;
import fe.game.Elem;
import fe.game.Elem.ElemType;
import fe.game.GameModel;
import fe.game.Help.HelpType;
import fe.game.SkillHandler;
import fe.game.dialog.GameDialog;
import fe.game.substate.MenuPage;
import fe.game.ui.GameUI;
import fe.game.util.BoardHelper;
import h2d.Interactive;
import h2d.Layers;
import haxe.Timer;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.Language;
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

	var menuPage:MenuPage;

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

	public function new(stage:Base2dStage, levelId:UInt = 0)
	{
		gameModel = new GameModel();
		gameModel.levelId = levelId;
		gameModel.helps.set(HelpType.BOMB, 3);
		gameModel.helps.set(HelpType.APPLE_JUICE, 3);
		gameModel.helps.set(HelpType.HOT_PEPPER, 3);
		gameModel.helps.set(HelpType.DICE, 3);
		gameModel.helps.set(HelpType.FRUIT_BOX, 3);

		super(stage);
	}

	override function build()
	{
		backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.game_loop else null;
		if (backgroundLoopMusic != null) backgroundLoopMusic.play(true, AppConfig.MUSIC_VOLUME, AppConfig.CHANNEL_GROUP_MUSIC);

		interactiveArea = new Interactive(stage.width, stage.height, stage);
		interactiveArea.cursor = Cursor.Default;

		background = new Background(stage);
		gameContainer = new Layers(stage);
		effectHandler = new EffectHandler();
		skillHandler = new SkillHandler();

		menuPage = new MenuPage(
			closeMenu,
			function(){ HppG.changeState(MenuState); }
		);

		reset();

		loadLevel(Level.getLevelData(gameModel.levelId));

		gameUI = new GameUI(stage, openMenu, gameModel, activateHelp);
		gameDialog = new GameDialog(stage, gameModel);
		gameContainer.addChild(effectHandler.view);

		layout = new GameLayout(
			stage,
			background,
			gameContainer,
			interactiveArea,
			gameUI,
			gameDialog,
			menuPage
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

	function openMenu()
	{
		gameModel.isPossibleToPlay.set(false);
		openSubState(menuPage);
	}

	function closeMenu()
	{
		gameModel.isPossibleToPlay.set(true);
		closeSubState();
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

			board.onSwapRequest(function(){
				gameModel.isPossibleToPlay.set(false);
			});
			board.onFailedSwap(function(){
				gameModel.isPossibleToPlay.set(true);
			});
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
				if (gameModel.remainingMoves.value > 0)
				{
					Actuate.timer(1).onComplete(board.shuffleElemsRequest);
					gameDialog.openNoMoreMovesDialog();
				}
			});
			board.onTurnEnd(function(){
				gameDialog.closeNoMoreMovesDialog();

				if (gameModel.remainingMoves.value == 0)
				{
					Actuate.timer(2).onComplete(function()
					{
						HppG.changeState(MenuState, [true]);
					});
				}
				else gameModel.isPossibleToPlay.set(true);
			});
		});
	}

	function createMap(rawMap:Array<Array<Int>>, availableElemTypes:Array<ElemType> = null, onComplete:Array<Array<Elem>>->Void):Void
	{
		var map = BoardHelper.createMap(rawMap, availableElemTypes);

		var mapData = BoardHelper.analyzeMap(map);
		if (mapData.matches.length > 0 || mapData.movePossibilities.length < 2) createMap(rawMap, availableElemTypes, onComplete);
		else onComplete(map);
	}

	function activateHelp(helpType:HelpType)
	{
		gameModel.isPossibleToPlay.set(false);
		gameModel.helps.get(helpType).set(gameModel.helps.get(helpType).value - 1);

		switch (helpType)
		{
			case HelpType.BOMB: skillHandler.addBomb(board.analyzeMap);

			case HelpType.APPLE_JUICE:
				gameUI.onMovesIncreased();
				Actuate.timer(.5).onComplete(function(){ gameModel.remainingMoves.set(gameModel.remainingMoves.value + 3); });
				Actuate.timer(1.6).onComplete(function(){ gameModel.isPossibleToPlay.set(true); });

			case HelpType.HOT_PEPPER:
				if (board.getCountOfMonsters() > 0) skillHandler.addHotPeppers(board.analyzeMap);
				else
				{
					gameModel.helps.get(helpType).set(gameModel.helps.get(helpType).value + 1);
					gameDialog.openSmallWarningDialog(Language.get("cant_use_help"), Language.get("no_monsters_on_the_board"));
					Actuate.timer(2).onComplete(function()
					{
						gameDialog.closeSmallWarningDialog();
						gameModel.isPossibleToPlay.set(true);
					});
				}

			case HelpType.DICE: board.shuffleElemsRequest();

			case HelpType.FRUIT_BOX:
				if (board.getCountOfFruits() > 0) skillHandler.collectRandomFruits(board.analyzeMap);
				else
				{
					gameModel.helps.get(helpType).set(gameModel.helps.get(helpType).value + 1);
					gameDialog.openSmallWarningDialog(Language.get("cant_use_help"), Language.get("no_fruits_on_the_board"));
					Actuate.timer(2).onComplete(function()
					{
						gameDialog.closeSmallWarningDialog();
						gameModel.isPossibleToPlay.set(true);
					});
				}
		}
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