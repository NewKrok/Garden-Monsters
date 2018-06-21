package fe.game.ui;

import h2d.Bitmap;
import h2d.Layers;
import h2d.Mask;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarsUI extends Layers
{
	var leftStar:Bitmap;
	var leftStarInactive:Bitmap;
	var rightStar:Bitmap;
	var rightStarInactive:Bitmap;
	var middleStar:Bitmap;
	var middleStarInactive:Bitmap;

	var leftStarMask:Mask;
	var rightStarMask:Mask;
	var middleStarMask:Mask;

	public function new(parent, stars:Observable<UInt>, starPercentage:Observable<Float>)
	{
		super(parent);

		leftStarInactive = new Bitmap(Res.image.common.ui.stars_left_inactive.toTile(), this);
		leftStarInactive.smooth = true;
		leftStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		leftStarMask = new Mask(cast leftStarInactive.getSize().width, cast leftStarInactive.getSize().height, this);
		leftStar = new Bitmap(Res.image.common.ui.stars_left.toTile(), leftStarMask);
		leftStar.smooth = true;
		leftStar.setScale(AppConfig.GAME_BITMAP_SCALE);

		rightStarInactive = new Bitmap(Res.image.common.ui.stars_right_inactive.toTile(), this);
		rightStarInactive.smooth = true;
		rightStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		rightStarMask = new Mask(cast rightStarInactive.getSize().width, cast rightStarInactive.getSize().height, this);
		rightStar = new Bitmap(Res.image.common.ui.stars_right.toTile(), rightStarMask);
		rightStar.smooth = true;
		rightStar.setScale(AppConfig.GAME_BITMAP_SCALE);

		middleStarInactive = new Bitmap(Res.image.common.ui.stars_middle_inactive.toTile(), this);
		middleStarInactive.smooth = true;
		middleStarInactive.setScale(AppConfig.GAME_BITMAP_SCALE);
		middleStarMask = new Mask(cast leftStarInactive.getSize().width, cast leftStarInactive.getSize().height, this);
		middleStar = new Bitmap(Res.image.common.ui.stars_middle.toTile(), middleStarMask);
		middleStar.smooth = true;
		middleStar.setScale(AppConfig.GAME_BITMAP_SCALE);

		leftStarMask.height = 0;
		leftStarMask.y = leftStarInactive.getSize().height;
		leftStar.y = leftStarMask.y;
		rightStarMask.height = 0;
		rightStarMask.y = rightStarInactive.getSize().height;
		rightStar.y = rightStarMask.y;
		middleStarMask.height = 0;
		middleStarMask.y = middleStarInactive.getSize().height;
		middleStar.y = middleStarMask.y;

		starPercentage.bind(function(v) {
			if (stars.value == 0 || (stars.value > 0 && leftStarMask.y != 0))
			{
				Actuate.stop(leftStarMask);
				Actuate.tween(leftStarMask, .3, {
					height: cast leftStarInactive.getSize().height * (stars.value == 0 ? v : 1),
					y: leftStarInactive.getSize().height - leftStarMask.height
				}).onUpdate(function(){
					leftStarMask.y = leftStarMask.y;
					leftStar.y = -leftStarMask.y;
				}).ease(Linear.easeNone);
			}

			if (stars.value == 1 || (stars.value > 1 && rightStarMask.y != 0))
			{
				Actuate.stop(rightStarMask);
				Actuate.tween(rightStarMask, .3, {
					height: cast rightStarInactive.getSize().height * (stars.value == 1 ? v : 1),
					y: rightStarInactive.getSize().height - rightStarMask.height
				}).onUpdate(function(){
					rightStarMask.y = rightStarMask.y;
					rightStar.y = -rightStarMask.y;
				}).ease(Linear.easeNone);
			}

			if (stars.value == 2 || (stars.value > 2 && middleStarMask.y != 0))
			{
				Actuate.stop(middleStarMask);
				Actuate.tween(middleStarMask, .3, {
					height: cast middleStarInactive.getSize().height * (stars.value == 2 ? v : 1),
					y: middleStarInactive.getSize().height - middleStarMask.height
				}).onUpdate(function(){
					middleStarMask.y = middleStarMask.y;
					middleStar.y = -middleStarMask.y;
				}).ease(Linear.easeNone);
			}
		});
	}
}