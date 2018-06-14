package fe.common;
import hxd.Save;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SaveUtil
{
	public static var data:SavedData;

	public static function load()
	{
		data = Save.load(getEmptyData(), AppConfig.APP_NAME);
	}

	public static function save()
	{
		Save.save(data, AppConfig.APP_NAME);
	}

	static function getEmptyData():SavedData
	{
		return
		{
			applicationInfo:
			{
				soundVolume: 1,
				musicVolume: 1
			}
		};
	}
}

typedef SavedData =
{
	var applicationInfo:ApplicationInfo;
}

typedef ApplicationInfo =
{
	var soundVolume:Float;
	var musicVolume:Float;
}