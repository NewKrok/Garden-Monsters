package fe.common;

import h2d.Bitmap;
import h2d.Layers;
import h2d.Tile;
import hpp.util.GeomUtil.SimplePoint;
import motion.Actuate;
import tink.CoreApi.Future;
import tink.CoreApi.Noise;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BaseDialog extends Layers
{
	var defaultY:Int = 0;

	public function new(parent, background:Tile, offset:SimplePoint = null)
	{
		super(parent);

		offset = offset == null ? { x: 0, y: 0 }: offset;

		var back = new Bitmap(background, this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		x = offset.x + -back.tile.width / 2 * AppConfig.GAME_BITMAP_SCALE;
		y = defaultY = cast(offset.y + -back.tile.height / 2 * AppConfig.GAME_BITMAP_SCALE);
	}

	public function open():Void
	{
		alpha = 0;
		y = defaultY + 50;
		visible = true;

		Actuate.tween(this, .5, {
			alpha: 1,
			y: defaultY
		}).onUpdate(function(){ y = y; });
	}

	public function close():Future<Noise>
	{
		var t = Future.trigger();

		Actuate.tween(this, .5, {
			alpha: 0,
			y: defaultY - 50
		}).onUpdate(function(){ y = y; }).onComplete(function(){ visible = false; t.trigger(Noise); });

		return t.asFuture();
	}
}