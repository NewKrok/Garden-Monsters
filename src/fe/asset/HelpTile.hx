package fe.asset;

import fe.game.Help.HelpType;
import h2d.Tile;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpTile
{
	public static var tiles(default, null):Map<HelpType, Tile>;

	static public function init()
	{
		tiles = [
			HelpType.BOMB => Res.image.common.help.bomb.toTile(),
			HelpType.APPLE_JUICE => Res.image.common.help.apple_juice.toTile(),
			HelpType.HOT_PEPPER => Res.image.common.help.hot_pepper.toTile(),
			HelpType.DICE => Res.image.common.help.dice.toTile(),
			HelpType.FRUIT_BOX => Res.image.common.help.fruit_box.toTile()
		];
	}
}