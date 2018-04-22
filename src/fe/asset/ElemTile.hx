package fe.asset;

import h2d.Tile;
import hxd.Res;
import fe.asset.ElemTile.MonsterTileInfo;
import fe.game.Elem;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ElemTile
{
	public static var tiles(default, null):Map<UInt, MonsterTileInfo>;
	public static var emptyElemGraphic(default, null):MonsterTileInfo;

	static public function init()
	{
		tiles = [
			0 => { baseTile: Res.image.game.block_base.toTile(), secondTile: Res.image.game.block_base.toTile() },
			1 => { baseTile: Res.image.game.elem.monster_1_base.toTile(), secondTile: Res.image.game.elem.monster_1_second.toTile() },
			2 => { baseTile: Res.image.game.elem.monster_2_base.toTile(), secondTile: Res.image.game.elem.monster_2_second.toTile() },
			3 => { baseTile: Res.image.game.elem.monster_3_base.toTile(), secondTile: Res.image.game.elem.monster_3_second.toTile() },
			4 => { baseTile: Res.image.game.elem.monster_4_base.toTile(), secondTile: Res.image.game.elem.monster_4_second.toTile() },
			5 => { baseTile: Res.image.game.elem.monster_5_base.toTile(), secondTile: Res.image.game.elem.monster_5_second.toTile() },
			6 => { baseTile: Res.image.game.elem.monster_6_base.toTile(), secondTile: Res.image.game.elem.monster_6_second.toTile() },
			7 => { baseTile: Res.image.game.elem.monster_7_base.toTile(), secondTile: Res.image.game.elem.monster_7_second.toTile() },
			8 => { baseTile: Res.image.game.elem.elem_8_base.toTile(), secondTile: Res.image.game.elem.elem_8_base.toTile() },
			9 => { baseTile: Res.image.game.elem.elem_9_base.toTile(), secondTile: Res.image.game.elem.elem_9_base.toTile() },
			10 => { baseTile: Res.image.game.elem.elem_10_base.toTile(), secondTile: Res.image.game.elem.elem_10_base.toTile() },
			11 => { baseTile: Res.image.game.elem.elem_11_base.toTile(), secondTile: Res.image.game.elem.elem_11_base.toTile() },
			12 => { baseTile: Res.image.game.elem.elem_12_base.toTile(), secondTile: Res.image.game.elem.elem_12_base.toTile() },
			13 => { baseTile: Res.image.game.elem.elem_13_base.toTile(), secondTile: Res.image.game.elem.elem_13_base.toTile() },
			14 => { baseTile: Res.image.game.elem.elem_14_base.toTile(), secondTile: Res.image.game.elem.elem_14_base.toTile() },
		];

		emptyElemGraphic = { baseTile: Tile.fromColor(0, cast Elem.SIZE, cast Elem.SIZE, 0), secondTile: Tile.fromColor(0, cast Elem.SIZE, cast Elem.SIZE, 0) };
	}
}

typedef MonsterTileInfo =
{
	var baseTile:Tile;
	var secondTile:Tile;
}