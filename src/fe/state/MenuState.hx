package fe.state;

import fe.menu.MenuLayout;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import hpp.heaps.Base2dState;
import hpp.heaps.Base2dSubState;
import hpp.util.GeomUtil;
import hxd.Event;
import hxd.Res;
import hxd.res.Sound;
import hxd.Cursor;
import fe.menu.substate.CampaignPage;
import fe.menu.substate.SettingsPage;
import fe.menu.substate.WelcomePage;
import motion.Actuate;
import motion.easing.Linear;

class MenuState extends Base2dState
{
	var menuContainer:Layers;
	var interactiveArea:Interactive;

	var layout:MenuLayout;

	var welcomePage:WelcomePage;
	var settingsPage:SettingsPage;
	var campaignPage:CampaignPage;

	var backgroundLoopMusic:Sound;
	var subStateChangeSound:Sound;

	var isDragging:Bool = false;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartContainerPoint:SimplePoint = { x: 0, y: 0 };
	var dragForce:Float = 0;
	var prevCheckForceYPoint:Int = 0;
	var dragForceTime:Float = 0;

	override function build()
	{
		//backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.Eerie_Cyber_World_Looping else null;
		//subStateChangeSound = if (Sound.supportedFormat(Mp3)) Res.sound.UI_Quirky20 else null;

		interactiveArea = new Interactive(stage.width, stage.height, stage);
		interactiveArea.cursor = Cursor.Default;

		menuContainer = new Layers(stage);

		var backgroundTop = new Bitmap(Res.image.menu.map_top.toTile(), menuContainer);
		backgroundTop.smooth = true;
		backgroundTop.setScale(AppConfig.GAME_BITMAP_SCALE);

		var backgroundBottom = new Bitmap(Res.image.menu.map_bottom.toTile(), menuContainer);
		backgroundBottom.smooth = true;
		backgroundBottom.setScale(AppConfig.GAME_BITMAP_SCALE);
		backgroundBottom.y = backgroundTop.getSize().height;

		interactiveArea.onPush = function(e:Event)
		{
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
			if (isDragging && Date.now().getTime() - dragForceTime < 30)
			{
				Actuate.stop(menuContainer);
				Actuate.tween(menuContainer, Math.abs(.02 * dragForce), {
					y: normalizeContainerY(menuContainer.y + dragForce * 5)
				}).onUpdate(function() {
					menuContainer.y = menuContainer.y;
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
				}
			}
		};

		welcomePage = new WelcomePage();
		settingsPage = new SettingsPage();
		campaignPage = new CampaignPage();

		layout = new MenuLayout(
			stage,
			menuContainer,
			interactiveArea
		);

		openSubState(welcomePage);
		onStageResize(0, 0);

		menuContainer.y = -menuContainer.getSize().height + stage.height;
		Actuate.timer(6).onComplete(function(){ changeState(GameState); });
	}

	function normalizeContainerY(baseY:Float):Float
	{
		baseY = Math.max(baseY, -menuContainer.getSize().height + stage.height);
		baseY = Math.min(baseY, 0);

		return baseY;
	}

	function startGame()
	{
		playSubStateChangeSound();

		changeState(GameState);
	}

	function openWelcomePage()
	{
		playSubStateChangeSound();
		openSubState(welcomePage);
	}

	function openSettingsPage()
	{
		playSubStateChangeSound();
		openSubState(settingsPage);
	}

	function openCampaignPage()
	{
		playSubStateChangeSound();
		openSubState(campaignPage);
	}

	override function onSubStateChanged(activeSubState:Base2dSubState):Void
	{
	}

	function playSubStateChangeSound():Void
	{
		if (subStateChangeSound != null) subStateChangeSound.play();
	}

	override public function onStageResize(width:UInt, height:UInt)
	{
		super.onStageResize(width, height);

		Actuate.stop(menuContainer);
		menuContainer.y = normalizeContainerY(menuContainer.y);

		layout.update(width, height);
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
		/*backgroundLoopMusic.stop();
		backgroundLoopMusic.dispose();
		subStateChangeSound.stop();
		subStateChangeSound.dispose();*/

		super.dispose();
	}
}