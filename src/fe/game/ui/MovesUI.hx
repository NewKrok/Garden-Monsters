package fe.game.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MovesUI extends Layers
{
	var countText:Text;
	var isStarRegistered:Bool = false;

	public function new(parent, remainingMoves:Observable<UInt>)
	{
		super(parent);

		var back = new Bitmap(Res.image.game.ui.moves_back.toTile(), this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		var countText = new Text(Fonts.DEFAULT_XXXL, this);
		countText.smooth = true;
		countText.text = Std.string(remainingMoves.value);
		countText.textColor = 0xFFBF00;
		countText.textAlign = Align.Center;
		countText.x = back.getSize().width / 2 + 2;
		countText.y = 15;

		var label = new Text(Fonts.DEFAULT_M, this);
		label.smooth = true;
		label.textColor = 0xFFFFFF;
		label.textAlign = Align.Center;
		label.x = back.getSize().width / 2 + 2;
		label.y = countText.y + countText.textHeight;
		Language.registerTextHolder(cast label, "moves");

		remainingMoves.bind(function(v) {
			countText.text = Std.string(v);
		});
	}
}