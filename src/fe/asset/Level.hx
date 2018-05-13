package fe.asset;

import fe.game.Elem.ElemType;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Level
{
	static var data:Array<LevelData> =
	[
		// LV 1 =====================================
		{
			maxMovement: 12,
			availableElemTypes: [
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11,
				ElemType.Elem12
			],
			rawMap: [
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				1000,
				2000,
				4000
			],
			elemGoals: [
				ElemType.Elem8 => 10,
				ElemType.Elem9 => 10,
				ElemType.Elem11 => 10,
			]
		},

		// LV 2 =====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem1,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11
			],
			rawMap: [
				[ -2, -2, -3, -3, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -3, -2, -2, -2, -2, -3 ],
				[ -3, -2, -2, -2, -2, -3 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -3, -3, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem1 => 10,
				ElemType.Elem8 => 10,
				ElemType.Elem11 => 10,
			]
		},

		// LV 3 =====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem1,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11,
				ElemType.Elem14
			],
			rawMap: [
				[  0, -2, -2, -2, -2,  0 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[  0, -2, -2, -2, -2,  0 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2 ],
				[  0, -2, -2, -2, -2,  0 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem1 => 10,
				ElemType.Elem10 => 10,
				ElemType.Elem14 => 10,
			]
		},

		// LV 4 =====================================
		{
			maxMovement: 10,
			availableElemTypes: [
				ElemType.Elem1,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11,
				ElemType.Elem14
			],
			rawMap: [
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2,  0, -2, -2, -2 ],
				[ -2, -2,  0, -3,  0, -2, -2 ],
				[ -2, -2,  0, -3,  0, -2, -2 ],
				[ -2, -2, -2,  0, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem8 => 6,
				ElemType.Elem9 => 6,
				ElemType.Elem11 => 6,
				ElemType.Elem14 => 6,
			]
		},

		// LV 5 =====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem2,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11
			],
			rawMap: [
				[ -2, -2, -2, -3, -2, -2, -2 ],
				[ -2, -3, -2, -2, -2, -3, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -3, -2, -2, -2, -3, -2 ],
				[ -2, -2, -2, -3, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem10 => 10,
				ElemType.Elem11 => 20,
			]
		},

		// LV 6 =====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem1,
				ElemType.Elem2,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11
			],
			rawMap: [
				[  0,  0, -2,  0,  0, -2,  0,  0 ],
				[  0, -2, -2, -2, -2, -2, -2,  0 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem2 => 15,
				ElemType.Elem8 => 6,
				ElemType.Elem9 => 6,
				ElemType.Elem10 => 20,
			]
		},

		// LV 7 =====================================
		{
			maxMovement: 10,
			availableElemTypes: [
				ElemType.Elem3,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11
			],
			rawMap: [
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -3, -3, -3, -3, -3, -3, -3, -3 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem3 => 10,
				ElemType.Elem8 => 15,
				ElemType.Elem11 => 10,
			]
		},

		// LV 8 =====================================
		{
			maxMovement: 22,
			availableElemTypes: [
				ElemType.Elem1,
				ElemType.Elem2,
				ElemType.Elem3,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem11
			],
			rawMap: [
				[ -2, -2, -2, -2, -2 ],
				[ -2, -3, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2 ],
				[ -2, -2, -3, -2, -2 ],
				[ -2, -2, -3, -2, -2 ],
				[ -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -3, -2 ],
				[ -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem1 => 10,
				ElemType.Elem2 => 10,
				ElemType.Elem3 => 10,
				ElemType.Elem8 => 6,
				ElemType.Elem11 => 6,
			]
		},

		// LV 9 =====================================
		{
			maxMovement: 25,
			availableElemTypes: [
				ElemType.Elem4,
				ElemType.Elem8,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11,
				ElemType.Elem14,
			],
			rawMap: [
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -3,  0, -2, -2, -2, -2,  0, -3 ],
				[ -3,  0, -2, -2, -2, -2,  0, -3 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem4 => 15,
				ElemType.Elem9 => 20,
				ElemType.Elem14 => 10,
			]
		},

		// LV 10 ====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem3,
				ElemType.Elem4,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem11
			],
			rawMap: [
				[ -2, -2, -2,  0, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2,  0, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2,  0, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2,  0, -2, -2, -2 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem3 => 15,
				ElemType.Elem4 => 15,
				ElemType.Elem9 => 15,
				ElemType.Elem10 => 15,
			]
		},

		// LV 11 ====================================
		{
			maxMovement: 15,
			availableElemTypes: [
				ElemType.Elem5,
				ElemType.Elem9,
				ElemType.Elem10,
				ElemType.Elem12,
				ElemType.Elem14
			],
			rawMap: [
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -3, -2, -2, -2, -2, -3, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -2, -3, -3, -2, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -2, -2, -3, -2, -2, -3, -2, -2 ],
				[ -2, -2, -2, -2, -2, -2, -2, -2 ],
				[ -3, -2, -2, -2, -2, -2, -2, -3 ]
			],
			starRequirements: [
				3000,
				5000,
				6000
			],
			elemGoals: [
				ElemType.Elem5 => 20,
				ElemType.Elem9 => 20,
				ElemType.Elem12 => 20,
			]
		}
	];

	public static function getLevelData(id:UInt):LevelData
	{
		if (id < data.length) return data[id];
		else return {
			maxMovement: 0,
			rawMap: [],
			availableElemTypes: [],
			starRequirements: []
		};
	}
}

typedef LevelData =
{
	var maxMovement:UInt;
	var rawMap:Array<Array<Int>>;
	var availableElemTypes:Array<ElemType>;
	var starRequirements:Array<UInt>;
	@:optional var elemGoals:Map<ElemType, UInt>;
}