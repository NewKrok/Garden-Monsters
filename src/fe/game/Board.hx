package fe.game;

import fe.TweenConfig;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Layers;
import h2d.Mask;
import h2d.filter.Glow;
import haxe.Timer;
import haxe.ds.Map;
import hpp.heaps.HppG;
import hpp.util.ArrayUtil;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Cursor;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.MotionPath;
import motion.actuators.GenericActuator;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import fe.game.Elem.ElemType;
import fe.game.util.BoardHelper;

using hpp.util.ArrayUtil;

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

				if (focusElement != null && !focusElement.isFrozen && focusElement.type != ElemType.Empty && focusElement.type != ElemType.None)
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

			for (m in foundMatch) handleElemSkill(m);

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

			Actuate.timer(1).onComplete(function() {
				checkMap();
				fillMap();

				for (row in map) for (e in row) if (e != null && e.animationPath.length > 0) moveElemToPosition(e, checkAnimationProgress);
			});
		}
	}

	function handleElemSkill(m:Array<Elem>)
	{
		switch(m[0].type)
		{
			case ElemType.Elem1: removeElemByElem(getRandomNearbyNotMatchedPlayableElem(m), m.random(), effectHandler.addElem1StartEffect, effectHandler.addElem1ActivateEffect);
			case ElemType.Elem2: freezeElemByElem(getRandomNearbyNotMatchedPlayableElem(m), m.random(), effectHandler.addElem2StartEffect, effectHandler.addElem2ActivateEffect);
			case ElemType.Elem3: changeElemTypeByElem(getRandomNearbyNotMatchedPlayableElem(m), m.random(), effectHandler.addElem3StartEffect, effectHandler.addElem3ActivateEffect);
			case ElemType.Elem4: shiftRow(getRandomNearbyNotMatchedPlayableElem(m), m.random(), effectHandler.addElem4StartEffect, effectHandler.addElem4ActivateEffect);
			case ElemType.Elem5: removeRandomElemByElem(getRandomNotMatchedPlayableElem(), m.random(), effectHandler.addElem5StartEffect, effectHandler.addElem5ActivateEffect);
			case ElemType.Elem7: swapRandomElemsByElem(getRandomNotMatchedPlayableElem(), getRandomNotMatchedPlayableElem(), m.random(), effectHandler.addElem7StartEffect, effectHandler.addElem7Effect);

			case _:
		}
	}

	function getRandomNearbyNotMatchedPlayableElem(m:Array<Elem>):Elem
	{
		var searchDirections:Array<SimplePoint> = [
			{ x: -1, y: -1 }, { x: -1, y: 0 }, { x: -1, y: 1 },
			{ x: 0,  y: -1 }, 				   { x: 0,  y: 1 },
			{ x: 1,  y: -1 }, { x: 1,  y: 0 }, { x: 1,  y: 1 }
		];
		var possibleElems:Array<Elem> = [];

		for (e in m)
		{
			for (d in searchDirections)
			{
				if (map[cast e.indexY + d.y] == null) continue;

				var selectedElem = map[cast e.indexY + d.y][cast e.indexX + d.x];

				if (
					selectedElem != null
					&& selectedElem.type != ElemType.Blocker
					&& selectedElem.type != ElemType.Empty
					&& selectedElem.type != ElemType.None
					&& m.indexOf(selectedElem) == -1
					&& isNotMatchedElem(selectedElem)
				) possibleElems.push(selectedElem);
			}
		}

		return possibleElems.random();
	}

	function getRandomNotMatchedPlayableElem():Elem
	{
		var possibleElems:Array<Elem> = [];

		for (row in map)
		{
			for (e in row)
			{
				if (
					e != null
					&& e.type != ElemType.Blocker
					&& e.type != ElemType.Empty
					&& e.type != ElemType.None
					&& isNotMatchedElem(e)
				) possibleElems.push(e);
			}
		}

		return possibleElems.random();
	}

	function removeElemByElem(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);
			jumpElemToElem(target, triggerElem, function(){
				activateEffect(target.graphic.x, target.graphic.y);
				map[target.indexY][target.indexX] = null;
				target.graphic.remove();
				target = null;
			});
		}
	}

	function removeRandomElemByElem(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);

			var e = triggerElem.clone();
			container.addChild(e.graphic);

			Actuate.tween(e.graphic, TweenConfig.JUMP_UP_PREPARE_TIME, {
				scaleX: .8,
				scaleY: .8,
			}).ease(Quad.easeOut).onUpdate(function() {
				e.graphic.scaleY = e.graphic.scaleY;
			}).onComplete(function() {
				Actuate.tween(e.graphic, TweenConfig.JUMP_UP_START_TIME, {
					scaleX: 2,
					scaleY: 2,
				}).ease(Quad.easeOut).onUpdate(function() {
					e.graphic.scaleY = e.graphic.scaleY;
				}).onComplete(function() {
					Actuate.tween(e.graphic, TweenConfig.JUMP_UP_TIME, {
						scaleX: 1,
						scaleY: 1,
					}).ease(Linear.easeNone).onUpdate(function() {
						e.graphic.scaleY = e.graphic.scaleY;
					}).onComplete(function(){
						e.graphic.remove();
						e = null;

						elemFallDown(target);
						shakeBoard(2);
						activateEffect(target.graphic.x, target.graphic.y);
						map[target.indexY][target.indexX] = null;
						target.graphic.remove();
						target = null;
					});
				});
			});
		}
	}

	function elemFallDown(e:Elem)
	{
		var elemClone = e.clone();
		container.addChild(elemClone.graphic);

		Actuate.tween(elemClone.graphic, TweenConfig.ELEM_FALL_OUT_FROM_GAME_TIME, {
			y: elemClone.graphic.y + 200,
			alpha: 0,
			rotation: Math.random() * Math.PI / 2
		}).ease(Quad.easeIn).onUpdate(function() {
			elemClone.graphic.y = elemClone.graphic.y;
		}).onComplete(function(){
			elemClone.graphic.remove();
			elemClone = null;
		});
	}

	function shakeBoard(count:UInt)
	{
		if (count > 0) count--;

		var basePos:SimplePoint = { x: container.x, y: container.y };
		Actuate.tween(container, TweenConfig.CAMERA_SHAKE_MOVEMENT_TIME, {
			x: basePos.x + Math.random() * 30 - 15,
			y: basePos.y + Math.random() * 30 - 15
		}).onUpdate(function(){
			container.x = container.x;
		}).onComplete(function(){
			Actuate.tween(container, TweenConfig.CAMERA_SHAKE_MOVEMENT_TIME, {
				x: basePos.x + Math.random() * 30 - 15,
				y: basePos.y + Math.random() * 30 - 15
			}).onUpdate(function(){
				container.x = container.x;
			}).onComplete(function(){
				if (count == 0)
					Actuate.tween(container, TweenConfig.CAMERA_SHAKE_MOVEMENT_TIME, { x: basePos.x, y: basePos.y }).onUpdate(function(){ container.x = container.x; });
				else
				{
					container.x = basePos.x;
					container.y = basePos.y;
					shakeBoard(count - 1);
				}
			});
		});
	}

	function changeElemTypeByElem(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);
			jumpElemToElem(target, triggerElem, function(){
				activateEffect(target.graphic.x, target.graphic.y);
				target.graphic.alpha = 0;
				target.type = ElemType.Random;
				Actuate.tween(target.graphic, .3, { alpha: 1 });
			});
		}
	}

	function freezeElemByElem(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);
			jumpElemToElem(target, triggerElem, function(){
				activateEffect(target.graphic.x, target.graphic.y);
				target.frozenTurnCount = 2;
			});
		}
	}

	function shiftRow(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);
			jumpElemToElem(target, triggerElem, function(){
				activateEffect(target.graphic.x, target.graphic.y);
				if (BoardHelper.isMovableElem(map[target.indexY][target.indexX + 1])) activateEffect(target.graphic.x + Elem.SIZE, target.graphic.y);
				if (BoardHelper.isMovableElem(map[target.indexY][target.indexX - 1])) activateEffect(target.graphic.x - Elem.SIZE, target.graphic.y);
				map[target.indexY][target.indexX] = null;
				shiftToLeft(target.indexX, target.indexY);
				shiftToRight(target.indexX, target.indexY);
				target.graphic.remove();
				target = null;
			});
		}
	}

	function shiftToLeft(x:UInt, y:UInt)
	{
		var firstLeftIndex:UInt = 0;
		for (i in 0...x)
			if (map[y][i] == null
				|| map[y][i].type == ElemType.Blocker
				|| map[y][i].type == ElemType.Empty
				|| map[y][i].type == ElemType.None
			) firstLeftIndex = i + 1;

		if (firstLeftIndex == x) return;

		var e = map[y][firstLeftIndex].clone();
		container.addChild(e.graphic);
		map[y][firstLeftIndex].graphic.remove();
		map[y][firstLeftIndex] = null;

		for (i in firstLeftIndex...x - 1)
		{
			map[y][i] = map[y][i + 1];
			map[y][i].indexX--;
			map[y][i].animationPath = [{ x: map[y][i].indexX * Elem.SIZE, y: map[y][i].graphic.y}];
			moveElemToPosition(map[y][i]);
		}

		map[y][x - 1] = null;

		var path = new MotionPath().bezier(
			e.graphic.x - Elem.SIZE,
			e.graphic.y + Elem.SIZE,
			e.graphic.x - Elem.SIZE / 2,
			e.graphic.y - Elem.SIZE
		);

		var speed:Float = getElemTweenSpeedByDistance(Math.abs(GeomUtil.getDistance(
			{ x: e.graphic.x - Elem.SIZE, y: e.graphic.y + Elem.SIZE },
			{ x: e.graphic.x, y: e.graphic.y }
		))) * 2;

		Actuate.tween(e.graphic, speed, {
			rotation: e.graphic.rotation + Math.random() * Math.PI - Math.PI / 2,
			alpha: 0
		});

		Actuate.motionPath(e.graphic, speed, {
			x: path.x,
			y: path.y
		}).ease(Quad.easeOut).onUpdate(function(){
			e.graphic.x = e.graphic.x;
		}).onComplete(function(){
			e.graphic.remove();
			e = null;
		});
	}

	function shiftToRight(x:UInt, y:UInt)
	{
		var lastRightIndex:UInt = map[0].length - 1;
		for (i in x + 1...map[0].length)
			if (map[y][i] == null
				|| map[y][i].type == ElemType.Blocker
				|| map[y][i].type == ElemType.Empty
				|| map[y][i].type == ElemType.None
			){
				lastRightIndex = i - 1;
				break;
			}

		if (lastRightIndex == x) return;

		var e = map[y][lastRightIndex].clone();
		container.addChild(e.graphic);
		map[y][lastRightIndex].graphic.remove();

		var reverseIndex:UInt = lastRightIndex;
		for (i in x + 1...lastRightIndex)
		{
			map[y][reverseIndex] = map[y][reverseIndex - 1];
			map[y][reverseIndex].indexX++;
			map[y][reverseIndex].animationPath = [{ x: map[y][reverseIndex].indexX * Elem.SIZE, y: map[y][reverseIndex].graphic.y}];
			moveElemToPosition(map[y][reverseIndex]);
			reverseIndex--;
		}

		map[y][x + 1] = null;

		var path = new MotionPath().bezier(
			e.graphic.x + Elem.SIZE,
			e.graphic.y + Elem.SIZE,
			e.graphic.x + Elem.SIZE / 2,
			e.graphic.y - Elem.SIZE
		);

		var speed:Float = getElemTweenSpeedByDistance(Math.abs(GeomUtil.getDistance(
			{ x: e.graphic.x + Elem.SIZE, y: e.graphic.y + Elem.SIZE },
			{ x: e.graphic.x, y: e.graphic.y }
		))) * 2;

		Actuate.tween(e.graphic, speed, {
			rotation: e.graphic.rotation + Math.random() * Math.PI - Math.PI / 2,
			alpha: 0
		});

		Actuate.motionPath(e.graphic, speed, {
			x: path.x,
			y: path.y
		}).ease(Quad.easeOut).onUpdate(function(){
			e.graphic.x = e.graphic.x;
		}).onComplete(function(){
			e.graphic.remove();
			e = null;
		});
	}

	function swapRandomElemsByElem(targetA:Elem, targetB:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (targetA != null && targetB != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);

			var savedTargetBType = targetB.type;
			var e = triggerElem.clone();
			container.addChild(e.graphic);

			Actuate.tween(e.graphic, TweenConfig.RUSH_PREPARE_TIME, {
				x: e.graphic.x + 20
			}).ease(Quad.easeOut).onUpdate(function() {
				e.graphic.x = e.graphic.x;
			}).onComplete(function() {
				Actuate.tween(e.graphic, TweenConfig.RUSH_PREPARE_TIME, {
					x: e.graphic.x - 40
				}).ease(Quad.easeOut).onUpdate(function() {
					e.graphic.x = e.graphic.x;
				}).onComplete(function() {
					Actuate.tween(e.graphic, TweenConfig.RUSH_PREPARE_TIME, {
						x: e.graphic.x + 20
					}).ease(Quad.easeOut).onUpdate(function() {
						e.graphic.x = e.graphic.x;
					}).onComplete(function() {
						Actuate.tween(e.graphic, TweenConfig.RUSH_MOVE_TIME, {
							x: targetA.graphic.x + 10,
							y: targetA.graphic.y + 10,
						}).delay(TweenConfig.RUSH_DELAY_TIME).ease(Quad.easeOut).onUpdate(function() {
							e.graphic.x = e.graphic.x;
						}).onComplete(function() {
							targetA.graphic.visible = false;
							Actuate.tween(e.graphic, TweenConfig.RUSH_MOVE_TIME, {
								x: targetB.graphic.x + 10,
								y: targetB.graphic.y + 10,
							}).ease(Quad.easeOut).onUpdate(function() {
								e.graphic.x = e.graphic.x;
							}).onComplete(function() {
								targetB.type = targetA.type;
								activateEffect(targetB.graphic.x, targetB.graphic.y);
								Actuate.tween(e.graphic, TweenConfig.RUSH_MOVE_TIME, {
									x: targetA.graphic.x + 10,
									y: targetA.graphic.y + 10,
								}).ease(Quad.easeOut).onUpdate(function() {
									e.graphic.x = e.graphic.x;
								}).onComplete(function() {
									targetA.type = savedTargetBType;
									targetA.graphic.visible = true;
									activateEffect(targetA.graphic.x, targetA.graphic.y);

									e.graphic.remove();
									e = null;
								});
							});
						});
					});
				});
			});
		}
	}

	function jumpElemToElem(target:Elem, triggerElem:Elem, onComplete:Void->Void)
	{
		var e = triggerElem.clone();

		var path = new MotionPath().bezier(
			target.graphic.x,
			target.graphic.y,
			target.graphic.x + (triggerElem.graphic.x - target.graphic.x) / 2,
			target.graphic.y + (triggerElem.graphic.y - target.graphic.y) / 2 - 100
		);

		container.addChild(e.graphic);
		Actuate.tween(e.graphic, TweenConfig.JUMP_PREPARE_TIME, {
			scaleY: .8,
			y: e.graphic.y + 10
		}).ease(Quad.easeOut).onUpdate(function() {
			e.graphic.scaleY = e.graphic.scaleY;
		}).onComplete(function() {
			Actuate.tween(e.graphic, TweenConfig.JUMP_START_TIME, {
				scaleY: 1,
				y: e.graphic.y - 10
			}).ease(Quad.easeOut).onUpdate(function() {
				e.graphic.scaleY = e.graphic.scaleY;
			}).onComplete(function() {
				Actuate.motionPath(e.graphic, TweenConfig.JUMP_TIME, {
					x: path.x,
					y: path.y
				}).ease(Linear.easeNone).onUpdate(function() {
					e.graphic.scaleY = e.graphic.scaleY;
				}).onComplete(function(){
					e.graphic.remove();
					e = null;
					onComplete();
				});
			});
		});
	}

	function isNotMatchedElem(e:Elem):Bool
	{
		var count:UInt = 0;

		for (m in foundMatch)
			if (m.indexOf(e) > -1) return false;

		return true;
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
		return d / Elem.SIZE * TweenConfig.ELEM_FALL_TIME;
	}

	function getElemByPosition(p:SimplePoint):Elem
	{
		for (row in map)
		{
			for (e in row)
			{
				if (e == null) continue;

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