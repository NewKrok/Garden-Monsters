package fe.game;

import fe.game.Elem;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Particles;
import h2d.Tile;
import h3d.mat.Texture;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Res;
import motion.Actuate;
import motion.MotionPath;
import motion.easing.Quad;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EffectHandler
{
	static public inline var EXPLODING_EFFECT_DURATION:Float = 1;
	static public inline var ICE_BREAK_EFFECT_DURATION:Float = 1;
	static public inline var SPLASH_EFFECT_DURATION:Float = .6;
	static public inline var LIGHT_FOCUS_EFFECT_DURATION:Float = 1;

	public var view(default, null):Layers;

	var particles:Particles;

	public function new()
	{
		particles = new Particles(view = new Layers());
	}

	public function addMonsterMatchEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.star.toTexture());
	}

	public function addElem1StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_1_light.toTile());
	}

	public function addElem1ActivateEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.elem_1_light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.elem_1.toTexture());
	}

	public function addElem2StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_2_light.toTile());
	}

	public function addElem2ActivateEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.elem_2_light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.elem_2.toTexture(), 60);
	}

	public function addElem3StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_3_light.toTile());
	}

	public function addElem3ActivateEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.elem_3_light.toTile());
		addSplashEffect(x, y, Res.image.game.effect.elem_3_splash.toTile());
	}

	public function addElem4StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_4_light.toTile());
	}

	public function addElem4ActivateEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.elem_4_light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.elem_4.toTexture(), 60);
	}

	public function addElem5StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_5_light.toTile());
	}

	public function addElem5ActivateEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.elem_5_light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.elem_5.toTexture(), 60);
	}

	public function addElem7StartEffect(x:Float, y:Float):Void
	{
		addFocusLightEffect(x, y, Res.image.game.effect.elem_7_light.toTile());
	}

	public function addElem7Effect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y, Res.image.game.effect.light.toTile());
		addExplosionEffect(x, y, Res.image.game.effect.elem_7.toTexture());
	}

	function addExplosionEffect(x:Float, y:Float, texture:Texture, speed:Float = 40):Void
	{
		var g = new ParticleGroup(particles);

		g.sizeRand = .5;
		g.gravity = 1;
		g.life = EXPLODING_EFFECT_DURATION / 2 + .1;
		g.speed = speed;
		g.emitDelay = 0;
		g.nparts = 10;
		g.emitMode = PartEmitMode.Point;
		g.emitDist = 30;
		g.emitLoop = false;
		g.speedRand = 3;
		g.fadeIn = 0;
		g.fadeOut = .5;
		g.rotSpeed = Math.PI / 5;
		g.rotSpeedRand = Math.PI / 5;
		g.texture = texture;
		g.dx = cast x;
		g.dy = cast y;

		particles.addGroup(g);

		Actuate.timer(EXPLODING_EFFECT_DURATION).onComplete(function() {
			removeEffect(g);
		});
	}

	function addSplashEffect(x:Float, y:Float, tile:Tile):Void
	{
		var image:Bitmap = new Bitmap(tile, view);
		image.x = x;
		image.y = y;
		image.rotation = Math.random() * (Math.PI / 4);
		image.setScale(.4);
		image.alpha = .9;

		var tile:Tile = image.tile;
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		Actuate.tween(image, SPLASH_EFFECT_DURATION, {
			scaleX: 1.4, scaleY: 1.4, rotation: Math.random() * (Math.PI / 4)
		}).onUpdate(function(){
			image.setScale(image.scaleX);
		}).onComplete(function(){
			Actuate.tween(image, .4, {
				scaleX: 2, scaleY: 2, alpha: 0, rotation: Math.random() * (Math.PI / 4)
			}).onUpdate(function(){
				image.setScale(image.scaleX);
			}).onComplete(function(){
				removeBitmap(image);
			});
		});
	}

	public function addIceBreakEffect(x:Float, y:Float):Void
	{
		var positions:Array<SimplePoint> = [{ x: -1, y: -1}, { x: 1, y: -1}, { x: -1, y: 1}, { x: 1, y: 1}];
		var tile:Tile = Res.image.game.effect.ice_piece.toTile();
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		for (i in 0...4)
		{
			var image:Bitmap = new Bitmap(tile, view);
			image.x = x + positions[i].x * tile.width / 2;
			image.y = y + positions[i].y * tile.height / 2;
			image.rotation = Math.floor(Math.random() * 4) * (Math.PI / 2);

			var path = new MotionPath().bezier(
				image.x + positions[i].x * (tile.width / 2),
				image.y + positions[i].y * tile.height + Math.random() * 50 + 50,
				image.x + positions[i].x * tile.width,
				image.y + positions[i].y * tile.height
			);

			Actuate.tween(image, ICE_BREAK_EFFECT_DURATION, {
				rotation: image.rotation + Math.random() * Math.PI - Math.PI / 2,
				alpha: 0
			});

			Actuate.motionPath(image, ICE_BREAK_EFFECT_DURATION, {
				x: path.x,
				y: path.y
			}).ease(Quad.easeOut).onUpdate(function(){
				image.x = image.x;
			}).onComplete(function(){
				removeBitmap(image);
			});
		}
	}

	function addExplosionLight(x:Float, y:Float, tile:Tile)
	{
		var image:Bitmap = new Bitmap(tile, view);
		image.x = x;
		image.y = y;
		image.setScale(.8);

		var tile:Tile = image.tile;
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		Actuate.tween(image, EXPLODING_EFFECT_DURATION, {
			scaleX: 1.5, scaleY: 1.5, alpha: 0
		}).onUpdate(function(){
			image.setScale(image.scaleX);
		}).onComplete(function(){
			removeBitmap(image);
		});
	}

	function addFocusLightEffect(x:Float, y:Float, tile:Tile)
	{
		var image:Bitmap = new Bitmap(tile, view);
		image.x = x;
		image.y = y;
		image.setScale(3);

		var tile:Tile = image.tile;
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		Actuate.tween(image, LIGHT_FOCUS_EFFECT_DURATION, {
			scaleX: .5, scaleY: .5, alpha: 0
		}).onUpdate(function(){
			image.setScale(image.scaleX);
		}).onComplete(function(){
			removeBitmap(image);
		});
	}

	function removeBitmap(img:Bitmap)
	{
		img.remove();
	}

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}
}