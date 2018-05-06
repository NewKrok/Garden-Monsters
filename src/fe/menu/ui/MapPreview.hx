package fe.menu.ui;

import h2d.Bitmap;
import h2d.Graphics;
import h2d.Sprite;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MapPreview extends Sprite
{
	static inline var blockSize:UInt = 26;
	static inline var blockGap:UInt = 3;

	var selectedRawMap:Observable<Array<Array<Int>>>;
	var back:Bitmap;

	public function new(
		p:Sprite,
		selectedRawMap:Observable<Array<Array<Int>>>
	){
		super(p);

		this.selectedRawMap = selectedRawMap;

		back = new Bitmap(Res.image.menu.ui.preview_back.toTile(), this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		updateView();
	}

	// TODO: why the blocks dispose after close substate???
	public function updateView()
	{
		var blocks = new Graphics(this);

		for (i in 0...selectedRawMap.value.length)
			for (j in 0...selectedRawMap.value[i].length)
			{
				var e = selectedRawMap.value[i][j];
				if (e == -3 || e == -2 || e == 0)
				{
					blocks.beginFill(e == 0 ? 0xFF0000 : 0x000000, e == -3 ? .1 : e == -2 ? .5 : .8);
					blocks.drawRect(
						j * blockSize + j * blockGap,
						i * blockSize + i * blockGap,
						blockSize,
						blockSize
					);
					blocks.endFill();
				}
			}

		blocks.x = back.getSize().width / 2 - blocks.getSize().width / 2;
		blocks.y = back.getSize().height / 2 - blocks.getSize().height / 2;
	}
}