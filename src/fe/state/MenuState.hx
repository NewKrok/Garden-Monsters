package fe.state;

import fe.asset.Level;
import fe.menu.MenuModel;
import fe.menu.MenuLayout;
import fe.menu.ui.LevelButton;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hxd.Event;
import hxd.Res;
import hxd.res.Sound;
import hxd.Cursor;
import fe.menu.substate.StartLevelPage;
import fe.menu.substate.WelcomePage;
import hxd.snd.Channel;
import motion.Actuate;
import motion.easing.Linear;

class MenuState extends Base2dState
{
	static inline var MAX_OVERDRAG:UInt = 50;

	var menuModel:MenuModel;

	var menuContainer:Layers;
	var backgroundContainer:Layers;
	var interactiveArea:Interactive;

	var layout:MenuLayout;

	var welcomePage:WelcomePage;
	var startLevelPage:StartLevelPage;
	var leafTop:Bitmap;
	var leafBottom:Bitmap;

	var levelButtons:Array<LevelButton>;

	var backgroundLoopMusic:Sound;

	var isDragging:Bool = false;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartContainerPoint:SimplePoint = { x: 0, y: 0 };
	var dragForce:Float = 0;
	var prevCheckForceYPoint:Int = 0;
	var dragForceTime:Float = 0;
	var isOpenedByGame:Bool;

	public function new(stage:Base2dStage, isOpenedByGame:Bool = false)
	{
		this.isOpenedByGame = isOpenedByGame;
		menuModel = new MenuModel();

		super(stage);
	}

	override function build()
	{
		interactiveArea = new Interactive(stage.width, stage.height, stage);
		interactiveArea.cursor = Cursor.Default;

		menuContainer = new Layers(stage);
		backgroundContainer = new Layers(menuContainer);

		var backgroundTop = new Bitmap(Res.image.menu.map_top.toTile(), backgroundContainer);
		backgroundTop.smooth = true;
		backgroundTop.setScale(AppConfig.GAME_BITMAP_SCALE);

		leafTop = new Bitmap(Res.image.menu.leaf_total.toTile(), menuContainer);
		leafTop.smooth = true;
		leafTop.setScale(AppConfig.GAME_BITMAP_SCALE);

		var backgroundBottom = new Bitmap(Res.image.menu.map_bottom.toTile(), backgroundContainer);
		backgroundBottom.smooth = true;
		backgroundBottom.setScale(AppConfig.GAME_BITMAP_SCALE);
		backgroundBottom.y = backgroundTop.getSize().height;

		leafBottom = new Bitmap(Res.image.menu.leaf_total.toTile(), menuContainer);
		leafBottom.smooth = true;
		leafBottom.setScale(AppConfig.GAME_BITMAP_SCALE);
		leafBottom.tile.flipY();
		leafBottom.y = backgroundContainer.getSize().height;

		var levelButtonPoints:Array<SimplePoint> = [
			{ x: 1729, y: 3858 },
			{ x: 1270, y: 3603 },
			{ x: 766, y: 3718 },
			{ x: 317, y: 3556 },
			{ x: 486, y: 3183 },
			{ x: 982, y: 3155 },
			{ x: 1250, y: 2832 },
			{ x: 1628, y: 2543 },
			{ x: 1788, y: 2110 },
			{ x: 1330, y: 1896 },
			{ x: 926, y: 2117 },
			{ x: 567, y: 2363 },
			{ x: 237, y: 2133 },
			{ x: 290, y: 1659 },
			{ x: 655, y: 1393 },
			{ x: 1074, y: 1273 },
			{ x: 1471, y: 1172 },
			{ x: 1701, y: 815 },
			{ x: 1552, y: 384 },
			{ x: 1028, y: 71 }
		];
		var buttonPadding = 20;
		levelButtons = [];
		for (i in 0...levelButtonPoints.length)
		{
			var levelButton = new LevelButton(menuContainer, i, startLevelRequest);
			levelButton.x = (levelButtonPoints[i].x + levelButton.getSize().width / 2 + buttonPadding) * AppConfig.GAME_BITMAP_SCALE;
			levelButton.y = (levelButtonPoints[i].y + levelButton.getSize().height / 2 + buttonPadding) * AppConfig.GAME_BITMAP_SCALE;
			levelButtons.push(levelButton);
		}

		interactiveArea.onPush = function(e:Event)
		{
			if (activeSubState != null) return;

			Actuate.stop(menuContainer);

			isDragging = true;
			dragStartPoint.x = e.relX;
			dragStartPoint.y = e.relY;
			dragStartContainerPoint.x = menuContainer.x;
			dragStartContainerPoint.y = menuContainer.y;

			dragForce = 0;
			prevCheckForceYPoint = Std.int(e.relY);
		};

		interactiveArea.onRelease = function(_)
		{
			Actuate.stop(menuContainer);

			if (menuContainer.y > 0)
			{
				Actuate.tween(menuContainer, .4, {
					y: normalizeContainerY(menuContainer.y, false)
				}).onUpdate(function() {
					menuContainer.y = menuContainer.y;
					recalculateLeafPositions();
				});
			}
			else if (menuContainer.y < -backgroundContainer.getSize().height * menuContainer.scaleY + stage.height)
			{
				Actuate.tween(menuContainer, .4, {
					y: normalizeContainerY(menuContainer.y, false)
				}).onUpdate(function() {
					menuContainer.y = menuContainer.y;
					recalculateLeafPositions();
				});
			}
			else if (isDragging && Date.now().getTime() - dragForceTime < 30)
			{
				Actuate.tween(menuContainer, Math.abs(.02 * dragForce), {
					y: normalizeContainerY(menuContainer.y + dragForce * 5, false)
				}).onUpdate(function() {
					menuContainer.y = menuContainer.y;
					recalculateLeafPositions();
				});
			}

			isDragging = false;
		};

		interactiveArea.onMove = function(e:Event)
		{
			if (isDragging)
			{
				var d = GeomUtil.getDistance({ x: e.relX, y: e.relY }, dragStartPoint);

				if (d > 10)
				{
					menuContainer.y = normalizeContainerY(dragStartContainerPoint.y + (e.relY - dragStartPoint.y));
					dragForce = e.relY - prevCheckForceYPoint;
					prevCheckForceYPoint = Std.int(e.relY);
					dragForceTime = Date.now().getTime();

					recalculateLeafPositions();
				}
			}
		};

		welcomePage = new WelcomePage();
		startLevelPage = new StartLevelPage(
			function(){ HppG.changeState(GameState, [menuModel.selectedLevelId.value]); },
			closeSubState,
			menuModel.selectedLevelId,
			menuModel.selectedRawMap
		);

		layout = new MenuLayout(
			stage,
			menuContainer,
			welcomePage,
			startLevelPage,
			interactiveArea
		);

		if (!isOpenedByGame) openWelcomePage();

		onStageResize(stage.width, stage.height);

		menuContainer.y = -backgroundContainer.getSize().height * menuContainer.scaleY + stage.height;
	}

