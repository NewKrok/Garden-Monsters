package fe.menu.substate;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Text;
import hpp.heaps.Base2dSubState;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CampaignPage extends Base2dSubState
{
	public function new()
	{
		super();
	}

	override function build()
	{
		var tf:Text = new Text(Fonts.DEFAULT_M, container);
		tf.text = "## Campaign Page ###############################\n";
		tf.text += "## ADD VIEW HERE ##";
		tf.x = 200;
		tf.y = 500;
	}
}