package fe.game.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;
import motion.Actuate;
import motion.easing.Back;
import motion.easing.Elastic;
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

	public function onMovesIncreased():Void
	{
		var img = new Bitmap(Res.image.common.help.apple_juice.toTile(), this);
		img.smooth = true;
		img.setScale(.1 * AppConfig.GAME_BITMAP_SCALE);
		img.tile.dx = cast -img.tile.width / 2;
		img.tile.dy = cast -img.tile.height / 2;
		img.alpha = 0;
		img.x = 130;
		img.y = 100;

		Actuate.tween(img, .5, {
			scaleX: 1.5 * AppConfig.GAME_BITMAP_SCALE,
			scaleY: 1.5 * AppConfig.GAME_BITMAP_SCALE,
			alpha: 1
		}).delay(.2).ease(Elastic.easeOut).onUpdate(function(){
			img.scaleX = img.scaleX;
		}).onComplete(function(){
			Actuate.tween(img, .5, {
				scaleX: .1 * AppConfig.GAME_BITMAP_SCALE,
				scaleY: .1 * AppConfig.GAME_BITMAP_SCALE,
				alpha: 0
			}).delay(.4).ease(Back.easeIn).onUpdate(function(){
				img.scaleX = img.scaleX;
			}).onComplete(function(){
				img.remove();
				img = null;
			});
		});
	}
}