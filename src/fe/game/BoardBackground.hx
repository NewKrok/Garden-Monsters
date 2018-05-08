package fe.game;

import fe.AppConfig;
import fe.game.Elem;
import fe.game.util.BoardHelper;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BoardBackground
{
	public function new(parent:Layers, map:Array<Array<Elem>>)
	{
		var tileA = Res.image.game.elem_background_a.toTile();
		var tileB = Res.image.game.elem_background_b.toTile();
		var frameTile = Res.image.game.elem_frame.toTile();
		var frameSize = (frameTile.width - tileA.width) / 2;

		var background = new Layers(parent);
		background.x = -Elem.SIZE / 2;
		background.y = -Elem.SIZE / 2;
		background.setScale(AppConfig.GAME_BITMAP_SCALE);

		var frame = new Graphics(background);
		var backgroundA = new Graphics(background);
		var backgroundB = new Graphics(background);

		for (i in 0...map[0].length)
			for (j in 0...map.length)
			{
				if (map[j][i] != null && map[j][i].type != ElemType.Blocker && map[j][i].type != ElemType.None && map[j][i].type != ElemType.Empty)
				{
					if ((i + j) % 2 == 1) backgroundA.drawTile(i * tileA.width, j * tileA.height, tileA);
					else backgroundB.drawTile(i * tileB.width, j * tileB.height, tileB);
				}

				var countOfEdge:UInt = 0;
				var isLeftEmpty:Bool = false;
				var isRightEmpty:Bool  = false;
				var isTopEmpty:Bool = false;
				var isBottomEmpty:Bool = false;

				if (BoardHelper.isMovableElem(map[j][i]))
				{
					if (i == 0 || j == 0 || i == map[0].length - 1 || j == map.length - 1)
					{
						isLeftEmpty = i == 0;
						isRightEmpty = i == map[0].length - 1;
						isTopEmpty = j == 0;
						isBottomEmpty = j == map.length - 1;
					}

					isLeftEmpty = isLeftEmpty || (i - 1 > -1 && !BoardHelper.isMovableElem(map[j][i - 1]));
					isRightEmpty = isRightEmpty || (i + 1 < map[0].length && !BoardHelper.isMovableElem(map[j][i + 1]));
					isTopEmpty = isTopEmpty || (j - 1 > -1 && !BoardHelper.isMovableElem(map[j - 1][i]));
					isBottomEmpty = isBottomEmpty || (j + 1 < map.length && !BoardHelper.isMovableElem(map[j + 1][i]));

					if (isLeftEmpty || isRightEmpty || isTopEmpty || isBottomEmpty)
						frame.drawTile(i * tileB.width - frameSize, j * tileB.height - frameSize, frameTile);
				}
			}
	}
}