package fe.menu.ui;

import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import h2d.Sprite;
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

	var leftStar:Bitmap;
	var leftStarInactive:Bitmap;
	var rightStar:Bitmap;
	var rightStarInactive:Bitmap;
	var middleStar:Bitmap;
	var middleStarInactive:Bitmap;

	var label:Text;

	var levelId:UInt;
	var isLocked:Bool;
	var starCount:UInt;

	public function new(
		parent:Layers,
		levelId:UInt,
		isLocked:Bool,
		isCompleted:Bool,
		starCount:UInt,
		onClick:UInt->Void
	){
		super(parent);

		this.levelId = levelId;
		this.isLocked = isLocked;
		this.starCount = starCount;

		var tile = Res.image.menu.ui.level_button.toTile();
		tile.scaleToSize(Std.int(tile.width * AppConfig.GAME_BITMAP_SCALE), Std.int(tile.height * AppConfig.GAME_BITMAP_SCALE));
		tile.dx = Std.int(-tile.width / 2);
		tile.dy = Std.int(-tile.height / 2);

		baseGraphic = new Bitmap(tile, this);
		baseGraphic.smooth = true;

		overGraphic = new Bitmap(tile);
		overGraphic.smooth = true;

		var disabledTile = Res.image.menu.ui.level_button_locked.toTile();
		disabledTile.scaleToSize(Std.int(disabledTile.width * AppConfig.GAME_BITMAP_SCALE), Std.int(disabledTile.height * AppConfig.GAME_BITMAP_SCALE));
		disabledTile.dx = Std.int(-disabledTile.width / 2);
		disabledTile.dy = Std.int(-disabledTile.height / 2);

		disabledGraphic = new Bitmap(disabledTile);
		disabledGraphic.smooth = true;

		label = new Text(Fonts.DEFAULT_XL, this);
		label.smooth = true;
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Left;
		label.text = Std.string(levelId + 1);
		label.x = -label.textWidth / 2;
		label.y = -label.textHeight / 2 - 10 + (isCompleted ? -6 : 0);

		if (!isLocked && isCompleted) buildStarView();

		interactive = new Interactive(baseGraphic.tile.width, baseGraphic.tile.height, this);
		interactive.cursor = Cursor.Button;
		interactive.onClick = function(_) { onClick(levelId); };
		interactive.onOver = onOverHandler;
		interactive.onOut = onOutHandler;
		interactive.x = -tile.width / 2;
		interactive.y = -tile.height / 2;
	}

	function buildStarView()
	{
		var starContainer = new Sprite(this);
		starContainer.setScale(.7);

		if (starCount < 1)
		{
			leftStarInactive = new Bitmap(Res.image.common.ui.stars_left_inactive.toTile(), starContainer);
			leftStarInactive.smooth = true;
			leftStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		}
		else
		{
			leftStar = new Bitmap(Res.image.common.ui.stars_left.toTile(), starContainer);
			leftStar.smooth = true;
			leftStar.setScale(AppConfig.GAME_BITMAP_SCALE);
		}

		if (starCount < 3)
		{
			rightStarInactive = new Bitmap(Res.image.common.ui.stars_right_inactive.toTile(), starContainer);
			rightStarInactive.smooth = true;
			rightStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		}
		else
		{
			rightStar = new Bitmap(Res.image.common.ui.stars_right.toTile(), starContainer);
			rightStar.smooth = true;
			rightStar.setScale(AppConfig.GAME_BITMAP_SCALE);
		}

		if (starCount < 2)
		{
			middleStarInactive = new Bitmap(Res.image.common.ui.stars_middle_inactive.toTile(), starContainer);
			middleStarInactive.smooth = true;
			middleStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		}
		else
		{
			middleStar = new Bitmap(Res.image.common.ui.stars_middle.toTile(), starContainer);
			middleStar.smooth = true;
			middleStar.setScale(AppConfig.GAME_BITMAP_SCALE);
		}

		starContainer.x = -starContainer.getSize().width / 2;
		starContainer.y = 10;
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

		if (isLocked)
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
		if (isLocked) value = false;

		isEnabled = value;

		interactive.visible = isEnabled && !isLocked;
		label.visible = !isLocked;
		onOutHandler(null);

		return isEnabled;
	}
}