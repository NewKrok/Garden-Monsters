package fe.game.ui;

import fe.game.GameLayout;
import fe.game.Help.HelpType;
import h2d.Flow;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hxd.Res;
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
	var secondaryContainer:Flow;

	var movesUi:MovesUI;
	var goalUi:GoalUI;
	var scoreUi:ScoreUI;
	var starsUi:StarsUI;
	var helpsUi:HelpsUI;
	var menuButton:BaseButton;

	var activeLayout:LayoutMode = null;

	public function new(
		parent:Sprite,
		openMenu:Void->Void,
		gameModel:GameModel,
		activateHelp:HelpType->Void
	){
		super(parent);

		secondaryContainer = new Flow(this);
		secondaryContainer.isVertical = false;
		secondaryContainer.verticalAlign = FlowAlign.Middle;
		secondaryContainer.horizontalAlign = FlowAlign.Middle;

		menuButton = new BaseButton(secondaryContainer, {
			onClick: function(_){ openMenu(); },
			baseGraphic: Res.image.game.ui.menu_button.toTile(),
			overGraphic: Res.image.game.ui.menu_button_over.toTile()
		});
		menuButton.setScale(AppConfig.GAME_BITMAP_SCALE);

		gameModel.isPossibleToPlay.observe().bind(function(v){
			menuButton.isEnabled = v;
		});

		goalUi = new GoalUI(this, gameModel.elemGoals);
		movesUi = new MovesUI(this, gameModel.remainingMoves);
		scoreUi = new ScoreUI(this, gameModel.score);
		starsUi = new StarsUI(this, gameModel.stars, gameModel.starPercentage);
		helpsUi = new HelpsUI(secondaryContainer, activateHelp, gameModel.isPossibleToPlay, cast gameModel.helps);

		secondaryContainer.reflow();
	}

	public function onMovesIncreased():Void movesUi.onMovesIncreased();

	public function setLayoutMode(mode:LayoutMode):Void
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

		var secondaryContainerSize = secondaryContainer.getSize();

		if (mode == LayoutMode.Landscape)
		{
			secondaryContainer.isVertical = true;
			secondaryContainer.reflow();
			var secondaryContainerSize = secondaryContainer.getSize();

			secondaryContainer.x = HppG.stage2d.width / scaleX - secondaryContainerSize.width - 85;
			secondaryContainer.y = 10;
		}
		else
		{
			secondaryContainer.isVertical = false;
			secondaryContainer.reflow();
			var secondaryContainerSize = secondaryContainer.getSize();

			secondaryContainer.x = HppG.stage2d.width / scaleX / 2 - secondaryContainerSize.width / 2;
			secondaryContainer.y = HppG.stage2d.height / scaleX - secondaryContainerSize.height - 25;
		}
	}
}