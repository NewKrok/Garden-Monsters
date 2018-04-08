package fe.game;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Layers;
import h2d.Mask;
import h2d.filter.Glow;
import haxe.Timer;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.actuators.GenericActuator;
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

	var map:Array<Array<Elem>>;
	var parent:Layers;
	var mask:Mask;
	var container:Layers;
	var background:Graphics;
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
				if (map[j][i].type != ElemType.Blocker && map[j][i].type != ElemType.Empty )
					background.drawTile(i * Elem.SIZE - Elem.SIZE / 2 + 2.5, j * Elem.SIZE - Elem.SIZE / 2 + 2.5, Res.image.game.elem_background.toTile());
		background.endFill();

		addElemsToBoard();
		checkMap();
		removeAllMatch();

		mask.width = Std.int(container.getSize().width + Elem.SIZE / 2);
		mask.height = Std.int(container.getSize().height + Elem.SIZE / 2);
		mask.setPos(50, 50);

		createInteractive();
	}

	function addElemsToBoard()
	{
		for (row in map) for (e in row) container.addChild(e.graphic);
	}

	function createInteractive()
	{
		var i:Interactive = new Interactive(HppG.stage2d.width, HppG.stage2d.height, parent);

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
				if (focusElement != null)
				{
					focusElement.hasMouseHover = false;
				}

				focusElement = getElemByPosition({
					x: e.relX - container.x - mask.x,
					y: e.relY - container.y - mask.y
				});

				if (focusElement != null)
				{
					focusElement.hasMouseHover = true;
				}
			}
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
		) return;

		tempA.isUnderSwapping = true;
		tempB.isUnderSwapping = true;
		isAnimationInProgress = true;

		var tempSavedX = tempA.x;
		var tempSavedY = tempA.y;
		var tempSavedindexX = tempA.indexX;
		var tempSavedindexY = tempA.indexY;

		map[indexY][indexX] = tempA;
		tempA.x = tempB.x;
		tempA.y = tempB.y;
		tempA.indexX = tempB.indexX;
		tempA.indexY = tempB.indexY;

		map[targetIndexY][targetIndexX] = tempB;
		tempB.x = tempSavedX;
		tempB.y = tempSavedY;
		tempB.indexX = tempSavedindexX;
		tempB.indexY = tempSavedindexY;

		Actuate.tween(tempA, .3, {
			animationX: tempA.x,
			animationY: tempA.y
		}).onUpdate(function() {
			tempA.graphic.x = tempA.animationX;
			tempA.graphic.y = tempA.animationY;
		}).ease(Quart.easeOut);

		Actuate.tween(tempB, .3, {
			animationX: tempB.x,
			animationY: tempB.y
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
	}

	function fillMap()
	{
		for (i in 0...map.length)
		{
			for (j in 0...map[i].length)
			{
				if (map[i][j] == null)
				{
					if (i > 0)
					{
						var upperIndex:UInt = i - 1;
						while (upperIndex != 0 && (map[upperIndex][j] == null || map[upperIndex][j].type == ElemType.Empty)) upperIndex--;
						var upperElem = map[upperIndex][j];

						var downIndex:UInt = map.length - 1;
						for (l in i + 1...map.length)
						{
							if (map[l][j] != null && map[l][j].type != ElemType.Empty)
							{
								downIndex = l - 1;
								break;
							}
						}

						if (upperElem.type == ElemType.Blocker)
						{
							if (downIndex - i > 1 || i - upperIndex > 1)
							{
								var prevPossibleElem = map[downIndex - 2][j - 1];
								var nextPossibleElem = map[downIndex - 2][j + 1];

								if (
									(crossFillFromLeft
										|| nextPossibleElem == null
										|| nextPossibleElem.type == ElemType.Empty
										|| nextPossibleElem.type == ElemType.Blocker)
									&& prevPossibleElem != null
									&& BoardHelper.isMovableElem(prevPossibleElem)
								){
									crossFillFromLeft = !crossFillFromLeft;

									prevPossibleElem.indexX = j;
									prevPossibleElem.indexY = downIndex;
									prevPossibleElem.x = j * Elem.SIZE;
									prevPossibleElem.y = downIndex * Elem.SIZE;

									map[downIndex - 2][j - 1] = null;
									map[downIndex][j] = prevPossibleElem;

									moveElemToPosition(prevPossibleElem);

									fillMap();
									return;
								}
								else if (nextPossibleElem != null && BoardHelper.isMovableElem(nextPossibleElem))
								{
									crossFillFromLeft = !crossFillFromLeft;

									nextPossibleElem.indexX = j;
									nextPossibleElem.indexY = downIndex;
									nextPossibleElem.x = j * Elem.SIZE;
									nextPossibleElem.y = downIndex * Elem.SIZE;

									map[downIndex - 2][j + 1] = null;
									map[downIndex][j] = nextPossibleElem;

									moveElemToPosition(nextPossibleElem);

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
							upperElem.y = downIndex * Elem.SIZE;
							upperElem.indexY = downIndex;

							map[i - 1][j] = null;
							map[downIndex][j] = upperElem;

							moveElemToPosition(upperElem);

							fillMap();
							return;
						}
					}
					else
					{
						map[i][j] = new Elem(i, j);
						map[i][j].animationY = map[i][j].graphic.y = -Elem.SIZE;
						container.addChild(map[i][j].graphic);
						moveElemToPosition(map[i][j]);

						fillMap();
						return;
					}
				}
			}
		}

		isAnimationInProgress = true;
		Actuate.timer(1).onComplete(function() {
			isAnimationInProgress = false;
			checkMap();
			if (foundMatch.length > 0 || isThereNullInMap())removeAllMatch();
		});
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
		Actuate.tween(e, .2, {
			animationY: e.animationY - Elem.SIZE / 4,
			rotation: Math.random() * Math.PI / 4 - Math.PI / 8
		}).onUpdate(function() {
			e.graphic.y = e.animationY;
			e.graphic.rotation = e.rotation;
		}).ease(Quad.easeOut)
		.onComplete(function() {
			Actuate.tween(e, getElemTweenSpeedByDistance(e.y - e.animationY), {
				animationX: e.x,
				animationY: e.y,
				rotation: 0
			}).onUpdate(function() {
				e.graphic.x = e.animationX;
				e.graphic.y = e.animationY;
				e.graphic.rotation = e.rotation;
			}).onComplete(function() {
				e.graphic.moveFinished();
				if (onComplete != null) onComplete();
			}).ease(Quad.easeIn);
		});
	}

	function getElemTweenSpeedByDistance(d:Float):Float
	{
		return d / Elem.SIZE * .2;
	}

	function getElemByPosition(p:SimplePoint):Elem
	{
		for (row in map)
		{
			for (e in row)
			{
				var size = e.graphic.getSize();

				if (e != null && e.type != ElemType.Blocker
					&& p.x > e.x - size.width / 2
					&& p.x < e.x + size.width / 2
					&& p.y > e.y - size.height / 2
					&& p.y < e.y + size.height / 2
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

		for (m in foundMatch) for (e in m) if (e != null) effectHandler.addMonsterMatchEffect(e.x, e.y);

		if (showHelpTimer != null)
		{
			showHelpTimer = null;
			Actuate.stop(showHelpTimer);
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