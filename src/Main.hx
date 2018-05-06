package;

import fe.AppConfig;
import fe.asset.ElemTile;
import fe.asset.Fonts;
import fe.state.MenuState;
import haxe.Json;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	override function init()
	{
		super.init();

		setDefaultAppSize(AppConfig.APP_WIDTH, AppConfig.APP_HEIGHT);
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		Fonts.init();
		ElemTile.init();

		//Language.setLang(Json.parse(Res.lang.lang_hu.entry.getText()));
		Language.setLang(Json.parse(Res.lang.lang_en.entry.getText()));

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