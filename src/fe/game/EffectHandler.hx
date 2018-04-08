package fe.game;

import h2d.Layers;
import h2d.Particles;
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
		g.fadeOut = 0;
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

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}
}