package fe.game.ui;

import fe.Layout.LayoutMode;
import fe.game.GameModel;
import h2d.Layers;
import h2d.Sprite;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameUI extends Layers
{
	var movesUI:MovesUI;
	var goalUI:GoalUI;
	var helpsUI:HelpsUI;

	var activeLayout:LayoutMode = null;

	public function new(parent:Sprite, gameModel:GameModel)
	{
		super(parent);

		goalUI = new GoalUI(this, gameModel.elemGoals);
		movesUI = new MovesUI(this, gameModel.remainingMoves);
		//helpsUI = new HelpsUI(this);
	}

	public function setLayoutMode(mode:LayoutMode)
	{
		if (activeLayout == mode) return;
		activeLayout = mode;

		goalUI.setLayoutMode(mode);

		if (mode == LayoutMode.Landscape)
		{
			goalUI.x = 215;
			goalUI.y = movesUI.getSize().height / 2 + 15;
		}
		else
		{
			goalUI.x = movesUI.getSize().width / 2 + 15;
			goalUI.y = 25;
		}
	}
}