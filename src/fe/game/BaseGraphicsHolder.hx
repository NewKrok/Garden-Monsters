package fe.game;

import h2d.Bitmap;
import h2d.Sprite;
import h2d.Tile;
import fe.AppConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BaseGraphicsHolder extends Sprite
{
	var bitmap:Bitmap;

	public function new(?tile:Tile)
	{
		super();

		if (tile != null) makeGraphic(tile);
	}

	public function setTile(t:Tile):Void
	{
		makeGraphic(t);
	}

	function makeGraphic(tile:Tile)
	{
		if (bitmap != null)
		{
			bitmap.remove();
			bitmap = null;
		}

		bitmap = new Bitmap(tile, this);
		bitmap.smooth = true;
		bitmap.scale(AppConfig.GAME_BITMAP_SCALE);
		bitmap.tile.dx = cast -bitmap.tile.width / 2;
		bitmap.tile.dy = cast -bitmap.tile.height / 2;
	}
}