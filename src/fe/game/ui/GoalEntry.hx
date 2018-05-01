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
import hpp.util.Language;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalEntry extends Layers
{
	var label:Text;
	var maxCount:UInt;
	var isChangedToDone:Bool;

	public function new(parent:Sprite, elemType:ElemType, maxCount:UInt, collectedCount:Observable<UInt>, isPreview:Bool = false)
	{
		super(parent);

		this.maxCount = maxCount;

		var elem = makeGraphic(ElemTile.tiles.get(cast elemType).baseTile.clone());
		elem.setScale(AppConfig.GAME_BITMAP_SCALE);
		elem.y = 30;

		var infoBack = new Bitmap(Res.image.game.ui.goal_info_back.toTile(), this);
		infoBack.smooth = true;
		infoBack.setScale(AppConfig.GAME_BITMAP_SCALE);

		elem.x = infoBack.getSize().width / 2;

		label = new Text(Fonts.DEFAULT_M, this);
		label.smooth = true;
		label.text = isPreview ? Std.string(maxCount) : '0/0';
		label.textColor = 0xFFFFFF;
		label.textAlign = Align.Center;
		label.x = infoBack.getSize().width / 2 + 2;
		label.y = -2;

		if (!isPreview)
		{
			collectedCount.bind(function(e:UInt)
			{
				if (e >= maxCount)
				{
					if (!isChangedToDone)
					{
						isChangedToDone = true;
						label.textColor = 0xFFFF00;
						label.y = 0;
						Language.registerTextHolder(cast label, "done");
					}
				}
				else label.text = '$e/$maxCount';
			});
		}
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