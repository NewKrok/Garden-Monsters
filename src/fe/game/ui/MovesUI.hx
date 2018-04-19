package fe.game.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MovesUI extends Layers
{
	var countText:Text;

	public function new(parent, remainingMoves:Observable<UInt>)
	{
		super(parent);

		var back = new Bitmap(Res.image.game.ui.short_ui_panel.toTile(), this);

		var label = new Text(Fonts.DEFAULT_M, this);
		label.text = "MOVES";
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Center;
		label.x = back.tile.width / 2 + 2;
		label.y = 20;

		var countText = new Text(Fonts.DEFAULT_L, this);
		countText.text = Std.string(remainingMoves.value);
		countText.textColor = 0xFFBF00;
		countText.textAlign = Align.Center;
		countText.x = back.tile.width / 2 + 2;
		countText.y = 40;

		remainingMoves.bind(function(v) {
			countText.text = Std.string(v);
		});
	}
}