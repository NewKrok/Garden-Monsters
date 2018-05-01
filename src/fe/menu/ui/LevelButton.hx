package fe.menu.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import h2d.Text;
import hxd.Cursor;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelButton extends Layers
{
	public var isEnabled(default, set):Bool;

	var interactive:Interactive;

	var baseGraphic:Bitmap;
	var overGraphic:Bitmap;
	var disabledGraphic:Bitmap;

	var levelId:UInt;

	public function new(parent:Layers, levelId:UInt, onClick:UInt->Void)
	{
		super(parent);

		this.levelId = levelId;

		var tile = Res.image.menu.ui.level_button.toTile();
		tile.scaleToSize(Std.int(tile.width * AppConfig.GAME_BITMAP_SCALE), Std.int(tile.height * AppConfig.GAME_BITMAP_SCALE));
		tile.dx = Std.int(-tile.width / 2);
		tile.dy = Std.int( -tile.height / 2);

		baseGraphic = new Bitmap(tile, this);
		baseGraphic.smooth = true;

		overGraphic = new Bitmap(tile);
		overGraphic.smooth = true;

		disabledGraphic = new Bitmap(tile);
		disabledGraphic.smooth = true;

		var label = new Text(Fonts.DEFAULT_XL, this);
		label.smooth = true;
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Left;
		label.text = Std.string(levelId + 1);
		label.x = -label.textWidth / 2;
		label.y = -label.textHeight / 2 - 10;

		interactive = new Interactive(baseGraphic.tile.width, baseGraphic.tile.height, this);
		interactive.cursor = Cursor.Button;
		interactive.onClick = function(_) { onClick(levelId); };
		interactive.onOver = onOverHandler;
		interactive.onOut = onOutHandler;
		interactive.x = -tile.width / 2;
		interactive.y = -tile.height / 2;
	}

	function onOverHandler(_)
	{
		if (!isEnabled) return;

		addChildAt(overGraphic, -1);
		removeChild(baseGraphic);
	}

	function onOutHandler(_)
	{
		overGraphic.alpha = 1;

		if (!isEnabled)
		{
			addChildAt(disabledGraphic, -1);
			removeChild(baseGraphic);
		}
		else
		{
			addChildAt(baseGraphic, -1);
			removeChild(disabledGraphic);
		}

		removeChild(overGraphic);
	}

	function set_isEnabled(value:Bool):Bool
	{
		isEnabled = value;

		interactive.visible = isEnabled;
		onOutHandler(null);

		return isEnabled;
	}
}