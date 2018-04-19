package;

import fe.asset.Fonts;
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.Language;
import hxd.Res;
import fe.AppConfig;
import fe.asset.ElemTile;
import fe.state.GameState;
import fe.state.MenuState;
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

		setDefaultAppSize(AppConfig.APP_WIDTH, AppConfig.APP_HEIGHT);
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		Fonts.init();
		ElemTile.init();

		//Language.setLang(Json.parse(Res.lang.lang_hu.entry.getText()));
		Language.setLang(Json.parse(Res.lang.lang_en.entry.getText()));

		//TestBoard.test();

		changeState(GameState);
	}

	static function main()
	{
		Res.initEmbed();
		new Main();
	}
}