package fe.game;

import fe.asset.ElemTile;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Elem
{
	public static var SIZE(default, null):UInt = 90;

	public var hasMouseHover(default, set):Bool = false;

	public var indexX:UInt;
	public var indexY:UInt;
	public var x:Float;
	public var y:Float;
	public var animationX:Float;
	public var animationY:Float;
	public var rotation:Float;
	public var type(default, set):ElemType;
	public var isUnderSwapping:Bool;
	public var graphic:ElemGraphic;

	public function new(row:UInt, col:UInt, type:ElemType = ElemType.Random)
	{
		indexX = col;
		indexY = row;
		x = col * SIZE;
		y = row * SIZE;
		animationX = x;
		animationY = y;
		rotation = 0;
		isUnderSwapping = false;

		graphic = new ElemGraphic();

		this.type = type == ElemType.Random ? cast(1 + Math.floor(Math.random() * 7)) : type;

		graphic.x = x;
		graphic.y = y;

		if (type == ElemType.Empty) graphic.visible = false;
	}

	function set_type(v:ElemType):ElemType
	{
		type = v;

		if (type == ElemType.Empty || type == null) graphic.setTile(ElemTile.emptyElemGraphic);
		else graphic.setTile(ElemTile.tiles.get(cast type));

		if (type == ElemType.Empty) graphic.visible = false;

		return v;
	}

	function set_hasMouseHover(value:Bool):Bool
	{
		graphic.hasMouseHover = value;

		return hasMouseHover = value;
	}
}

@:enum abstract ElemType(Int)
{
	var Random = -2;
	var Empty = -1;
	var Blocker = 0;
}