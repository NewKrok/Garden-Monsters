package fe.game;

import h2d.Layers;
import h2d.Particles;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EffectHandler
{
	var parent:Layers;
	var particles:Particles;

	public function new(s2d:Layers)
	{
		this.parent = s2d;

		particles = new Particles(s2d);
	}

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}
}