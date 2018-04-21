package fe.game;

import fe.AppConfig;
import fe.asset.ElemTile.MonsterTileInfo;
import h2d.Bitmap;
import h2d.Sprite;
import h2d.Tile;
import hxd.Res;
import motion.Actuate;
import motion.easing.Quad;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ElemGraphic extends Sprite
{
	public var hasMouseHover(default, set):Bool = false;
	public var isFrozen(default, set):Bool = false;

	var marker:Bitmap;
	var frozenBitmap:Bitmap;
	var baseBitmap:Bitmap;
	var hoverBitmap:Bitmap;

	var sX:Float = 1;
	var sY:Float = 1;

	public function new()
	{
		super();

		marker = makeGraphic(Res.image.game.elem_marker.toTile());
		marker.visible = false;
	}

	public function setTile(tileInfo:MonsterTileInfo):Void
	{
		if (baseBitmap != null)
		{
			baseBitmap.remove();
			baseBitmap = null;

			hoverBitmap.remove();
			hoverBitmap = null;
		}

		baseBitmap = makeGraphic(tileInfo.baseTile);
		hoverBitmap = makeGraphic(tileInfo.secondTile);

		baseBitmap.visible = !hasMouseHover;
		hoverBitmap.visible = hasMouseHover;
	}

	function makeGraphic(tile:Tile):Bitmap
	{
		var bmp = new Bitmap(tile, this);

		bmp.smooth = true;
		bmp.scale(AppConfig.GAME_BITMAP_SCALE);
		bmp.tile.dx = cast -bmp.tile.width / 2;
		bmp.tile.dy = cast -bmp.tile.height / 2;

		return bmp;
	}

	function set_hasMouseHover(value:Bool):Bool
	{
		if (value)
		{
			Actuate.tween(this, .3, { sX: Math.random() * .2 + .9, sY: Math.random() * .2 + .9 }, false).ease(Quad.easeOut).onUpdate(updateView);
			unmark();
		}
		else Actuate.tween(this, .3, { sX: 1, sY: 1 }, false).ease(Quad.easeOut).onUpdate(updateView);

		baseBitmap.visible = !value;
		hoverBitmap.visible = value;

		return hasMouseHover = value;
	}

	public function moveFinished()
	{
		Actuate.tween(this, .2, {
			y: y + 10, sX: Math.random() * .2 + 1, sY: Math.random() * .2 + .7
		}, false).ease(Quad.easeOut).onUpdate(updateView).onComplete(function(){
			Actuate.tween(this, .1, { y: y - 10, sX: 1, sY: 1 }, false).ease(Quad.easeOut).onUpdate(updateView);
		});
	}

	public function mark() { marker.visible = true; }

	public function unmark() { marker.visible = false; }

	function updateView()
	{
		scaleX = sX;
		scaleY = sY;
	}

	function set_isFrozen(value:Bool):Bool
	{
		if (value)
		{
			if (frozenBitmap == null) frozenBitmap = makeGraphic(Res.image.game.effect.ice.toTile());
			frozenBitmap.visible = true;
		}
		else if (frozenBitmap != null) frozenBitmap.visible = false;

		return isFrozen = value;
	}
}