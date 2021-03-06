package fe.game;

import fe.game.Board.Map;
import fe.game.Elem.ElemType;
import fe.game.util.BoardHelper;
import fe.game.util.TweenHelper;
import format.abc.Data.IName;
import h2d.Bitmap;
import h2d.Layers;
import h2d.filter.ColorMatrix;
import h3d.Matrix;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Res;
import motion.Actuate;
import motion.MotionPath;
import motion.easing.Back;
import motion.easing.Linear;
import motion.easing.Quad;

using hpp.util.ArrayUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SkillHandler
{
	var map:Map;
	var foundMatch:Array<Array<Elem>>;

	var container:Layers;
	var availableElemTypes:Array<ElemType>;
	var effectHandler:EffectHandler;
	var moveElemToPosition:Elem->Void;
	var onElemCollectCallback:ElemType->Void;

	public function new() {}

	public function init(
		container:Layers,
		availableElemTypes:Array<ElemType>,
		effectHandler:EffectHandler,
		map:Map,
		moveElemToPosition:Elem->Void,
		onElemCollectCallback:ElemType-> Void
	){
		this.container = container;
		this.availableElemTypes = availableElemTypes;
		this.effectHandler = effectHandler;
		this.map = map;
		this.moveElemToPosition = moveElemToPosition;
		this.onElemCollectCallback = onElemCollectCallback;

		foundMatch = [];
	}

	public function update(map:Map, foundMatch:Array<Array<Elem>>)
	{
		this.map = map;
		this.foundMatch = foundMatch;
	}

	public function handleElemSkill(match:Array<Elem>):Float
	{
		var longestSkillTime:Float = 1;

		var type = match[0].type;
		var matchClone = match.concat([]);
		while (type == ElemType.Elem6) type = cast(1 + Math.floor(Math.random() * 7));

		if (BoardHelper.isFruitElem(match[0]))
		{
			var selectedElem = matchClone.random();

			if (match.length < 4) longestSkillTime = .2;
			else if (match.length == 4)
			{
				longestSkillTime = 1.2;
				removeNearbyElemsByElem(
					selectedElem,
					effectHandler.addBombEffect,
					effectHandler.addMonsterMatchEffect,
					longestSkillTime
				);
			}
			else if (match.length > 4)
			{
				longestSkillTime = .4;
				removeAllSameTypeElemsByElem(
					selectedElem,
					effectHandler.addVortexEffect,
					effectHandler.addMonsterMatchEffect
				);
			}
		}
		else
		{
			for (i in 0...match.length - 2)
			{
				var selectedElem = matchClone.random();
				matchClone.remove(selectedElem);

				switch(type)
				{
					case ElemType.Elem1:
						removeElemByElem(
							getRandomNearbyNotMatchedPlayableElem(match),
							selectedElem,
							effectHandler.addElem1StartEffect,
							effectHandler.addElem1ActivateEffect
						);

					case ElemType.Elem2:
						freezeElemByElem(
							getRandomNearbyNotMatchedPlayableElem(match),
							selectedElem,
							effectHandler.addElem2StartEffect,
							effectHandler.addElem2ActivateEffect
						);

					case ElemType.Elem3:
						changeElemTypeByElem(
							getRandomNearbyNotMatchedPlayableElem(match),
							selectedElem,
							effectHandler.addElem3StartEffect,
							effectHandler.addElem3ActivateEffect
						);

					case ElemType.Elem4:
						shiftRow(
							getRandomNearbyNotMatchedPlayableElem(match),
							selectedElem,
							effectHandler.addElem4StartEffect,
							effectHandler.addElem4ActivateEffect
						);

					case ElemType.Elem5:
						removeRandomElemByElem(
							getRandomNotMatchedPlayableElem(),
							selectedElem,
							effectHandler.addElem5StartEffect,
							effectHandler.addElem5ActivateEffect
						);

					case ElemType.Elem7:
						swapRandomElemsByElem(
							getRandomNotMatchedPlayableElem(),
							getRandomNotMatchedPlayableElem(),
							selectedElem,
							effectHandler.addElem7StartEffect,
							effectHandler.addElem7Effect
						);

					case _: longestSkillTime = .2;
				}
			}
		}

		return longestSkillTime;
	}

	public function addBomb(onComplete:Void->Void):Void
	{
		var target = BoardHelper.getRandomPlayableElem(map);

		removeNearbyElemsByElem(
			target,
			effectHandler.addBombEffect,
			effectHandler.addMonsterMatchEffect,
			1.2
		);

		onElemCollectCallback(target.type);
		effectHandler.addMonsterMatchEffect(target.graphic.x, target.graphic.y);
		map[target.indexY][target.indexX] = null;
		target.graphic.remove();
		target = null;

		Actuate.timer(1.2).onComplete(onComplete);
	}

	public function addHotPeppers(onComplete:Void->Void):Void
	{
		var monsters = BoardHelper.getMonsters(map).shuffle().splice(0, 3);

		var m = new Matrix();
		m.identity();
		m.colorGain(0xFF0000, .8);
		var colorFilter = new ColorMatrix(m);

		for (m in monsters)
		{
			effectHandler.addHotPepperEffect(m.graphic.x, m.graphic.y);
			map[m.indexY][m.indexX] = null;

			Actuate.timer(.7).onComplete(function(){
				m.graphic.filter = colorFilter;
			});

			Actuate.timer(1.2).onComplete(function(){
				effectHandler.addMonsterMatchEffect(m.graphic.x, m.graphic.y);
				onElemCollectCallback(m.type);
				m.graphic.remove();
				m = null;
			});
		}

		Actuate.timer(1.5).onComplete(onComplete);
	}

	public function collectRandomFruits(onComplete:Void->Void):Void
	{
		var fruits = BoardHelper.getFruits(map).shuffle().splice(0, 3);
		var index:Int = 0;

		for (f in fruits)
		{
			var box = new Bitmap(Res.image.game.block_base.toTile());
			box.setScale(AppConfig.GAME_BITMAP_SCALE);
			box.x = f.graphic.x - box.getSize().width / 2;
			box.y = f.graphic.y - box.getSize().height / 2;
			box.alpha = 0;
			container.addChild(box);

			var clone = f.clone();
			container.addChild(clone.graphic);

			onElemCollectCallback(f.type);
			map[f.indexY][f.indexX] = null;
			f.graphic.remove();
			f = null;

			Actuate.tween(box, .6, {
				alpha: 1
			}).delay(index * .2);

			Actuate.tween(clone.graphic, .6, {
				scaleX: clone.graphic.scaleX - .2,
				scaleY: clone.graphic.scaleY - .2,
			}).delay(index * .2).onUpdate(function(){
				clone.graphic.scaleX = clone.graphic.scaleX;
			}).onComplete(function(){
				Actuate.timer(.2).onComplete(function(){
					effectHandler.addMonsterMatchEffect(clone.graphic.x, clone.graphic.y);
				});
				Actuate.tween(clone.graphic, .6, {
					scaleX: clone.graphic.scaleX + .4,
					scaleY: clone.graphic.scaleY + .4,
					alpha: 0
				}).delay(.1).onUpdate(function(){
					clone.graphic.scaleX = clone.graphic.scaleX;
				}).onComplete(function(){
					clone.graphic.remove();
					clone = null;
					box.remove();
					box = null;
				});
			});

			index++;
		}

		Actuate.timer(1.5).onComplete(onComplete);
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

	function isNotMatchedElem(e:Elem):Bool
	{
		var count:UInt = 0;

		for (m in foundMatch)
			if (m.indexOf(e) > -1) return false;

		return true;
	}

	function removeNearbyElemsByElem(triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void, delay:Float)
	{
		var nearbyElems:Array<SimplePoint> = [
			{ x: -1, y: -1 }, { x: -1, y: 0 }, { x: -1, y: 1 },
			{ x: 0,  y: -1 }, 				   { x: 0,  y: 1 },
			{ x: 1,  y: -1 }, { x: 1,  y: 0 }, { x: 1,  y: 1 }
		];

		if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);

		Actuate.timer(delay).onComplete(function(){
			for (d in nearbyElems)
			{
				if (map[cast triggerElem.indexY + d.y] == null) continue;

				var selectedElem = map[cast triggerElem.indexY + d.y][cast triggerElem.indexX + d.x];

				if (
					selectedElem != null
					&& selectedElem.type != ElemType.Blocker
					&& selectedElem.type != ElemType.Empty
					&& selectedElem.type != ElemType.None
					&& isNotMatchedElem(selectedElem)
				)
				{
					onElemCollectCallback(selectedElem.type);
					activateEffect(selectedElem.graphic.x, selectedElem.graphic.y);
					map[selectedElem.indexY][selectedElem.indexX] = null;
					selectedElem.graphic.remove();
					selectedElem = null;
				}
			}
		});
	}

	function removeAllSameTypeElemsByElem(triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		for (row in map)
			for (e in row)
			{
				if (e == null) continue;

				if (
					e.type == triggerElem.type
					&& isNotMatchedElem(e)
				)
				{
					var clone = e.clone();
					container.addChild(clone.graphic);
					startEffect(clone.graphic.x, clone.graphic.y);

					map[e.indexY][e.indexX] = null;
					e.graphic.remove();
					e = null;

					Actuate.tween(clone.graphic, .2, {
						scaleX: .8,
						scaleY: .8,
					}).ease(Quad.easeOut).onUpdate(function() {
						clone.graphic.scaleY = clone.graphic.scaleY;
					}).onComplete(function() {
						Actuate.tween(clone.graphic, .4, {
							scaleX: 1.2,
							scaleY: 1.2,
							alpha: 0
						}).ease(Quad.easeOut).onUpdate(function() {
							clone.graphic.scaleY = clone.graphic.scaleY;
						}).onComplete(function() {
							onElemCollectCallback(clone.type);
							activateEffect(clone.graphic.x, clone.graphic.y);
							clone.graphic.remove();
							clone = null;
						});
					});
				}
			}
	}

	function removeElemByElem(target:Elem, triggerElem:Elem, startEffect:Float->Float->Void, activateEffect:Float->Float->Void)
	{
		if (target != null)
		{
			if (startEffect != null) startEffect(triggerElem.graphic.x, triggerElem.graphic.y);
			jumpElemToElem(target, triggerElem, function(){
				onElemCollectCallback(target.type);
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
						onElemCollectCallback(target.type);
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
				target.type = BoardHelper.createRandomElemType(availableElemTypes);
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

		var speed:Float = TweenHelper.getElemTweenSpeedByDistance(Math.abs(GeomUtil.getDistance(
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

		var speed:Float = TweenHelper.getElemTweenSpeedByDistance(Math.abs(GeomUtil.getDistance(
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
}