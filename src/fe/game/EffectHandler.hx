package fe.game;

import h2d.Bitmap;
import h2d.Layers;
import h2d.Particles;
import h2d.Tile;
import hxd.Res;
import motion.Actuate;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EffectHandler
{
	static public inline var MONSTER_MATCH_EFFECT_DURATION:Float = 1;

	public var view(default, null):Layers;

	var particles:Particles;

	public function new()
	{
		particles = new Particles(view = new Layers());
	}

	public function addMonsterMatchEffect(x:Float, y:Float):Void
	{
		addExplosionLight(x, y);
		addStarEffect(x, y);
	}

	function addStarEffect(x:Float, y:Float):Void
	{
		var g = new ParticleGroup(particles);

		g.sizeRand = .3;
		g.gravity = 1;
		g.life = MONSTER_MATCH_EFFECT_DURATION / 2 + .1;
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
		g.texture = Res.image.game.effect.star.toTexture();
		g.dx = cast x;
		g.dy = cast y;

		particles.addGroup(g);

		Actuate.timer(MONSTER_MATCH_EFFECT_DURATION).onComplete(function() {
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

		Actuate.tween(image, MONSTER_MATCH_EFFECT_DURATION, {
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

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}
}