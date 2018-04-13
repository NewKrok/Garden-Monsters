package fe.game;

import h2d.Bitmap;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Layers;
import h2d.Mask;
import h2d.filter.Glow;
import haxe.Timer;
import haxe.ds.Map;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Cursor;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.actuators.GenericActuator;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import fe.game.Elem.ElemType;
import fe.game.util.BoardHelper;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Board
{
	public var foundMatch:Array<Array<Elem>>;
	public var foundPossibilities:Array<Elem>;

	public var alreadyAnimatedElems:Array<Elem>;
	public var underAnimationElems:Array<Elem>;

	var map:Array<Array<Elem>>;
	var parent:Layers;
	var mask:Mask;
	var container:Layers;
	var background:Graphics;
	var selectedElemBackground:Bitmap;
	var effectHandler:EffectHandler;

	var isDragging:Bool = false;
	var isAnimationInProgress:Bool = false;
	var crossFillFromLeft:Bool = true;
	var dragDirection:DragDirection;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };
	var draggedElement:Elem;
	var focusElement:Elem;

	var showHelpTimer:Dynamic;

	public function new(parent:Layers, map:Array<Array<Elem>>, effectHandler:EffectHandler)
	{
		this.parent = parent;
		this.map = map;
		this.effectHandler = effectHandler;

		mask = new Mask(100, 100, parent);

		container = new Layers(mask);
		container.setPos(Elem.SIZE / 2, Elem.SIZE / 2);

		background = new Graphics(container);
		background.beginFill(0xFF0000);
		for (i in 0...map[0].length)
			for (j in 0...map.length)
				if (map[j][i].type != ElemType.Blocker && map[j][i].type != ElemType.None && map[j][i].type != ElemType.Empty )
					background.drawTile(i * Elem.SIZE - Elem.SIZE / 2 + 2.5, j * Elem.SIZE - Elem.SIZE / 2 + 2.5, Res.image.game.elem_background.toTile());
		background.endFill();

		selectedElemBackground = new Bitmap(Res.image.game.elem_selected.toTile(), container);
		selectedElemBackground.tile.dx = cast -selectedElemBackground.tile.width / 2;
		selectedElemBackground.tile.dy = cast -selectedElemBackground.tile.height / 2;
		selectedElemBackground.visible = false;

		addElemsToBoard();
		checkMap();
		removeAllMatch();

		mask.width = Std.int(container.getSize().width + Elem.SIZE / 2);
		mask.height = Std.int(container.getSize().height + Elem.SIZE / 2);
		mask.setPos(25, 25);

		createInteractive();
	}

	function addElemsToBoard()
	{
		for (row in map) for (e in row) container.addChild(e.graphic);
	}

	function createInteractive()
	{
		var i:Interactive = new Interactive(HppG.stage2d.width, HppG.stage2d.height, parent);
		i.cursor = Cursor.Default;

		i.onPush = function(e:Event)
		{
			draggedElement = getElemByPosition({
				x: e.relX - container.x - mask.x,
				y: e.relY - container.y - mask.y
			});

			if (draggedElement != null){
				isDragging = true;
				dragStartPoint.x = e.relX;
				dragStartPoint.y = e.relY;
			}
			else focusElement = null;
		};

		i.onRelease = function(_) { swapElemRequest(); };

		i.onMove = function(e:Event)
		{
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
					x: e.relX - container.x - mask.x,
					y: e.relY - container.y - mask.y
				});

				if (focusElement != null && focusElement.type != ElemType.Empty && focusElement.type != ElemType.None)
				{
					focusElement.hasMouseHover = true;
					selectedElemBackground.x = focusElement.graphic.x;
					selectedElemBackground.y = focusElement.graphic.y;
					selectedElemBackground.visible = true;
					i.cursor = Cursor.Button;
				}
				else i.cursor = Cursor.Default;
			}
			else selectedElemBackground.visible = false;
		};
	}

	function swapElemRequest():Void
	{
		isDragging = false;

		if (draggedElement != null)
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

		if (!isRevertSwap && (tempA.isUnderSwapping || tempB.isUnderSwapping)) return;

		if (
			tempA.type == ElemType.Blocker
			|| tempB.type == ElemType.Blocker
			|| tempA.type == ElemType.Empty
			|| tempB.type == ElemType.Empty
			|| tempA.type == ElemType.None
			|| tempB.type == ElemType.None
		) return;

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

		Actuate.tween(tempA, .3, {
			animationX: tempB.graphic.x,
			animationY: tempB.graphic.y
		}).onUpdate(function() {
			tempA.graphic.x = tempA.animationX;
			tempA.graphic.y = tempA.animationY;
		}).ease(Quart.easeOut);

		Actuate.tween(tempB, .3, {
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

			removeAllMatch();
		}
	}

	function removeAllMatch()
	{
		underAnimationElems = [];
		alreadyAnimatedElems = [];

		if (foundMatch.length > 0)
		{
			for (row in map) for (e in row) e.animationPath = [];
			isAnimationInProgress = true;

			for (i in 0...map.length)
			{
				for (j in 0...map[i].length)
				{
					for (m in foundMatch)
					{
						for (e in m)
							if (e == map[i][j])
							{
								map[i][j].graphic.remove();
								map[i][j] = null;
								break;
							}
					}
				}
			}

			checkMap();
			fillMap();

			for (row in map) for (e in row) if (e != null && e.animationPath.length > 0) moveElemToPosition(e, checkAnimationProgress);
		}
	}

	function checkAnimationProgress()
	{
		for (row in map) for (e in row) if (e != null && e.animationPath.length > 0) return;

		isAnimationInProgress = false;
		checkMap();
		removeAllMatch();
	}

	function fillMap()
	{
		for (i in 0...map.length)
		{
			for (j in 0...map[i].length)
			{
				if (map[i][j] == null)
				{
					var firstElemIndex:UInt = 0;
					while (
						firstElemIndex < map.length
						&& map[firstElemIndex][j] != null
						&& map[firstElemIndex][j].type == ElemType.None
					) {
						firstElemIndex++;
					}

					if (firstElemIndex < i)
					{
						var upperIndex:UInt = i - 1;
						while (
							upperIndex != 0
							&& (
								map[upperIndex][j] == null
								|| map[upperIndex][j].type == ElemType.Empty
								|| map[upperIndex][j].type == ElemType.None
							)
						) upperIndex--;

						var upperElem = map[upperIndex][j];

						var downIndex:UInt = map.length - 1;
						var noneIndex:Int = -1;
						for (l in i + 1...map.length)
						{
							if (map[l][j] != null && map[l][j].type != ElemType.Empty)
							{
								if (noneIndex == -1 && map[l][j].type == ElemType.None)
								{
									noneIndex = l;
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
							if (downIndex - i > 1 || i - upperIndex > 1)
							{
								var prevPossibleElem = map[downIndex - 2][j - 1];
								var isPrevBlocked:Bool = map[downIndex - 1][j - 1] == null || map[downIndex - 1][j - 1].type == ElemType.Blocker;
								var nextPossibleElem = map[downIndex - 2][j + 1];
								var isNextBlocked:Bool = map[downIndex - 1][j + 1] == null || map[downIndex - 1][j + 1].type == ElemType.Blocker;

								if (
									(crossFillFromLeft
										|| nextPossibleElem == null
										|| nextPossibleElem.type == ElemType.Empty
										|| nextPossibleElem.type == ElemType.Blocker
										|| isNextBlocked)
									&& prevPossibleElem != null
									&& !isPrevBlocked
									&& BoardHelper.isMovableElem(prevPossibleElem)
								){
									crossFillFromLeft = !crossFillFromLeft;

									prevPossibleElem.indexX++;
									prevPossibleElem.indexY++;

									prevPossibleElem.animationPath.push(
										{ x: prevPossibleElem.indexX * Elem.SIZE, y: prevPossibleElem.indexY * Elem.SIZE }
									);

									map[downIndex - 2][j - 1] = null;
									map[prevPossibleElem.indexY][prevPossibleElem.indexX] = prevPossibleElem;

									fillMap();
									return;
								}
								else if (
									nextPossibleElem != null
									&& !isNextBlocked
									&& BoardHelper.isMovableElem(nextPossibleElem)
								){
									crossFillFromLeft = !crossFillFromLeft;

									nextPossibleElem.indexX--;
									nextPossibleElem.indexY++;

									nextPossibleElem.animationPath.push(
										{ x: nextPossibleElem.indexX * Elem.SIZE, y: nextPossibleElem.indexY * Elem.SIZE }
									);

									map[downIndex - 2][j + 1] = null;
									map[nextPossibleElem.indexY][nextPossibleElem.indexX] = nextPossibleElem;

									fillMap();
									return;
								}
								else
								{
									map[i][j] = new Elem(i, j, ElemType.Empty);
									container.addChild(map[i][j].graphic);
								}
							}
							else
							{
								map[i][j] = new Elem(i, j, ElemType.Empty);
								container.addChild(map[i][j].graphic);
							}
						}
						else if (upperElem.type != ElemType.Empty)
						{
							upperElem.animationPath.push({ x: upperElem.indexX * Elem.SIZE, y: downIndex * Elem.SIZE});
							upperElem.indexY = downIndex;

							map[upperIndex][j] = null;
							map[downIndex][j] = upperElem;

							fillMap();
							return;
						}
					}
					else
					{
						var addingPosition:Float = -Elem.SIZE;

						for (k in 1...map.length)
						{
							if (map[k][j] != null && map[k][j].type != ElemType.Empty)
							{
								addingPosition = map[k][j].graphic.y > 0 ? -Elem.SIZE : map[k][j].graphic.y - Elem.SIZE;
								break;
							}
						}

						var newElem = map[i][j] = new Elem(i, j);
						newElem.animationPath.push({ x: newElem.graphic.x, y: newElem.graphic.y});
						newElem.animationY = newElem.graphic.y = addingPosition;
						container.addChild(newElem.graphic);

						fillMap();
						return;
					}
				}
			}
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

			Actuate.tween(e, .2, {
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
		Actuate.tween(e, getElemTweenSpeedByDistance(GeomUtil.getDistance(e.animationPath[0], { x: e.graphic.x, y: e.graphic.y } )), {
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

	function getElemTweenSpeedByDistance(d:Float):Float
	{
		return d / Elem.SIZE * .15;
	}

	function getElemByPosition(p:SimplePoint):Elem
	{
		for (row in map)
		{
			for (e in row)
			{
				var size = e.graphic.getSize();

				if (e != null && e.type != ElemType.Blocker
					&& p.x > e.graphic.x - size.width / 2
					&& p.x < e.graphic.x + size.width / 2
					&& p.y > e.graphic.y - size.height / 2
					&& p.y < e.graphic.y + size.height / 2
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
					elem.graphic.filter = null;
					elem.graphic.setScale(1);
				}

		var mapData = BoardHelper.analyzeMap(map);
		foundMatch = mapData.matches;
		foundPossibilities = mapData.movePossibilities;

		for (m in foundMatch) for (e in m) if (e != null) effectHandler.addMonsterMatchEffect(e.graphic.x, e.graphic.y);

		if (showHelpTimer != null)
		{
			Actuate.stop(showHelpTimer, null, false, false);
			showHelpTimer = null;
		}
		showHelpTimer = Actuate.timer(5).onComplete(function() {
			if (foundPossibilities.length == 1) trace("NO MORE MOVES!");
			else for (m in foundPossibilities) if (m != null) m.graphic.filter = new Glow(0xFFFF00, 1, 1, 3, 1);
		});

		debugMapTrace();
	}

	function debugMapTrace()
	{
		trace("#Map");
		for (row in map)
		{
			var rowText:String = "| ";
			for (elem in row)
			{
				if (elem == null) rowText += " N | ";
				else rowText += ((elem.type != ElemType.Empty) ? " " : "") + elem.type + " | ";
			}
			trace(rowText);
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