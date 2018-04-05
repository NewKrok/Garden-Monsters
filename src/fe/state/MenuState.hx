package fe.state;

import h2d.Bitmap;
import hpp.heaps.Base2dState;
import hpp.heaps.Base2dSubState;
import hxd.Res;
import hxd.res.Sound;
import fe.menu.substate.CampaignPage;
import fe.menu.substate.SettingsPage;
import fe.menu.substate.WelcomePage;

class MenuState extends Base2dState
{
	var welcomePage:WelcomePage;
	var settingsPage:SettingsPage;
	var campaignPage:CampaignPage;

	var backgroundLoopMusic:Sound;
	var subStateChangeSound:Sound;

	override function build()
	{
		//backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.Eerie_Cyber_World_Looping else null;
		//subStateChangeSound = if (Sound.supportedFormat(Mp3)) Res.sound.UI_Quirky20 else null;

		if (backgroundLoopMusic != null) backgroundLoopMusic.play(true, .3);

		welcomePage = new WelcomePage();
		settingsPage = new SettingsPage();
		campaignPage = new CampaignPage();

		openSubState(welcomePage);
		onStageResize(0, 0);
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

	override public function onFocus()
	{
		//TweenMax.resumeAll(true, true, true);
	}

	override public function onFocusLost()
	{
		//TweenMax.pauseAll(true, true, true);
	}

	override public function dispose()
	{
		backgroundLoopMusic.stop();
		backgroundLoopMusic.dispose();
		subStateChangeSound.stop();
		subStateChangeSound.dispose();

		super.dispose();
	}
}