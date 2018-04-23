package fe.game.ui;

import h2d.Bitmap;
import h2d.Layers;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarsUI extends Layers
{
	var starGraphics:Array<Bitmap>;

	public function new(parent, stars:Observable<UInt>)
	{
		super(parent);

		starGraphics = [];

		for (i in 0...3)
		{
			var stars = new Bitmap(
				i == 0 ? Res.image.game.ui.ingame_stars_1.toTile() :
					i == 1 ? Res.image.game.ui.ingame_stars_2.toTile() :
						i == 2 ? Res.image.game.ui.ingame_stars_3.toTile() : null,
				this
			);
			stars.smooth = true;
			stars.setScale(AppConfig.GAME_BITMAP_SCALE);

			starGraphics.push(stars);
		}

		stars.bind(function(v) {
			for (i in 0...starGraphics.length)
			{
				if (v == i + 1)
				{
					if (!starGraphics[i].visible) starGraphics[i].visible = true;
				}
				else starGraphics[i].visible = false;
			}
		});
	}
}