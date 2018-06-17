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
				musicVolume: 1,
				lang: "en"
			},
			levelInfos:
			[{
				id: 0,
				isEnabled: true,
				isCompleted: false,
				score: 0
			}]
		};
	}
}

typedef SavedData =
{
	var applicationInfo:ApplicationInfo;
	var levelInfos:Array<LevelInfo>;
}

typedef ApplicationInfo =
{
	var soundVolume:Float;
	var musicVolume:Float;
	var lang:String;
}

typedef LevelInfo =
{
	var id:UInt;
	var isEnabled:Bool;
	var isCompleted:Bool;
	var score:UInt;
}