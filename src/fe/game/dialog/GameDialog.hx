package fe.game.dialog;

import fe.common.BaseDialog;
import fe.game.GameModel;
import h2d.Graphics;
import h2d.Layers;
import h2d.Sprite;
import motion.Actuate;
import motion.easing.Linear;
/**
 * ...
 * @author Krisztian Somoracz
 */
class GameDialog extends Layers
{
	var background:Graphics;

	var smallWarningDialog:SmallWarningDialog;
	var noMoreMovesDialog:NoMoreMovesDialog;
	var goalsDialog:GoalsDialog;

	var dialogWrapper:Layers;
	var dialogs:Array<BaseDialog> = [];

	public function new(
		parent:Sprite,
		gameModel:GameModel
	){
		super(parent);

		background = new Graphics(this);
		dialogWrapper = new Layers(this);

		smallWarningDialog = new SmallWarningDialog(dialogWrapper);
		dialogs.push(smallWarningDialog);

		noMoreMovesDialog = new NoMoreMovesDialog(dialogWrapper);
		dialogs.push(noMoreMovesDialog);

		goalsDialog = new GoalsDialog(dialogWrapper, gameModel.levelId, gameModel.elemGoals, gameModel.playersBestScore);
		dialogs.push(goalsDialog);

		for (d in dialogs) d.visible = false;
	}

	public function openSmallWarningDialog(titleText:String, descriptionText:String):Void
	{
		showBackground();
		smallWarningDialog.updateData(titleText, descriptionText);
		smallWarningDialog.open();
	}
	public function closeSmallWarningDialog():Void { hideBackground(); smallWarningDialog.close(); };

	public function openNoMoreMovesDialog():Void { showBackground(); noMoreMovesDialog.open(); };
	public function closeNoMoreMovesDialog():Void { hideBackground(); noMoreMovesDialog.close(); };

	public function openGoalsDialog():Void { showBackground();  goalsDialog.open(); }
	public function closeGoalsDialog():Void { hideBackground();  goalsDialog.close(); }

	function showBackground()
	{
		background.alpha = 0;
		Actuate.tween(background, .5, { alpha: 1 }).ease(Linear.easeNone);
	}

	function hideBackground()
	{
		Actuate.tween(background, .5, { alpha: 0 }).ease(Linear.easeNone);
	}

	public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, width, height);
		background.endFill();

		dialogWrapper.x = width / 2 / scaleX;
		dialogWrapper.y = height / 2 / scaleY;
	}
}