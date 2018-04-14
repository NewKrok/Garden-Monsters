package fe.game;

import fe.asset.ElemTile;
import hpp.util.GeomUtil.SimplePoint;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Elem
{
	public static var SIZE(default, null):UInt = 105;

	public var hasMouseHover(default, set):Bool = false;
	public var isFrozen(get, null):Bool;
	public var frozenTurnCount(default, set):UInt = 0;
	public var id(default, null):UInt = Math.floor(Math.random() * 99999);

	public var indexX:UInt;
	public var indexY:UInt;
	public var animationX:Float;
	public var animationY:Float;
	public var rotation:Float;
	public var type(default, set):ElemType;
	public var isUnderSwapping:Bool;
	public var graphic:ElemGraphic;
	public var animationPath:Array<SimplePoint>;

	public function new(row:UInt, col:UInt, type:ElemType = ElemType.Random)
	{
		indexX = col;
		indexY = row;
		animationX = col * SIZE;
		animationY = row * SIZE;
		rotation = 0;
		isUnderSwapping = false;

		animationPath = [];

		graphic = new ElemGraphic();

		this.type = type;

		graphic.x = animationX;
		graphic.y = animationY;
	}

	public function clone()
	{
		return new Elem(indexY, indexX, type);
	}

	function set_type(v:ElemType):ElemType
	{
		if (type == v) return v;

		if (v == ElemType.Random)
		{
			v = cast(1 + Math.floor(Math.random() * 7));
			while(v == type) v = cast(1 + Math.floor(Math.random() * 7));
		}
		type = v;

		if (type == ElemType.Empty || type == ElemType.None || type == null) graphic.setTile(ElemTile.emptyElemGraphic);
		else graphic.setTile(ElemTile.tiles.get(cast type));

		switch (type)
		{
			case ElemType.Empty: graphic.visible = false;
			case ElemType.None: graphic.visible = false;
			case _:
		}

		return v;
	}

	function set_hasMouseHover(value:Bool):Bool
	{
		graphic.hasMouseHover = value;

		return hasMouseHover = value;
	}

	function set_frozenTurnCount(value:UInt):UInt
	{
		if (value == 0 && graphic.isFrozen) graphic.isFrozen = false;
		else if (value > 0 && !graphic.isFrozen) graphic.isFrozen = true;

		return frozenTurnCount = value;
	}

	function get_isFrozen():Bool
	{
		return frozenTurnCount > 0;
	}
}

@:enum abstract ElemType(Int)
{
	var None = -3;
	var Random = -2;
	var Empty = -1;
	var Blocker = 0;

	var Elem1 = 1;
	var Elem2 = 2;
	var Elem3 = 3;
	var Elem4 = 4;
	var Elem5 = 5;
	var Elem6 = 6;
	var Elem7 = 7;
}

/* TEMPORARY INFO
-3	DONE Not playable block but it cant block the other elems
-2	DONE Random block between 1 - 7
-1	DONE Temporary empty block - Iterable can happen after match
 0	DONE Not playable block and it block the other elems
 1	DONE After match it removes 1 nearby element too
 2	DONE After match it freezes 1 nearby elems for one turn - cant move but can match
 3	DONE After match it changes to random type 1 nearby element
 4	After match it shifts to left and to right the elems - the left and the right elems dissapearing
 5	After match it removes the elem under it
 6	After match it removes the nearby similar type elems too
 7	After match it removes 1 random element too // IT SHOULD BE DIFFERENT
*/