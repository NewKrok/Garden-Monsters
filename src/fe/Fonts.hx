package fe;

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
	public static var DEFAULT_ES(default, null):Font;

	public static function init()
	{
		DEFAULT_L  = Res.font.EllipticaLight.build(18);
		DEFAULT_M  = Res.font.EllipticaLight.build(16);
		DEFAULT_S  = Res.font.EllipticaLight.build(13);
		DEFAULT_ES = Res.font.EllipticaLight.build(10);
	}
}