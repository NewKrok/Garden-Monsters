package fe.game;

import h2d.Bitmap;
import h2d.Layers;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Background extends Layers
{
	var baseBack:Bitmap;
	var leafLeft:Bitmap;
	var leafRight:Bitmap;

	public function new(parent:Layers)
	{
		super(parent);

		baseBack = new Bitmap(Res.image.game.background.toTile(), this);

		leafLeft = new Bitmap(Res.image.game.ui.leaf.toTile(), this);
		leafLeft.smooth = true;

		leafRight = new Bitmap(Res.image.game.ui.leaf.toTile(), this);
		leafRight.smooth = true;
		leafRight.scaleX = -1 * AppConfig.GAME_BITMAP_SCALE;
	}

	public function onResize(width:UInt, height:UInt, ratio:Float):Void
	{
		baseBack.tile.scaleToSize(width, height);

		leafLeft.setScale(ratio * AppConfig.GAME_BITMAP_SCALE);

		leafRight.scaleX = -ratio * AppConfig.GAME_BITMAP_SCALE;
		leafRight.scaleY = ratio * AppConfig.GAME_BITMAP_SCALE;
		leafRight.x = width;
	}
}