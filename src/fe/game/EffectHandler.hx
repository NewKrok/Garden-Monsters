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

/**
 * ...
 * @author Krisztian Somoracz
 */
class EffectHandler
{
	static public inline var EXPLODING_EFFECT_DURATION:Float = 1;

	public var view(default, null):Layers;

	var particles:Particles;

	public function new()
	{
		particles = new Particles(view = new Layers());
	}

	public function addMonsterMatchEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y);
		addExplosionEffect(x, y, Res.image.game.effect.star.toTexture());
	}

	function addExplosionEffect(x:Float, y:Float, texture:Texture):Void
	{
		var g = new ParticleGroup(particles);

		g.sizeRand = .3;
		g.gravity = 1;
		g.life = EXPLODING_EFFECT_DURATION / 2 + .1;
		g.speed = 40;
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

	function addExplosionLight(x:Float, y:Float)
	{
		var image:Bitmap = new Bitmap(Res.image.game.effect.light.toTile(), view);
		image.x = x;
		image.y = y;
		image.setScale(.5);

		var tile:Tile = image.tile;
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		Actuate.tween(image, EXPLODING_EFFECT_DURATION, {
			scaleX: 1, scaleY: 1, alpha: 0
		}).onUpdate(function(){
			image.setScale(image.scaleX);
		}).onComplete(function(){
			removeExplosionLight(image);
		});
	}

	function removeExplosionLight(img:Bitmap)
	{
		img.remove();
	}

	public function addElem1Effect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y);
		addExplosionEffect(x, y, Res.image.game.effect.elem_1.toTexture());
	}

	public function addElem3Effect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y);
		addExplosionEffect(x, y, Res.image.game.effect.elem_3.toTexture());
	}

	public function addElem7Effect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y);
		addExplosionEffect(x, y, Res.image.game.effect.elem_7.toTexture());
	}

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}
}