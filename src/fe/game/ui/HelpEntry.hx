package fe.game.ui;

import fe.asset.ElemTile;
import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import h2d.Tile;
import hpp.util.Language;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpEntry extends Layers
{
	var label:Text;
	var isChangedToDone:Bool;

	public function new(parent:Sprite, tile:Tile, collectedCount:Observable<UInt>)
	{
		super(parent);

		var elem = makeGraphic(tile.clone());
		elem.setScale(AppConfig.GAME_BITMAP_SCALE);
		elem.y = 30;

		var infoBack = new Bitmap(Res.image.common.ui.help_counter.toTile(), this);
		infoBack.smooth = true;
		infoBack.setScale(AppConfig.GAME_BITMAP_SCALE);

		elem.x = -infoBack.getSize().width + 65;
		elem.y = 60;

		label = new Text(Fonts.DEFAULT_XL, this);
		label.smooth = true;
		label.text = Std.string(collectedCount.value);
		label.textColor = 0xFFFFFF;
		label.textAlign = Align.Center;
		label.x = infoBack.getSize().width / 2 + 2;
		label.y = 0;

		collectedCount.bind(function(c:UInt)
		{
			label.text = '$c';
		});
	}

	function makeGraphic(tile:Tile):Bitmap
	{
		var bmp = new Bitmap(tile, this);

		bmp.smooth = true;
		bmp.tile.dx = cast -bmp.tile.width / 2;
		bmp.tile.dy = -bmp.tile.height;

		return bmp;
	}
}