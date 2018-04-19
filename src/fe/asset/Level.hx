package fe.asset;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Level
{
	static var data:Array<LevelData> =
	[
		{
			maxMovement: 20,
			rawMap: [
				[ -3, -3, -2, -2, -2, -2, -3, -3 ],
				[ -3, -2, -2, -2, -2, -2, -2, -3 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -3, -2, -2, -2, -2, -2, -2, -3 ],
				[ -3, -3, -2, -2, -2, -2, -3, -3 ]
			]
		}
	];

	public static function getLevelData(id:UInt):LevelData
	{
		return data[id];
	}
}

typedef LevelData =
{
	var maxMovement:UInt;
	var rawMap:Array<Array<Int>>;
}