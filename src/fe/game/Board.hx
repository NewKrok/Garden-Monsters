package fe.game;

import fe.TweenConfig;
import fe.game.Elem.ElemType;
import fe.game.util.BoardHelper;
import fe.game.util.TweenHelper;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Layers;
import h2d.Mask;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Cursor;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import tink.state.Observable;

using hpp.util.ArrayUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Board
{
	static inline var maskOffset:UInt = 10;

	public var foundMatch:Array<Array<Elem>>;
	public var foundPossibilities:Array<Elem>;

	public var alreadyAnimatedElems:Array<Elem>;
	public var underAnimationElems:Array<Elem>;

	var map:Map;
	var availableElemTypes:Array<ElemType>;
	var parent:Layers;
	var interactiveArea:Interactive;
	var mask:Mask;
	var container:Layers;
	var selectedElemBackground:Bitmap;
	var effectHandler:EffectHandler;
	var skillHandler:SkillHandler;

	var isDragging:Bool = false;
	var isAnimationInProgress:Bool = false;
	var isShuffleInProgress:Bool = false;
	var crossFillFromLeft:Bool = true;
	var dragDirection:DragDirection;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };
	var draggedElement:Elem;
	var focusElement:Elem;
	var isPossibleToPlay:Observable<Bool>;

	var showHelpTimer:Dynamic;

	var onSwapRequestCallback:Void->Void = function(){};
	var onFailedSwapCallback:Void->Void = function(){};
	var onSuccessfulSwapCallback:Void->Void = function(){};
	var onTurnEndCallback:Void->Void = function(){};
	var onElemCollectCallback:ElemType->Void = function(_){};
	var onNoMoreMovesCallback:Void->Void = function(){};

	public function new(
		parent:Layers,
		interactiveArea:Interactive,
		effectHandler:EffectHandler,
		skillHandler:SkillHandler,
		availableElemTypes:Array<ElemType>,
		isPossibleToPlay:Observable<Bool>,
		map:Map
	){
		this.parent = parent;
		this.interactiveArea = interactiveArea;
		this.effectHandler = effectHandler;
		this.skillHandler = skillHandler;
		this.availableElemTypes = availableElemTypes;
		this.isPossibleToPlay = isPossibleToPlay;
		this.map = map;

		mask = new Mask(100, 100, parent);

		container = new Layers(mask);
		container.setPos(Elem.SIZE / 2 + maskOffset, Elem.SIZE / 2 + maskOffset);
		effectHandler.view.setPos(Elem.SIZE / 2, Elem.SIZE / 2);

		skillHandler.init(
			container,
			availableElemTypes,
			effectHandler,
			map,
			function(e) { moveElemToPosition(e); },
			function(t) { onElemCollectCallback(t); }
		);

		new BoardBackground(container, map);

		selectedElemBackground = new Bitmap(Res.image.game.elem_selected.toTile(), container);
		selectedElemBackground.setScale(AppConfig.GAME_BITMAP_SCALE);
		selectedElemBackground.tile.dx = cast -selectedElemBackground.tile.width / 2;
		selectedElemBackground.tile.dy = cast -selectedElemBackground.tile.height / 2;
		selectedElemBackground.visible = false;

		addElemsToBoard();
		checkMap();
		removeAllMatch();

		mask.x = -maskOffset;
		mask.y = -maskOffset;
		mask.width = Std.int(container.getSize().width + maskOffset * 2);
		mask.height = Std.int(container.getSize().height + maskOffset * 2);

		createInteractive();

		isPossibleToPlay.bind(function(v){
			if (v)
			{
				if (showHelpTimer != null)
				{
					Actuate.stop(showHelpTimer, null, false, false);
					showHelpTimer = null;
				}

				if (foundPossibilities.length > 0)
					showHelpTimer = Actuate.timer(10).onComplete(function()
					{
						for (m in foundPossibilities) if (m != null) m.graphic.mark();
					});
			}
			else
			{
				Actuate.stop(showHelpTimer, null, false, false);
				showHelpTimer = null;

				if (foundPossibilities != null)
					for (m in foundPossibilities) if (m != null) m.graphic.unmark();
			}
		});
	}

	public function onTurnEnd(callback:Void->Void):Void onTurnEndCallback = callback;
	public function onSwapRequest(callback:Void->Void):Void onSwapRequestCallback = callback;
	public function onFailedSwap(callback:Void->Void):Void onFailedSwapCallback = callback;
	public function onSuccessfulSwap(callback:Void->Void):Void onSuccessfulSwapCallback = callback;
	public function onElemCollect(callback:ElemType->Void):Void onElemCollectCallback = callback;
	public function onNoMoreMoves(callback:Void->Void):Void onNoMoreMovesCallback = callback;

	function addElemsToBoard()
	{
		for (row in map) for (e in row) if (e != null) container.addChild(e.graphic);
	}

	function createInteractive()
	{
		isPossibleToPlay.bind(function(v){
			if (!v) interactiveArea.cursor = Cursor.Default;
		});

		interactiveArea.onPush = function(e:Event)
		{
			if (isShuffleInProgress || !isPossibleToPlay.value) return;

			draggedElement = getElemByPosition({
				x: e.relX,
				y: e.relY
			});

			if (draggedElement != null){
				isDragging = true;
				dragStartPoint.x = e.relX;
				dragStartPoint.y = e.relY;
			}
			else focusElement = null;
		};

		interactiveArea.onRelease = function(_)
		{
			if (isShuffleInProgress || !isPossibleToPlay.value) return;

			swapElemRequest();
		};

		interactiveArea.onMove = function(e:Event)
		{
			if (isShuffleInProgress || !isPossibleToPlay.value) return;

			if (isDragging)
			{
				var d:Float = GeomUtil.getDistance({ x: e.relX, y: e.relY }, dragStartPoint);

				if (d > 25)
				{
					var a:Float = GeomUtil.getAngle({ x: e.relX, y: e.relY }, dragStartPoint) * (180 / Math.PI);

					if ((a > 135 && a <= 180)
						|| (a > -180 && a <= -135)
					)
						dragDirection = DragDirection.Right;
					else if ((a > 0 && a <= 45)
						|| (a > -45 && a <= 0)
					)
						dragDirection = DragDirection.Left;
					else if (a > 45 && a <= 135)
						dragDirection = DragDirection.Up;
					else if (a > -135 && a <= -45)
						dragDirection = DragDirection.Down;

					swapElemRequest();
				} else dragDirection = DragDirection.None;
			}
			else if (!isAnimationInProgress)
			{
				selectedElemBackground.visible = false;

				if (focusElement != null)
				{
					focusElement.hasMouseHover = false;
				}

				focusElement = getElemByPosition({
					x: e.relX,
					y: e.relY
				});

				if (focusElement != null && !focusElement.isFrozen && focusElement.type != ElemType.Empty && focusElement.type != ElemType.None)
				{
					focusElement.hasMouseHover = true;
					selectedElemBackground.x = focusElement.graphic.x;
					selectedElemBackground.y = focusElement.graphic.y;
					selectedElemBackground.visible = true;
					interactiveArea.cursor = Cursor.Button;
				}
				else interactiveArea.cursor = Cursor.Default;
			}
			else selectedElemBackground.visible = false;
		};
	}

	function swapElemRequest():Void
	{
		isDragging = false;

		if (draggedElement != null && dragDirection != null)
		{
			switch(dragDirection)
			{
				case DragDirection.Right:
					swapElems(draggedElement.indexX, draggedElement.indexY, draggedElement.indexX + 1, draggedElement.indexY);

				case DragDirection.Left:
					swapElems(draggedElement.indexX, draggedElement.indexY, draggedElement.indexX - 1, draggedElement.indexY);

				case DragDirection.Up:
					swapElems(draggedElement.indexX, draggedElement.indexY, draggedElement.indexX, draggedElement.indexY - 1);

				case DragDirection.Down:
					swapElems(draggedElement.indexX, draggedElement.indexY, draggedElement.indexX, draggedElement.indexY + 1);

				case _:
			}

			dragDirection = DragDirection.None;
		}
	}

	function swapElems(indexX:UInt, indexY:UInt, targetIndexX:UInt, targetIndexY:UInt, isRevertSwap:Bool = false):Void
	{
		if ((isAnimationInProgress && !isRevertSwap)
			|| targetIndexX >= map[0].length
			|| targetIndexX < 0
			|| targetIndexY >= map.length
			|| targetIndexY < 0
		) return;

		var tempA:Elem = map[targetIndexY][targetIndexX];
		var tempB:Elem = map[indexY][indexX];

		if (tempA.isFrozen || tempB.isFrozen) return;

		if (!isRevertSwap && (tempA.isUnderSwapping || tempB.isUnderSwapping)) return;

		if (
			tempA.type == ElemType.Blocker
			|| tempB.type == ElemType.Blocker
			|| tempA.type == ElemType.Empty
			|| tempB.type == ElemType.Empty
			|| tempA.type == ElemType.None
			|| tempB.type == ElemType.None
		) return;

		onSwapRequestCallback();

		tempA.isUnderSwapping = true;
		tempB.isUnderSwapping = true;
		isAnimationInProgress = true;

		var tempSavedX = tempA.graphic.x;
		var tempSavedY = tempA.graphic.y;
		var tempSavedindexX = tempA.indexX;
		var tempSavedindexY = tempA.indexY;

		map[indexY][indexX] = tempA;
		tempA.indexX = tempB.indexX;
		tempA.indexY = tempB.indexY;

		map[targetIndexY][targetIndexX] = tempB;
		tempB.indexX = tempSavedindexX;
		tempB.indexY = tempSavedindexY;

		Actuate.tween(tempA, isRevertSwap ? TweenConfig.SWAP_REVERT_TIME : TweenConfig.SWAP_TIME, {
			animationX: tempB.graphic.x,
			animationY: tempB.graphic.y
		}).onUpdate(function() {
			tempA.graphic.x = tempA.animationX;
			tempA.graphic.y = tempA.animationY;
		}).ease(Quart.easeOut);

		Actuate.tween(tempB, isRevertSwap ? TweenConfig.SWAP_REVERT_TIME : TweenConfig.SWAP_TIME, {
			animationX: tempSavedX,
			animationY: tempSavedY
		}).onUpdate(function() {
			tempB.graphic.x = tempB.animationX;
			tempB.graphic.y = tempB.animationY;
		}).ease(Quart.easeOut).onComplete(function(){
			if (isRevertSwap)
			{
				checkMap();
				tempA.isUnderSwapping = false;
				tempB.isUnderSwapping = false;
				isAnimationInProgress = false;
				onFailedSwapCallback();
			}
			else checkSwapResult(indexX, indexY, targetIndexX, targetIndexY);
		});
	}

	function checkSwapResult(indexX:UInt, indexY:UInt, targetIndexX:UInt, targetIndexY:UInt)
	{
		checkMap();

		if (foundMatch.length == 0) swapElems(targetIndexX, targetIndexY, indexX, indexY, true);
		else
		{
			map[targetIndexY][targetIndexX].isUnderSwapping = false;
			map[indexY][indexX].isUnderSwapping = false;
			isAnimationInProgress = false;

			onSuccessfulSwapCallback();
			removeAllMatch();
		}
	}

	function removeAllMatch()
	{
		underAnimationElems = [];
		alreadyAnimatedElems = [];

		if (foundMatch.length > 0)
		{
			skillHandler.update(map, foundMatch);

			for (row in map) for (e in row) if (e != null) e.animationPath = [];
			isAnimationInProgress = true;

			var longestSkillTime:Float = 0;
			for (m in foundMatch)
			{
				var skillTime = skillHandler.handleElemSkill(m);
				if (skillTime > longestSkillTime) longestSkillTime = skillTime;
			}

			for (i in 0...map.length)
			{
				for (j in 0...map[i].length)
				{
					for (m in foundMatch)
					{
						for (e in m)
							if (e == map[i][j])
							{
								onElemCollectCallback(e.type);
								map[i][j].graphic.remove();
								map[i][j] = null;
								break;
							}
					}
				}
			}

			Actuate.timer(longestSkillTime).onComplete(analyzeMap);
		}
	}

	public function analyzeMap():Void
	{
		checkMap();
		fillMap();

		for (row in map) for (e in row) if (e != null && e.animationPath.length > 0) moveElemToPosition(e, checkAnimationProgress);
	}

	function checkAnimationProgress()
	{
		for (row in map) for (e in row) if (e != null && e.animationPath.length > 0) return;

		isAnimationInProgress = false;
		checkMap();

		if (foundMatch.length == 0) turnEnd();
		else removeAllMatch();
	}

	function turnEnd()
	{
		checkMap();
		if (foundMatch.length > 0) return;

		for (row in map)
			for (e in row)
				if (e.isFrozen && e.frozenTurnCount > 0)
				{
					e.frozenTurnCount--;
					if (e.frozenTurnCount == 0) effectHandler.addIceBreakEffect(e.graphic.x, e.graphic.y);
				}

		if (foundPossibilities.length == 0) onNoMoreMovesCallback();
		else onTurnEndCallback();
	}

	function fillMap()
	{
		for (i in 0...map.length)
		{
			for (j in 0...map[i].length)
			{
				if (map[i][j] == null)
				{
					fillElem(j, i);
					return;
				}
			}
		}
	}

	function fillElem(x:UInt, y:UInt)
	{
		var firstElemIndex:UInt = 0;
		while (
			firstElemIndex < map.length
			&& map[firstElemIndex][x] != null
			&& map[firstElemIndex][x].type == ElemType.None
		) {
			firstElemIndex++;
		}

		if (firstElemIndex < y)
		{
			var upperIndex:UInt = y - 1;
			while (
				upperIndex != 0
				&& (
					map[upperIndex][x] == null
					|| map[upperIndex][x].type == ElemType.Empty
					|| map[upperIndex][x].type == ElemType.None
				)
			) upperIndex--;

			var upperElem = map[upperIndex][x];

			var downIndex:UInt = map.length - 1;
			var noneIndex:Int = -1;

			for (l in y + 1...map.length)
			{
				if (map[l][x] != null && map[l][x].type != ElemType.Empty)
				{
					if (noneIndex == -1 && map[l][x].type == ElemType.None)
					{
						noneIndex = l;
						if (l == map.length - 1) downIndex = l - 1;
					}
					else
					{
						if (noneIndex == -1) downIndex = l - 1;
						else downIndex = noneIndex - 1;
						break;
					}
				}
			}

			if (upperElem.type == ElemType.Blocker)
			{
				if (downIndex - y > 1 || y - upperIndex > 0)
				{
					var prevElemYIndex:UInt = y - 1;
					var prevPossibleElem = map[prevElemYIndex][x - 1];
					if ((map[y][x - 1] != null && map[y][x - 1].type == ElemType.Blocker
							&& map[y - 1] != null && map[y - 1][x] != null && map[y - 1][x].type == ElemType.Blocker)
						||
						(prevPossibleElem != null && prevPossibleElem.type == ElemType.None)
					)
						prevPossibleElem = null
					else if (prevPossibleElem == null)
						for (k in 2...y)
							if (map[y - k][x - 1] != null)
							{
								prevElemYIndex = y - k;
								prevPossibleElem = map[prevElemYIndex][x - 1];
								break;
							}

					var nextElemYIndex:UInt = y - 1;
					var nextPossibleElem = map[nextElemYIndex][x + 1];
					if ((map[y][x + 1] != null && map[y][x + 1].type == ElemType.Blocker
							&& map[y - 1] != null && map[y - 1][x] != null && map[y - 1][x].type == ElemType.Blocker)
						||
						(nextPossibleElem != null && nextPossibleElem.type == ElemType.None)
					)
						nextPossibleElem = null
					else if (nextPossibleElem == null)
						for (k in 2...y)
							if (map[y - k][x + 1] != null)
							{
								nextElemYIndex = y - k;
								nextPossibleElem = map[nextElemYIndex][x + 1];
								break;
							}

					if (
						(crossFillFromLeft
							|| nextPossibleElem == null
							|| nextPossibleElem.type == ElemType.Empty
							|| nextPossibleElem.type == ElemType.Blocker)
						&& prevPossibleElem != null
						&& BoardHelper.isMovableElem(prevPossibleElem)
					){
						crossFillFromLeft = !crossFillFromLeft;

						prevPossibleElem.indexX++;
						prevPossibleElem.indexY++;

						prevPossibleElem.animationPath.push(
							{ x: prevPossibleElem.indexX * Elem.SIZE, y: prevPossibleElem.indexY * Elem.SIZE }
						);

						map[prevElemYIndex][x - 1] = null;
						map[prevPossibleElem.indexY][prevPossibleElem.indexX] = prevPossibleElem;

						fillMap();
						return;
					}
					else if (
						nextPossibleElem != null
						&& BoardHelper.isMovableElem(nextPossibleElem)
					){
						crossFillFromLeft = !crossFillFromLeft;

						nextPossibleElem.indexX--;
						nextPossibleElem.indexY++;

						nextPossibleElem.animationPath.push(
							{ x: nextPossibleElem.indexX * Elem.SIZE, y: nextPossibleElem.indexY * Elem.SIZE }
						);

						map[nextElemYIndex][x + 1] = null;
						map[nextPossibleElem.indexY][nextPossibleElem.indexX] = nextPossibleElem;

						fillMap();
						return;
					}
					else
					{
						map[y][x] = new Elem(y, x, ElemType.Empty);
						container.addChild(map[y][x].graphic);

						fillMap();
						return;
					}
				}
				else
				{
					map[y][x] = new Elem(y, x, ElemType.Empty);
					container.addChild(map[y][x].graphic);

					fillMap();
					return;
				}
			}
			else if (upperElem.type != ElemType.Empty)
			{
				upperElem.animationPath.push({ x: upperElem.indexX * Elem.SIZE, y: downIndex * Elem.SIZE});
				upperElem.indexY = downIndex;

				map[upperIndex][x] = null;
				map[downIndex][x] = upperElem;

				fillMap();
				return;
			}
		}
		else
		{
			var addingPosition:Float = -Elem.SIZE;

			for (k in 1...map.length)
			{
				if (map[k][x] != null && map[k][x].type != ElemType.Empty)
				{
					addingPosition = map[k][x].graphic.y > 0 ? -Elem.SIZE : map[k][x].graphic.y - Elem.SIZE;
					break;
				}
			}

			var newElem = map[y][x] = BoardHelper.createRandomElem(y, x, availableElemTypes);
			newElem.animationPath.push({ x: newElem.graphic.x, y: newElem.graphic.y});
			newElem.animationY = newElem.graphic.y = addingPosition;
			container.addChild(newElem.graphic);

			fillMap();
			return;
		}
	}

	function isThereNullInMap():Bool
	{
		for (row in map)
			for (e in row)
				if (e == null) return true;

		return false;
	}

	function moveElemToPosition(e:Elem, onComplete:Void->Void = null)
	{
		if (underAnimationElems.indexOf(e) == -1) underAnimationElems.push(e);

		if (alreadyAnimatedElems.indexOf(e) == -1)
		{
			alreadyAnimatedElems.push(e);

			Actuate.tween(e, TweenConfig.ELEM_BACKWARD_TIME, {
				animationY: e.animationY - Elem.SIZE / 4,
				rotation: Math.random() * Math.PI / 4 - Math.PI / 8
			}).onUpdate(function() {
				e.graphic.y = e.animationY;
				e.graphic.rotation = e.rotation;
			}).ease(Quad.easeOut)
			.onComplete(function() {
				moveElemToNextPosition(e, onComplete, true);
			});
		}
		else moveElemToNextPosition(e, onComplete, true);
	}

	function moveElemToNextPosition(e:Elem, onComplete:Void->Void = null, isFirstMove:Bool = false)
	{
		Actuate.tween(e, TweenHelper.getElemTweenSpeedByDistance(GeomUtil.getDistance(e.animationPath[0], { x: e.graphic.x, y: e.graphic.y } )), {
			animationX: e.animationPath[0].x,
			animationY: e.animationPath[0].y,
			rotation: 0
		}).onUpdate(function() {
			e.graphic.x = e.animationX;
			e.graphic.y = e.animationY;
			e.graphic.rotation = e.rotation;
		}).onComplete(function() {
			e.animationPath.shift();

			if (e.animationPath.length > 0) moveElemToNextPosition(e, onComplete);
			else
			{
				underAnimationElems.remove(e);

				if (
					map[e.indexY + 1] != null
					&& map[e.indexY + 1][e.indexX] != null
					&& map[e.indexY + 1][e.indexX].type != ElemType.Empty
					&& underAnimationElems.indexOf(e) == -1
				) e.graphic.moveFinished();

				if (onComplete != null) onComplete();
			}
		}).ease(Linear.easeNone);
	}

	function getElemByPosition(p:SimplePoint):Elem
	{
		p.x -= parent.x + Elem.SIZE * parent.scaleX / 2;
		p.y -= parent.y + Elem.SIZE * parent.scaleY / 2;
		p.x = (p.x / (parent.scaleX * 100)) * 100;
		p.y = (p.y / (parent.scaleY * 100)) * 100;

		for (row in map)
		{
			for (e in row)
			{
				if (e == null) continue;

				if (e != null && e.type != ElemType.Blocker
					&& p.x > e.graphic.x - Elem.SIZE / 2
					&& p.x <= e.graphic.x + Elem.SIZE / 2
					&& p.y > e.graphic.y - Elem.SIZE / 2
					&& p.y <= e.graphic.y + Elem.SIZE / 2
				){
					return e;
				}
			}
		}

		return null;
	}

	function checkMap()
	{
		for (row in map)
			for (elem in row)
				if (elem != null)
				{
					elem.graphic.unmark();
					elem.graphic.setScale(1);
				}

		var mapData = BoardHelper.analyzeMap(map);
		foundMatch = mapData.matches;
		foundPossibilities = mapData.movePossibilities;

		for (m in foundMatch) for (e in m) if (e != null) effectHandler.addMonsterMatchEffect(e.graphic.x, e.graphic.y);

		debugMapTrace();
	}

	public function shuffleElemsRequest()
	{
		shuffleElems(function(){ Actuate.timer(.5).onComplete(onTurnEndCallback); });
	}

	function shuffleElems(onFinished:Void->Void):Void
	{
		isShuffleInProgress = true;

		var allMovableElem = [];
		for (row in map)
			for (elem in row)
				if (BoardHelper.isMovableElem(elem))
					allMovableElem.push(elem);

		allMovableElem.shuffle();

		for (i in 0...map.length)
			for (j in 0...map[0].length)
				if (BoardHelper.isMovableElem(map[i][j]))
				{
					var tempObj = map[i][j];
					map[i][j] = allMovableElem[allMovableElem.length - 1];
					map[i][j].indexX = j;
					map[i][j].indexY = i;
					map[i][j].animationPath = [
						{ x: j * Elem.SIZE, y: i * Elem.SIZE }
					];

					allMovableElem.pop();
				}

		var mapData = BoardHelper.analyzeMap(map);
		if (mapData.matches.length > 0 || mapData.movePossibilities.length < 2) shuffleElems(onFinished);
		else
		{
			var isFirstElem:Bool = true;
			for (row in map)
				for (elem in row)
					if (BoardHelper.isMovableElem(elem))
					{
						moveElemToPosition(elem, isFirstElem ? onFinished : null);

						isFirstElem = false;
					}
			isShuffleInProgress = false;
			checkMap();
		}
	}

	function debugMapTrace()
	{
		trace("#Map");
		for (row in map)
		{
			var rowText:String = "[ ";
			for (elem in row)
			{
				if (elem == null) rowText += " N, ";
				else rowText += ((elem.type.toInt() < 10 && elem.type.toInt() > -1) ? " " : "") + elem.type + ", ";
			}
			trace(rowText.substr(0, rowText.length - 2) + " ]");
		}
	}
}

enum DragDirection {
	Up;
	Down;
	Left;
	Right;
	None;
}

typedef Map = Array<Array<Elem>>;