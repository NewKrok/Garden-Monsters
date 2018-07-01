package;

import fe.AppConfig;
import fe.asset.ElemTile;
import fe.asset.Fonts;
import fe.asset.HelpTile;
import fe.common.SaveUtil;
import fe.state.GameState;
import fe.state.MenuState;
import haxe.Json;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.HPPServices;
import hpp.util.Language;
import hxd.Res;
import test.TestBoard;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	override function init()
	{
		super.init();

		HPPServices.init("hppservices", AppConfig.APP_ID);

		SaveUtil.load();
		AppConfig.SOUND_VOLUME = SaveUtil.data.applicationInfo.soundVolume;
		AppConfig.MUSIC_VOLUME = SaveUtil.data.applicationInfo.musicVolume;

		switch (SaveUtil.data.applicationInfo.lang)
		{
			case "en": Language.setLang(Json.parse(Res.lang.lang_en.entry.getText()));
			case "hu": Language.setLang(Json.parse(Res.lang.lang_hu.entry.getText()));
			case _: Language.setLang(Json.parse(Res.lang.lang_en.entry.getText()));
		}

		setDefaultAppSize(AppConfig.APP_WIDTH, AppConfig.APP_HEIGHT);
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		Fonts.init();
		ElemTile.init();
		HelpTile.init();

		//TestBoard.test();

		//changeState(GameState);
		changeState(MenuState);
	}

	static function main()
	{
		Res.initEmbed();
		new Main();
	}
}

// handle mosue scroll in menu