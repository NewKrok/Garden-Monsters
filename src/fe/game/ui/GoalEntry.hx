package fe.game.ui;

import fe.asset.ElemTile;
import fe.asset.Fonts;
import fe.game.Elem.ElemType;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import h2d.Tile;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalEntry extends Layers
{
	var doneMarker:Bitmap;

	var label:Text;
	var maxCount:UInt;

	public function new(parent:Sprite, elemType:ElemType, maxCount:UInt, collectedCount:Observable<UInt>)
	{
		super(parent);

		this.maxCount = maxCount;

		var baseSize = new Graphics(this);
		baseSize.drawRect(0, 0, 125, 10);

		var back = new Bitmap(Res.image.game.ui.goal_back.toTile(), this);
		back.x = baseSize.getSize().width / 2 - back.getSize().width / 2;
		back.y = 25;

		var elem = makeGraphic(ElemTile.tiles.get(cast elemType).baseTile.clone());
		elem.x = baseSize.getSize().width / 2;
		elem.y = 65;

		label = new Text(Fonts.DEFAULT_S, this);
		label.text = '0/0';
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Center;
		label.x = baseSize.getSize().width / 2 + 2;
		label.y = back.y + back.tile.height - label.getSize().height - 3;

		collectedCount.bind(function(e:UInt)
		{
			label.text = '$e/$maxCount';

			if (e >= maxCount && doneMarker == null)
			{
				doneMarker = new Bitmap(Res.image.game.ui.tick.toTile(), this);
				doneMarker.x = back.x + back.getSize().width - doneMarker.tile.width / 2;
				doneMarker.y = 15;
			}
		});
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
}