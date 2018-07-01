package fe.state;

import fe.asset.Level;
import fe.common.SaveUtil;
import fe.menu.MenuLayout;
import fe.menu.MenuModel;
import fe.menu.substate.StartLevelPage;
import fe.menu.substate.WelcomePage;
import fe.menu.ui.MenuMap;
import fe.menu.ui.MenuUI;
import h2d.Layers;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.HPPServices;
import hxd.Res;
import hxd.res.Sound;
import motion.Actuate;

class MenuState extends Base2dState
{
	var menuModel:MenuModel;
	var menuMap:MenuMap;

	var layout:MenuLayout;

	var welcomePage:WelcomePage;
	var startLevelPage:StartLevelPage;
	var menuUI:MenuUI;

	var backgroundLoopMusic:Sound;

	var isOpenedByGame:Bool;

	public function new(stage:Base2dStage, isOpenedByGame:Bool = false)
	{
		this.isOpenedByGame = isOpenedByGame;
		menuModel = new MenuModel();

		super(stage);

		if (isOpenedByGame)
		{
			backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.game_loop else null;
			if (backgroundLoopMusic != null) backgroundLoopMusic.play(true, AppConfig.MUSIC_VOLUME, AppConfig.CHANNEL_GROUP_MUSIC);
		}
	}

	override function build()
	{
		menuMap = new MenuMap(new Layers(stage), startLevelRequest);
		menuUI = new MenuUI(stage, HPPServices.open);

		welcomePage = new WelcomePage(function()
		{
			backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.game_loop else null;
			if (backgroundLoopMusic != null) backgroundLoopMusic.play(true, AppConfig.MUSIC_VOLUME, AppConfig.CHANNEL_GROUP_MUSIC);
			closeSubState();
		});

		startLevelPage = new StartLevelPage(
			function(){ HppG.changeState(GameState, [menuModel.selectedLevelId.value]); },
			closeSubState,
			menuModel.selectedLevelId,
			menuModel.selectedRawMap,
			menuModel.selectedLevelsHighScore
		);

		layout = new MenuLayout(
			stage,
			menuUI,
			menuMap,
			welcomePage,
			startLevelPage
		);

		if (!isOpenedByGame) openWelcomePage();

		onStageResize(stage.width, stage.height);
	}

	function openWelcomePage():Void
	{
		openSubState(welcomePage);

		menuMap.disable();
	}

	function startLevelRequest(levelId:UInt):Void
	{
		if (levelId != menuModel.selectedLevelId.value)
		{
			menuModel.selectedLevelId.set(levelId);
			menuModel.selectedRawMap.set(Level.getLevelConfig(levelId).rawMap);
			menuModel.selectedLevelsHighScore.set(SaveUtil.getLevelInfo(levelId).score);
		}

		menuMap.disable();
		openSubState(startLevelPage);

		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME / 3;
	}

	override public function onSubStateClosed()
	{
		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME;

		menuMap.enable();
	}

	override public function onStageResize(width:UInt, height:UInt)
	{
		super.onStageResize(width, height);

		layout.update(width, height);

		menuMap.onStageResize();
	}

	function resumeRequest()
	{
		Actuate.resumeAll();
	}

	function pauseRequest()
	{
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
		if (backgroundLoopMusic != null) backgroundLoopMusic.stop();

		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME;

		super.dispose();
	}
}