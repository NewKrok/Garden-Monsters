package test;

import haxe.io.Error;
import fe.game.Board;
import fe.game.Elem;
import fe.game.util.BoardHelper;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TestBoard
{
	static var testStartTime:Float;

	static public function test()
	{
		testStartTime = Date.now().getTime();

		testRandomPlayableMap();

		testNullMatch();
		testRowWithEmptyMatch();
		testRowMatchWithBlockerWithEmpty();
		testColMatchWithBlockerWithEmpty();
		testTripleRow();
		testTripleRowDoubleMatch();
		testSingleCol();
		testLongSingleCol();
		testLongSingleColDoubleMatch();
		testDoubleCol();
		testLongDoubleCol();
		testLongDoubleColDoubleMatch();
		testMatchWithEmpty();
		testMatchWithBlock();
		testMatchWithNone();
		testMatchWithNoneInTheCorner();

		testPossibilityColLeft();
		testPossibilityColLeftDouble();
		testPossibilityColLeftDoubleBack();
		testPossibilityColRight();
		testPossibilityRowDown();
		testPossibilityRowDownDouble();
		testPossibilityRowUp();
		testPossibilityFirstRowDown();
		testPossibilityLastRowUp();
		testPossibilityRowToRight();
		testPossibility3Possibility();
		testPossibility5Possibility();
		testPossibility9Possibility();
		testPossibilityWithFrozenElemRow();
		testPossibilityWithFrozenElemCol();

		testPossibilityRealMap();
		testPossibilityRealMap2();

		trace("Test finished! Time: " + (Date.now().getTime() - testStartTime) + "ms");
	}

	static private function testRandomPlayableMap()
	{
		var movePossibilities:UInt = 5;
		var availableElemTypes = [ElemType.Elem1, ElemType.Elem2, ElemType.Elem3, ElemType.Elem4, ElemType.Elem5, ElemType.Elem6, ElemType.Elem7];

		for (i in 0...100)
		{
			var map = BoardHelper.createRandomPlayableMap(10, 12, movePossibilities, 5, availableElemTypes);
			var mapData = BoardHelper.analyzeMap(map);
			if (mapData.matches.length > 0 || mapData.movePossibilities.length < movePossibilities)
			{
				trace("Generate random playable map failed");
				trace("Generated move possibilities: " + mapData.movePossibilities.length);
				trace("Generated matches: " + mapData.matches.length);

				throw "Failed test!";
			}
		}
	}

	static function testNullMatch()
	{
		var map = BoardHelper.createMap([
			[ 4, 	4, 		4 ],
			[ 1, 	2, 		null ],
			[ 3, 	2, 		null ],
			[ 1, 	2, 		null ],
			[ null, null, 	null ]
		]);

		var expected = [
			[ map[0][0], map[0][1], map[0][2] ],
			[ map[1][1], map[2][1], map[3][1] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testRowWithEmptyMatch()
	{
		var map = BoardHelper.createMap([
			[ 2, 2, 3, -1, -1, -1, 7, 3 ],
			[ 1, 5, 5,  5, -1,  1, 1, 2 ],
			[ 5, 6, 5,  2, -1,  3, 7, 7 ],
		]);

		var expected = [
			[ map[1][1], map[1][2], map[1][3] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testRowMatchWithBlockerWithEmpty()
	{
		var map = BoardHelper.createMap([
			[ 0,  0, 1, 2, 0 ],
			[ 6, -1, 6, 6, 4 ],
			[ 4,  7, 1, 1, 3 ],
		]);

		var expected = [
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testColMatchWithBlockerWithEmpty()
	{
		var map = BoardHelper.createMap([
			[ 5,  1,  4 ],
			[ 5,  4,  2 ],
			[ 4,  4,  6 ],
			[ 2,  0,  0 ],
			[ 7,  0,  0 ],
			[ 5, -1, -1 ]
		]);

		var expected = [
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testTripleRow()
	{
		var map = BoardHelper.createMap([
			[ 6, 6, 6, 1, 1 ],
			[ 1, 6, 6, 6, 6 ],
			[ 2, 3, 3, 3, 2 ]
		]);

		var expected = [
			[ map[0][0], map[0][1], map[0][2] ],
			[ map[1][1], map[1][2], map[1][3], map[1][4] ],
			[ map[2][1], map[2][2], map[2][3] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testTripleRowDoubleMatch()
	{
		var map = BoardHelper.createMap([
			[ 6, 6, 6, 1, 1, 1 ],
			[ 1, 6, 6, 6, 6, 1 ],
			[ 2, 3, 3, 3, 2, 1 ]
		]);

		var expected = [
			[ map[0][0], map[0][1], map[0][2] ],
			[ map[0][3], map[0][4], map[0][5], map[1][5], map[2][5] ],
			[ map[1][1], map[1][2], map[1][3], map[1][4] ],
			[ map[2][1], map[2][2], map[2][3] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testSingleCol()
	{
		var map = BoardHelper.createMap([
			[ 6 ],
			[ 6 ],
			[ 1 ],
			[ 1 ],
			[ 1 ]
		]);

		var expected = [
			[ map[2][0], map[3][0], map[4][0] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testLongSingleCol()
	{
		var map = BoardHelper.createMap([
			[ 6 ],
			[ 6 ],
			[ 1 ],
			[ 6 ],
			[ 6 ],
			[ 6 ]
		]);

		var expected = [
			[ map[3][0], map[4][0], map[5][0] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testLongSingleColDoubleMatch()
	{
		var map = BoardHelper.createMap([
			[ 6 ],
			[ 6 ],
			[ 6 ],
			[ 1 ],
			[ 1 ],
			[ 1 ],
			[ 1 ]
		]);

		var expected = [
			[ map[0][0], map[1][0], map[2][0] ],
			[ map[3][0], map[4][0], map[5][0], map[6][0] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testDoubleCol()
	{
		var map = BoardHelper.createMap([
			[ 3, 6 ],
			[ 3, 6 ],
			[ 3, 6 ],
			[ 3, 6 ],
			[ 3, 6 ]
		]);

		var expected = [
			[ map[0][0], map[1][0], map[2][0], map[3][0], map[4][0] ],
			[ map[0][1], map[1][1], map[2][1], map[3][1], map[4][1] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testLongDoubleCol()
	{
		var map = BoardHelper.createMap([
			[ 3, 1 ],
			[ 1, 6 ],
			[ 6, 6 ],
			[ 3, 6 ],
			[ 3, 6 ],
			[ 1, 1 ]
		]);

		var expected = [
			[ map[1][1], map[2][1], map[3][1], map[4][1] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testLongDoubleColDoubleMatch()
	{
		var map = BoardHelper.createMap([
			[ 3, 1 ],
			[ 3, 6 ],
			[ 3, 6 ],
			[ 4, 6 ],
			[ 4, 6 ],
			[ 4, 1 ]
		]);

		var expected = [
			[ map[0][0], map[1][0], map[2][0] ],
			[ map[3][0], map[4][0], map[5][0] ],
			[ map[1][1], map[2][1], map[3][1], map[4][1] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testMatchWithEmpty()
	{
		var map = BoardHelper.createMap([
			[ 3,  1,  3 ],
			[ 2,  2,  2 ],
			[ 0,  4,  4 ],
			[ -1, 6,  6 ],
			[ -1, -1, 3 ],
			[ -1, 1,  2 ]
		]);

		var expected = [
			[ map[1][0], map[1][1], map[1][2] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testMatchWithBlock()
	{
		var map = BoardHelper.createMap([
			[ 3, 1, 3 ],
			[ 2, 2, 2 ],
			[ 0, 4, 4 ],
			[ 0, 6, 6 ],
			[ 0, 0, 0 ],
			[ 0, 1, 2 ]
		]);

		var expected = [
			[ map[1][0], map[1][1], map[1][2] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testMatchWithNone()
	{
		var map = BoardHelper.createMap([
			[  3,  3,  3, -3 ],
			[  2,  5,  4,  4 ],
			[  7,  4,  4,  5 ],
			[  7,  6,  4,  4 ],
			[  7,  5,  5, -3 ],
			[ -3,  1,  2,  2 ]
		]);

		var expected = [
			[ map[0][0], map[0][1], map[0][2] ],
			[ map[1][2], map[2][2], map[3][2] ],
			[ map[2][0], map[3][0], map[4][0] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static function testMatchWithNoneInTheCorner()
	{
		var map = BoardHelper.createMap([
			[ -3, -3, 2, 4, 7, 6, 2, 7, -3, -3 ],
			[ -3,  1, 5, 3, 1, 5, 3, 3,  1, -3 ],
			[  1,  2, 5, 6, 4, 1, 5, 1,  4,  4 ],
			[  3,  5, 5, 1, 6, 1, 7, 2,  2,  3 ],
			[  3,  4, 1, 1, 2, 3, 5, 3,  7,  4 ],
			[  3,  4, 2, 5, 4, 3, 2, 3,  4,  5 ],
			[ -3,  4, 3, 1, 5, 2, 3, 6,  3, -3 ],
			[ -3, -3, 3, 4, 5, 6, 5, 1, -3, -3 ]
		]);

		var expected = [
			[ map[1][2], map[2][2], map[3][2] ],
			[ map[3][0], map[4][0], map[5][0] ],
			[ map[4][1], map[5][1], map[6][1] ]
		];

		if (!isEqual(BoardHelper.analyzeMap(map).matches, expected))
			throw "Failed test!";
	}

	static private function testPossibilityColLeft()
	{
		var map = BoardHelper.createMap([
			[ 4, 1, 5 ],
			[ 1, 4, 2 ],
			[ 4, 3, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityColLeftDouble()
	{
		var map = BoardHelper.createMap([
			[ 6, 1, 5 ],
			[ 6, 3, 2 ],
			[ 4, 6, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityColLeftDoubleBack()
	{
		var map = BoardHelper.createMap([
			[ 6, 1, 5 ],
			[ 3, 6, 2 ],
			[ 4, 6, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityColRight()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 5 ],
			[ 6, 1, 2 ],
			[ 3, 6, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityRowDown()
	{
		var map = BoardHelper.createMap([
			[ 6, 1, 6 ],
			[ 1, 6, 2 ],
			[ 5, 3, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityRowDownDouble()
	{
		var map = BoardHelper.createMap([
			[ 6, 6, 2 ],
			[ 1, 4, 6 ],
			[ 5, 3, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityRowUp()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3 ],
			[ 6, 2, 6 ],
			[ 5, 3, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityFirstRowDown()
	{
		var map = BoardHelper.createMap([
			[ 6, 2, 3 ],
			[ 1, 6, 6 ],
			[ 5, 3, 2 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityLastRowUp()
	{
		var map = BoardHelper.createMap([
			[ 1, 2, 3 ],
			[ 6, 6, 2 ],
			[ 5, 3, 6 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibilityRowToRight()
	{
		var map = BoardHelper.createMap([
			[ 1, 2, 3, 1 ],
			[ 6, 4, 6, 6 ],
			[ 5, 3, 1, 4 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static private function testPossibility3Possibility()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3, 6 ],
			[ 6, 2, 6, 2 ],
			[ 5, 3, 2, 3 ]
		]);

		if (!checkPossibilities(map, 3))
			throw "Failed test!";
	}

	static private function testPossibility5Possibility()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3, 6 ],
			[ 6, 2, 6, 2 ],
			[ 5, 3, 2, 7 ],
			[ 7, 4, 2, 3 ]
		]);

		if (!checkPossibilities(map, 5))
			throw "Failed test!";
	}

	static private function testPossibility9Possibility()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3, 6, 5 ],
			[ 6, 2, 6, 2, 5 ],
			[ 6, 3, 2, 5, 7 ],
			[ 7, 2, 2, 3, 5 ],
			[ 4, 7, 7, 3, 5 ]
		]);

		if (!checkPossibilities(map, 9))
			throw "Failed test!";
	}

	static private function testPossibilityWithFrozenElemRow()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3, 6 ],
			[ 6, 2, 6, 2 ],
			[ 5, 3, 2, 3 ]
		]);

		map[0][1].frozenTurnCount = 1;

		if (!checkPossibilities(map, 2))
			throw "Failed test!";
	}

	static private function testPossibilityWithFrozenElemCol()
	{
		var map = BoardHelper.createMap([
			[ 1, 6, 3, 6 ],
			[ 6, 2, 4, 2 ],
			[ 5, 6, 1, 3 ]
		]);

		map[1][0].frozenTurnCount = 1;

		if (!checkPossibilities(map, 0))
			throw "Failed test!";
	}

	static private function testPossibilityRealMap()
	{
		var map = BoardHelper.createMap([
			[ -3, -3, 12,  9,  9, 11, -3, -3],
			[ -3, 11, 13, 13, 11, 12, 13, -3],
			[  8, 10, 12, 13, 13, 10, 13, 13],
			[ 11,  8, 12,  0,  0,  9,  8,  9],
			[ 12,  9, 11,  0,  0,  8, 11, 12],
			[ 11,  9, 10, 12, 11, 12, 12, 10],
			[ -3, 12, 11, 13, 12, 11,  8, -3],
			[ -3, -3, 13, 12, 11, 13, -3, -3],
		]);

		if (!checkPossibilities(map, 8))
			throw "Failed test!";
	}

	static private function testPossibilityRealMap2()
	{
		var map = BoardHelper.createMap([
			[ -3, -3, 11, 13, 12, 11, -3, -3 ],
			[ -3, 13, 12, 10,  9, 10, 13, -3 ],
			[  8,  9,  9, 10, 12, 11, 10,  9 ],
			[ 10, 11, 10,  0,  0,  8, 12, 10 ],
			[ 12,  8, 12,  0,  0, 13,  9,  9 ],
			[ 11,  9, 13, 11,  9, 13, 10, 12 ],
			[ -3,  9,  8, 12, 13, 11, 12, -3 ],
			[ -3, -3, 11, 11, 10,  8, -3, -3 ]
		]);

		if (!checkPossibilities(map, 1))
			throw "Failed test!";
	}

	static function isEqual(mapA:Array<Array<Elem>>, mapB:Array<Array<Elem>>):Bool
	{
		if (mapA.length != mapB.length)
		{
			trace("Test failed, missing match count: " + mapA.length + " / " + mapB.length);
			for (i in 0...mapA.length - mapB.length) trace("Unexpected Match: " + mapA[i]);
			return false;
		}

		for (i in 0...mapA.length)
			for (j in 0...mapA[i].length)
				if (mapA[i].length != mapB[i].length || mapA[i][j] != mapB[i][j])
				{
					trace("Test failed, index: " + i + " / " + j);
					trace("Result (length:" + mapA.length + "):", mapA[i]);
					trace("Expected (length:" + mapB.length + "):", mapB[i]);
					return false;
				}

		return true;
	}

	static function checkPossibilities(map:Array<Array<Elem>>, expected:UInt):Bool
	{
		var possbilities = BoardHelper.analyzeMap(map).movePossibilities;

		if (possbilities.length != expected)
		{
			trace("Test failed, possibilities: " + possbilities.length + " / " + expected);
			trace("Found possibilities:", possbilities);

			return false;
		}

		return true;
	}
}