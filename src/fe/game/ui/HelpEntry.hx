package fe.game.ui;

import fe.asset.ElemTile;
import fe.asset.Fonts;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import h2d.Tile;
import h2d.filter.ColorMatrix;
import h3d.Matrix;
import hpp.heaps.ui.BaseButton;
import hpp.util.Language;
import hxd.Cursor;
import hxd.Res;
import motion.Actuate;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpEntry extends Layers
{
	var counter:Text;
	var isChangedToDone:Bool;
	var infoBack:Bitmap;
	var elem:Bitmap;
	var interactive:Interactive;
	var isPossibleToPlay:Observable<Bool>;
	var availableCount:Observable<UInt>;

	public function new(parent:Sprite, isPossibleToPlay:Observable<Bool>, tile:Tile, availableCount:Observable<UInt>, activateHelp:Void->Void)
	{
		super(parent);
		this.isPossibleToPlay = isPossibleToPlay;
		this.availableCount = availableCount;

		elem = makeGraphic(tile.clone());
		elem.setScale(AppConfig.GAME_BITMAP_SCALE);
		elem.y = 30;

		infoBack = new Bitmap(Res.image.common.ui.help_counter.toTile(), this);
		infoBack.smooth = true;
		infoBack.setScale(AppConfig.GAME_BITMAP_SCALE);

		elem.x = -infoBack.getSize().width + 65;
		elem.y = 60;

		counter = new Text(Fonts.DEFAULT_XL, this);
		counter.smooth = true;
		counter.text = Std.string(availableCount.value);
		counter.textColor = 0xFFFFFF;
		counter.textAlign = Align.Center;
		counter.x = infoBack.getSize().width / 2 + 2;
		counter.y = 0;

		availableCount.bind(function(c:UInt)
		{
			counter.text = '$c';

			if (c == 0)
			{
				infoBack.alpha = 0;
				counter.alpha = 0;

				interactive.cursor = Cursor.Default;

				var m = new Matrix();
				m.identity();
				m.colorSaturation(-1);
				filter = new ColorMatrix(m);

				alpha = .5;
			}
		});

		interactive = new Interactive(tile.width * AppConfig.GAME_BITMAP_SCALE, tile.height * AppConfig.GAME_BITMAP_SCALE, this);
		interactive.cursor = Cursor.Button;
		interactive.onClick = function(_) {
			if (availableCount.value > 0 && isPossibleToPlay.value)
			{
				onOutHandler(null);
				activateHelp();
			}
		};
		interactive.onOver = onOverHandler;
		interactive.onOut = onOutHandler;
		interactive.x = -80;
		interactive.y = -80;

		isPossibleToPlay.bind(function(v:Bool)
		{
			if (v) interactive.cursor = Cursor.Button;
			else interactive.cursor = Cursor.Default;
		});
	}

	function onOverHandler(_)
	{
		if (availableCount.value == 0 || !isPossibleToPlay.value) return;

		Actuate.stop(elem);

		Actuate.tween(elem, .4, {
			scaleX: AppConfig.GAME_BITMAP_SCALE + .1,
			scaleY: AppConfig.GAME_BITMAP_SCALE + .1,
			rotation: Math.random() * Math.PI / 30
		}).onUpdate(function() {
			elem.x = elem.x;
		});
	}

	function onOutHandler(_)
	{
		Actuate.stop(elem);

		Actuate.tween(elem, .4, {
			scaleX: AppConfig.GAME_BITMAP_SCALE,
			scaleY: AppConfig.GAME_BITMAP_SCALE,
			rotation: 0
		}).onUpdate(function() {
			elem.x = elem.x;
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