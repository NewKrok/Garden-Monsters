package fe.game.ui;
import fe.game.GameLayout;
import fe.game.Help.HelpType;
import hpp.heaps.HppG;

import fe.game.GameLayout.LayoutMode;
import fe.game.GameModel;
import h2d.Layers;
import h2d.Sprite;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameUI extends Layers
{
	var movesUi:MovesUI;
	var goalUi:GoalUI;
	var scoreUi:ScoreUI;
	var starsUi:StarsUI;
	var helpsUi:HelpsUI;

	var activeLayout:LayoutMode = null;

	public function new(
		parent:Sprite,
		gameModel:GameModel,
		activateHelp:HelpType->Void
	){
		super(parent);

		goalUi = new GoalUI(this, gameModel.elemGoals);
		movesUi = new MovesUI(this, gameModel.remainingMoves);
		scoreUi = new ScoreUI(this, gameModel.score);
		starsUi = new StarsUI(this, gameModel.stars, gameModel.starPercentage);
		helpsUi = new HelpsUI(this, activateHelp, cast gameModel.helps);
	}

	public function setLayoutMode(mode:LayoutMode)
	{
		if (activeLayout == mode)
		{

		}
		else
		{
			activeLayout = mode;

			movesUi.x = 30;
			movesUi.y = 30;

			starsUi.x = movesUi.x + 27;
			starsUi.y = movesUi.y + 160;

			goalUi.setLayoutMode(mode);
			helpsUi.setLayoutMode(mode);

			if (mode == LayoutMode.Landscape)
			{
				goalUi.x = movesUi.x + 215;
				goalUi.y = movesUi.y + movesUi.getSize().height / 2 + 15;

				scoreUi.x = 2;
				scoreUi.y = 0;
			}
			else
			{
				goalUi.x = movesUi.x + movesUi.getSize().width / 2 + 15;
				goalUi.y = movesUi.y + 25;

				scoreUi.x = movesUi.x + goalUi.x + 220;
				scoreUi.y = movesUi.y + goalUi.y + 149;


			}
		}

		if (mode == LayoutMode.Landscape)
		{
			helpsUi.x = HppG.stage2d.width / scaleX - helpsUi.getSize().width / 2 + 30;
			helpsUi.y = HppG.stage2d.height / 2 / scaleX - helpsUi.getSize().height / 2 + 10;
		}
		else
		{
			helpsUi.x = HppG.stage2d.width / 2 / scaleX - helpsUi.getSize().width / 2 + 10;
			helpsUi.y = HppG.stage2d.height / scaleX - helpsUi.getBounds().height / scaleX - 25;
		}
	}
}