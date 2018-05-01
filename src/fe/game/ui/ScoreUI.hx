package fe.game.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hpp.util.NumberUtil;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScoreUI extends Layers
{
	var localScore:Float = 0;

	public function new(parent, score:Observable<UInt>)
	{
		super(parent);

		var back = new Bitmap(Res.image.game.ui.score_back.toTile(), this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		var label = new Text(Fonts.DEFAULT_M, this);
		label.smooth = true;
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Left;
		label.x = 33;
		label.y = 8;
		Language.registerTextHolder(cast label, "score");

		var countText = new Text(Fonts.DEFAULT_L, this);
		countText.smooth = true;
		countText.text = Std.string(localScore);
		countText.textColor = 0xFFFFFF;
		countText.textAlign = Align.Left;
		countText.x = back.getSize().width - countText.textWidth - 30;

		score.bind(function(v) {
			Actuate.tween(this, 1, { localScore: v }).ease(Linear.easeNone).onUpdate(function() {
				countText.text = NumberUtil.formatNumber(Math.round(localScore));
				countText.x = back.getSize().width - countText.textWidth - 30;
			});
		});
	}
}