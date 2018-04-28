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

	public function new(
		parent:Sprite,
		gameModel:GameModel
	){
		super(parent);

		noMoreMovesDialog = new NoMoreMovesDialog(this);
		noMoreMovesDialog.visible = false;
	}

	public function openNoMoreMovesDialog():Void noMoreMovesDialog.open();
	public function closeNoMoreMovesDialog():Void noMoreMovesDialog.close();
}