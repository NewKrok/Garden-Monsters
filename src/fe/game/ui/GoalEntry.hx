package fe.game.ui;

import fe.asset.ElemTile;
import fe.asset.Fonts;
import fe.game.Elem.ElemType;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import h2d.Tile;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalEntry extends Layers
{
	var label:Text;
	var maxCount:UInt;

	public function new(parent:Sprite, elemType:ElemType, maxCount:UInt)
	{
		super(parent);

		this.maxCount = maxCount;

		var back = new Bitmap(Res.image.game.ui.goal_back.toTile(), this);
		back.y = 25;

		var elem = makeGraphic(ElemTile.tiles.get(cast elemType).baseTile.clone());
		elem.x = back.tile.width / 2;
		elem.y = 65;

		label = new Text(Fonts.DEFAULT_S, this);
		label.text = '0/$maxCount';
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Center;
		label.x = back.tile.width / 2 + 2;
		label.y = back.y + back.tile.height - label.getSize().height - 3;
	}

	function makeGraphic(tile:Tile):Bitmap
	{
		var bmp = new Bitmap(tile, this);

		bmp.smooth = true;
		bmp.scale(.28);
		bmp.tile.dx = cast -bmp.tile.width / 2;
		bmp.tile.dy = -bmp.tile.height;

		return bmp;
	}

	public function updateValue(v:UInt):Void
	{
		label.text = '${v}/${maxCount}';
	}
}