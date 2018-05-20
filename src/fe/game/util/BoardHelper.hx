package fe.game.util;

import fe.game.Board.Map;
import hpp.util.GeomUtil.SimplePoint;
import fe.game.Elem;

using hpp.util.ArrayUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BoardHelper
{
	static var matchTemplate:Array<MatchTemplate> = [
		{
			expected: [
				{ x: 0, y: -2 },
				{ x: 0, y: -3 }
			],
			matchBlockerPosition: [
				{ x: 0, y: -1 }
			],
		},
		{
			expected: [
				{ x: 0, y: 2 },
				{ x: 0, y: 3 }
			],
			matchBlockerPosition: [
				{ x: 0, y: 1 }
			],
		},
		{
			expected: [
				{ x: -3, y: 0 },
				{ x: -2, y: 0 }
			],
			matchBlockerPosition: [
				{ x: -1, y: 0 }
			],
		},
		{
			expected: [
				{ x: 2, y: 0 },
				{ x: 3, y: 0 }
			],
			matchBlockerPosition: [
				{ x: 1, y: 0 }
			],
		},
		{
			expected: [
				{ x: 1, y: -1 },
				{ x: 1, y: 1 }
			],
			matchBlockerPosition: [
				{ x: 1, y: 0 }
			],
		},
		{
			expected: [
				{ x: -1, y: -1 },
				{ x: -1, y: 1 }
			],
			matchBlockerPosition: [
				{ x: -1, y: 0 }
			],
		},
		{
			expected: [
				{ x: -1, y: -1 },
				{ x: 1, y: -1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: -1 }
			],
		},
		{
			expected: [
				{ x: -1, y: 1 },
				{ x: 1, y: 1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: 1 }
			],
		},
		{
			expected: [
				{ x: 1, y: -1 },
				{ x: 2, y: -1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: -1 }
			],
		},
		{
			expected: [
				{ x: -1, y: -1 },
				{ x: -2, y: -1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: -1 }
			],
		},
		{
			expected: [
				{ x: -1, y: 1 },
				{ x: -2, y: 1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: 1 }
			],
		},
		{
			expected: [
				{ x: 1, y: 1 },
				{ x: 2, y: 1 }
			],
			matchBlockerPosition: [
				{ x: 0, y: 1 }
			],
		},
		{
			expected: [
				{ x: -1, y: 1 },
				{ x: -1, y: 2 }
			],
			matchBlockerPosition: [
				{ x: -1, y: 0 }
			],
		},
		{
			expected: [
				{ x: -1, y: -1 },
				{ x: -1, y: -2 }
			],
			matchBlockerPosition: [
				{ x: -1, y: 0 }
			],
		},
		{
			expected: [
				{ x: 1, y: 1 },
				{ x: 1, y: 2 }
			],
			matchBlockerPosition: [
				{ x: 1, y: 0 }
			],
		},
		{
			expected: [
				{ x: 1, y: -1 },
				{ x: 1, y: -2 }
			],
			matchBlockerPosition: [
				{ x: 1, y: 0 }
			],
		}
	];

	public static function createMap(rawMap:Array<Array<Int>>, availableElemTypes:Array<ElemType> = null):Map
	{
		var map:Map = [];
		availableElemTypes = availableElemTypes == null ? [] : availableElemTypes;

		for (i in 0...rawMap.length)
		{
			map.push([]);
			for (j in 0...rawMap[0].length)
				if (rawMap[i][j] == null) map[i].push(null);
				else
				{
					var type:ElemType = cast rawMap[i][j];
					map[i].push(
						type == ElemType.Random
							? createRandomElem(i, j, availableElemTypes)
							: new Elem(i, j, type)
					);
				}
		}

		return map;
	}

	public static function createRandomPlayableMap(
		col:UInt,
		row:UInt,
		minimumStartPossiblities:UInt = 2,
		blockCount:UInt = 0,
		availableElemTypes:Array<ElemType>
	):Map
	{
		var maxTry:UInt = 300;

		var map = createRandomMap(col, row, blockCount, availableElemTypes);
		var mapData = BoardHelper.analyzeMap(map);
		var tryCount = 0;

		while (
			(mapData.matches.length != 0
			|| mapData.movePossibilities.length < minimumStartPossiblities)
			&& tryCount++ < maxTry
		){
			map = createRandomMap(col, row, blockCount, availableElemTypes);
			mapData = BoardHelper.analyzeMap(map);
		}

		if (tryCount == maxTry) map = null;

		return map;
	}

	public static function createRandomMap(col:UInt, row:UInt, blockCount:UInt = 0, availableElemTypes:Array<ElemType>):Map
	{
		var map:Map = [];

		for (i in 0...row)
		{
			map.push([]);
			for (j in 0...col) map[i].push(createRandomElem(i, j, availableElemTypes));
		}

		for (i in 0...blockCount)
			map[Math.floor(Math.random() * map.length)][Math.floor(Math.random() * map[0].length)].type = ElemType.Blocker;

		return map;
	}

	public static function createRandomElem(row:UInt, col:UInt, availableElemTypes:Array<ElemType>):Elem
	{
		return new Elem(row, col, createRandomElemType(availableElemTypes));
	}

	public static function createRandomElemType(availableElemTypes:Array<ElemType>):ElemType
	{
		return availableElemTypes[Math.floor(Math.random() * availableElemTypes.length)];
	}

	public static function analyzeMap(map:Map):MapData
	{
		return {
			movePossibilities: calculateMovePossibilities(map),
			matches: detectMatch(map)
		}
	}

	public static function detectMatch(map:Map):Array<Array<Elem>>
	{
		var foundMatch:Array<Array<Elem>> = [];

		var allFounds:Array<Array<Elem>> = [];
		var colBaseType:Array<ElemType> = [];
		var sameElemsInCol:Array<Array<Elem>> = [];
		var rowIndex:UInt = 0;

		for (row in map)
		{
			sameElemsInCol.push([]);

			var rowBaseType:ElemType = ElemType.Empty;
			var sameElemsInRow:Array<Elem> = [];

			var colIndex:UInt = 0;
			for (elem in row)
			{
				var elemType:ElemType = elem == null ? ElemType.Empty : elem.type;

				if (rowIndex == 0)
				{
					colBaseType.push(ElemType.Empty);
					sameElemsInCol.push([]);
				}

				if (colBaseType[colIndex] == ElemType.Empty)
				{
					colBaseType[colIndex] = elemType;
					sameElemsInCol[colIndex] = [];
				}

				if (isMovableElem(elem) && colBaseType[colIndex] == elemType)
				{
					sameElemsInCol[colIndex].push(elem);

					if (sameElemsInCol[colIndex].length > 2 && rowIndex == map.length - 1)
						allFounds.push(sameElemsInCol[colIndex].copy());
				}
				else if (sameElemsInCol[colIndex].length > 2)
				{
					allFounds.push(sameElemsInCol[colIndex].copy());
					colBaseType[colIndex] = elemType;
					sameElemsInCol[colIndex] = [elem];
				}
				else if (isMovableElem(elem))
				{
					colBaseType[colIndex] = elemType;
					sameElemsInCol[colIndex] = [elem];
				}
				else sameElemsInCol[colIndex] = [];

				if (rowBaseType == ElemType.Empty)
				{
					rowBaseType = elemType;
					sameElemsInRow = [];
				}

				if (isMovableElem(elem) && rowBaseType == elemType)
				{
					sameElemsInRow.push(elem);

					if (sameElemsInRow.length > 2 && colIndex == row.length - 1)
						allFounds.push(sameElemsInRow.copy());
				}
				else if (sameElemsInRow.length > 2)
				{
					allFounds.push(sameElemsInRow.copy());
					rowBaseType = elemType;
					sameElemsInRow = [elem];
				}
				else if (isMovableElem(elem))
				{
					rowBaseType = elemType;
					sameElemsInRow = [elem];
				}
				else sameElemsInRow = [];

				colIndex++;
			}
			rowIndex++;
		}

		for (found in allFounds)
		{
			var concatedElems:Array<Elem> = found.copy();

			for (elem in found)
			{
				for (secondFound in allFounds)
				{
					if (found != secondFound)
					{
						for (secondElem in secondFound)
						{
							if (elem == secondElem)
							{
								concatedElems = concatedElems.concat(secondFound);

								concatedElems.remove(secondElem);
								allFounds.remove(secondFound);
								break;
							}
						}
					}
				}
			}

			foundMatch.push(concatedElems);
		}

		return foundMatch;
	}

	static function calculateMovePossibilities(map:Map):Array<Elem>
	{
		var possibilities:Array<Elem> = [];

		for (i in 0...map.length)
		{
			for (j in 0...map[0].length)
			{
				if (isMovableElem(map[i][j]) && !map[i][j].isFrozen)
				{
					var type:ElemType = map[i][j].type;
					if (checkElemPossibilities(map, i, j, type)) possibilities.push(map[i][j]);
				}
			}
		}

		return possibilities;
	}

	static function checkElemPossibilities(map:Map, x:UInt, y:UInt, type:ElemType):Bool
	{
		if (!isMovableType(type)) return false;

		for (t in matchTemplate)
		{
			var match:Bool = true;
			for (o in t.expected)
				if (map[cast x + o.x] == null
					|| map[cast x + o.x][cast y + o.y] == null
					|| map[cast x + o.x][cast y + o.y].type != cast type
				) match = false;

			for (o in t.matchBlockerPosition)
				if (map[cast x + o.x] == null
					|| map[cast x + o.x][cast y + o.y] == null
					|| map[cast x + o.x][cast y + o.y].type == ElemType.Blocker
					|| map[cast x + o.x][cast y + o.y].type == ElemType.Empty
					|| map[cast x + o.x][cast y + o.y].type == ElemType.None
				) match = false;

			if (match) return true;
		}

		return false;
	}

	static public function isMovableElem(elem:Elem):Bool
	{
		return elem != null && elem.type != ElemType.Empty && elem.type != ElemType.Blocker && elem.type != ElemType.None;
	}

	static public function isMovableType(type:ElemType):Bool
	{
		return type != ElemType.Empty && type != ElemType.Blocker && type != ElemType.None;
	}

	static public function isFruitElem(elem:Elem):Bool
	{
		return elem != null && elem.type.toInt() > 7;
	}

	static public function getRandomPlayableElem(map:Map):Elem
	{
		var possibleElems:Array<Elem> = [];

		for (row in map)
			for (e in row)
				if (
					e != null
					&& e.type != ElemType.Blocker
					&& e.type != ElemType.Empty
					&& e.type != ElemType.None
				) possibleElems.push(e);

		return possibleElems.random();
	}

	static public function getMonsters(map:Map):Array<Elem>
	{
		var possibleElems:Array<Elem> = [];

		for (row in map)
			for (e in row)
				if (
					e != null
					&& e.type.toInt() > 0
					&& e.type.toInt() < 8
				) possibleElems.push(e);

		return possibleElems;
	}

	static public function getFruits(map:Map):Array<Elem>
	{
		var possibleElems:Array<Elem> = [];

		for (row in map)
			for (e in row)
				if (
					e != null
					&& e.type.toInt() > 7
				) possibleElems.push(e);

		return possibleElems;
	}
}

typedef MapData = {
	var matches:Array<Array<Elem>>;
	var movePossibilities:Array<Elem>;
}

typedef MatchTemplate = {
	var expected:Array<SimplePoint>;
	var matchBlockerPosition:Array<SimplePoint>;
}