	function recalculateLeafPositions()
	{
		if (menuContainer.y > 0) leafTop.y = -menuContainer.y / menuContainer.scaleY;
		else leafTop.y = 0;

		var bottomDiff = (-backgroundContainer.getSize().height * menuContainer.scaleY + stage.height) - menuContainer.y;
		bottomDiff = Math.min(bottomDiff, MAX_OVERDRAG * menuContainer.scaleY);
		if (bottomDiff > 0) leafBottom.y = backgroundContainer.getSize().height + bottomDiff / menuContainer.scaleY;
		else leafBottom.y = backgroundContainer.getSize().height;
	}

	function openWelcomePage():Void
	{
		openSubState(welcomePage);
		interactiveArea.cursor = Cursor.Button;

		for (b in levelButtons) b.isEnabled = false;

		interactiveArea.onClick = function(e:Event)
		{
			if (activeSubState == welcomePage)
			{
				welcomePage.closeRequest().handle(function(){
					backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.game_loop else null;
					if (backgroundLoopMusic != null) backgroundLoopMusic.play(true, AppConfig.MUSIC_VOLUME, AppConfig.CHANNEL_GROUP_MUSIC);

					closeSubState();
				});
			}
		}
	}

	function startLevelRequest(levelId:UInt):Void
	{
		if (levelId != menuModel.selectedLevelId.value)
		{
			menuModel.selectedLevelId.set(levelId);
			menuModel.selectedRawMap.set(Level.getLevelData(levelId).rawMap);
		}

		openSubState(startLevelPage);

		for (b in levelButtons) b.isEnabled = false;

		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME / 3;
	}

	function normalizeContainerY(baseY:Float, withOverFlow:Bool = true):Float
	{
		baseY = Math.max(baseY, -backgroundContainer.getSize().height * menuContainer.scaleY + stage.height - (withOverFlow ? MAX_OVERDRAG * menuContainer.scaleY : 0));
		baseY = Math.min(baseY, withOverFlow ? MAX_OVERDRAG * menuContainer.scaleY : 0);

		return baseY;
	}

	override public function onSubStateClosed()
	{
		interactiveArea.onClick = function(_){};
		interactiveArea.cursor = Cursor.Default;

		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME;

		for (b in levelButtons) b.isEnabled = true;
	}

	override public function onStageResize(width:UInt, height:UInt)
	{
		super.onStageResize(width, height);

		layout.update(width, height);

		Actuate.stop(menuContainer);
		menuContainer.y = normalizeContainerY(menuContainer.y);

		recalculateLeafPositions();
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
		backgroundLoopMusic.stop();

		AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME;

		super.dispose();
	}
}