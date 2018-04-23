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
	var scoreUI:ScoreUI;
	var starsUI:StarsUI;
	var helpsUI:HelpsUI;

	var activeLayout:LayoutMode = null;

	public function new(
		parent:Sprite,
		gameModel:GameModel
	){
		super(parent);

		goalUI = new GoalUI(this, gameModel.elemGoals);
		movesUI = new MovesUI(this, gameModel.remainingMoves, gameModel.stars);
		scoreUI = new ScoreUI(this, gameModel.score);
		starsUI = new StarsUI(this, gameModel.stars);
		//helpsUI = new HelpsUI(this);
	}

	public function setLayoutMode(mode:LayoutMode)
	{
		if (activeLayout == mode) return;
		activeLayout = mode;

		movesUI.x = 30;
		movesUI.y = 30;

		starsUI.x = movesUI.x + 20;
		starsUI.y = movesUI.y + 160;

		goalUI.setLayoutMode(mode);

		if (mode == LayoutMode.Landscape)
		{
			goalUI.x = movesUI.x + 215;
			goalUI.y = movesUI.y + movesUI.getSize().height / 2 + 15;

			scoreUI.x = 2;
			scoreUI.y = 0;
		}
		else
		{
			goalUI.x = movesUI.x + movesUI.getSize().width / 2 + 15;
			goalUI.y = movesUI.y + 25;

			scoreUI.x = movesUI.x + goalUI.x + 90;
			scoreUI.y = movesUI.y + goalUI.y + 149;
		}
	}
}