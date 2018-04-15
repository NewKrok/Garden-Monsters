package fe.game.util;

import fe.TweenConfig;
import fe.game.Elem;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TweenHelper
{
	public static function getElemTweenSpeedByDistance(d:Float):Float
	{
		return d / Elem.SIZE * TweenConfig.ELEM_FALL_TIME;
	}
}