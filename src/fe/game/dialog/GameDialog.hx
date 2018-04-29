package fe.game.dialog;

import h2d.Layers;
import h2d.Sprite;
/**
 * ...
 * @author Krisztian Somoracz
 */
class GameDialog extends Layers
{
	var noMoreMovesDialog:NoMoreMovesDialog;
	var goalsDialog:GoalsDialog;

	public function new(
		parent:Sprite,
		gameModel:GameModel
	){
		super(parent);

		noMoreMovesDialog = new NoMoreMovesDialog(this);
		noMoreMovesDialog.visible = false;

		goalsDialog = new GoalsDialog(this, gameModel.levelId, gameModel.elemGoals, gameModel.playersBestScore);
		goalsDialog.visible = false;
	}

	public function openNoMoreMovesDialog():Void noMoreMovesDialog.open();
	public function closeNoMoreMovesDialog():Void noMoreMovesDialog.close();

	public function openGoalsDialog():Void goalsDialog.open();
	public function closeGoalsDialog():Void goalsDialog.close();
}