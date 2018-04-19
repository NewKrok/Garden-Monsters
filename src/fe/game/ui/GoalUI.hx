package fe.game.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalUI extends Layers
{
	public function new(parent)
	{
		super(parent);

		var back = new Bitmap(Res.image.game.ui.long_ui_panel.toTile(), this);

		var label = new Text(Fonts.DEFAULT_M, this);
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Center;
		label.x = back.tile.width / 2 + 2;
		label.y = 20;
		Language.registerTextHolder(cast label, "goals");
	}
}