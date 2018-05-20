package fe.game.dialog;

import fe.game.GameModel;
import h2d.Layers;
import h2d.Sprite;
/**
 * ...
 * @author Krisztian Somoracz
 */
class GameDialog extends Layers
{
	var smallWarningDialog:SmallWarningDialog;
	var noMoreMovesDialog:NoMoreMovesDialog;
	var goalsDialog:GoalsDialog;

	public function new(
		parent:Sprite,
		gameModel:GameModel
	){
		super(parent);

		smallWarningDialog = new SmallWarningDialog(this);
		smallWarningDialog.visible = false;

		noMoreMovesDialog = new NoMoreMovesDialog(this);
		noMoreMovesDialog.visible = false;

		goalsDialog = new GoalsDialog(this, gameModel.levelId, gameModel.elemGoals, gameModel.playersBestScore);
		goalsDialog.visible = false;
	}

	public function openSmallWarningDialog(titleText:String, descriptionText:String):Void
	{
		smallWarningDialog.updateData(titleText, descriptionText);
		smallWarningDialog.open();
	}
	public function closeSmallWarningDialog():Void smallWarningDialog.close();

	public function openNoMoreMovesDialog():Void noMoreMovesDialog.open();
	public function closeNoMoreMovesDialog():Void noMoreMovesDialog.close();

	public function openGoalsDialog():Void goalsDialog.open();
	public function closeGoalsDialog():Void goalsDialog.close();
}