package fe.game.ui;

import h2d.Bitmap;
import h2d.Layers;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpsUI extends Layers
{
	public function new(parent)
	{
		super(parent);

		new Bitmap(Res.image.game.ui.long_ui_panel.toTile(), this);
	}
}