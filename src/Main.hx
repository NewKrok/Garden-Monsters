package;

import fe.AppConfig;
import fe.asset.ElemTile;
import fe.asset.Fonts;
import fe.asset.HelpTile;
import fe.state.GameState;
import fe.state.MenuState;
import haxe.Json;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
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

		setDefaultAppSize(AppConfig.APP_WIDTH, AppConfig.APP_HEIGHT);
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		Fonts.init();
		ElemTile.init();
		HelpTile.init();

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

// handle mosue scroll in menu
// fix position of game container
// fiXml sound issue