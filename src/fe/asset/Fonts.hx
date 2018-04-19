package fe.asset;

import h2d.Font;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Fonts
{
	public static var DEFAULT_L(default, null):Font;
	public static var DEFAULT_M(default, null):Font;
	public static var DEFAULT_S(default, null):Font;

	public static function init()
	{
		DEFAULT_L  = Res.font.Cooper_Black_Regular.build(80);
		DEFAULT_M  = Res.font.Cooper_Black_Regular.build(25);
		DEFAULT_S  = Res.font.Cooper_Black_Regular.build(20);
	}
}