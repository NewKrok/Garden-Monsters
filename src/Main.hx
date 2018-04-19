package;

import fe.asset.Fonts;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
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

		//TestBoard.test();

		changeState(GameState);
	}

	static function main()
	{
		Res.initEmbed();
		new Main();
	}
}