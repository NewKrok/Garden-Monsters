package fe.game;

import fe.game.Background;
import fe.game.Elem;
import fe.game.dialog.GameDialog;
import fe.game.ui.GameUI;
import h2d.Interactive;
import h2d.Layers;
import hpp.heaps.Base2dStage;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameLayout
{
	static var gameContainerDefaultWidth = Elem.SIZE * 8;
	static var gameContainerDefaultHeight = Elem.SIZE * 8;
	static inline var gameContainerLandscapeXOffset = 8;
	static inline var gameContainerLandscapeYOffset = 8;
	static inline var gameContainerLandscapeHorizontalMinPadding = 260;
	static inline var gameContainerLandscapeVerticalMinPadding = 50;
	static inline var gameContainerPortraitXOffset = 8;
	static inline var gameContainerPortraitYOffset = 25;
	static inline var gameContainerPortraitHorizontalMinPadding = 23;
	static inline var gameContainerPortraitVerticalMinPadding = 280;

	var mode:LayoutMode = LayoutMode.Landscape;
	var stage:Base2dStage;

	var background:Background;
	var gameContainer:Layers;
	var interactiveArea:Interactive;
	var gameUI:GameUI;
	var gameDialog:GameDialog;

	public function new(
		stage:Base2dStage,
		background:Background,
		gameContainer:Layers,
		interactiveArea:Interactive,
		gameUI:GameUI,
		gameDialog:GameDialog
	){
		this.stage = stage;
		this.background = background;
		this.gameContainer = gameContainer;
		this.interactiveArea = interactiveArea;
		this.gameUI = gameUI;
		this.gameDialog = gameDialog;
	}

	public function update(width:UInt, height:UInt):Void
	{
		calculateLayoutMode(width, height);

		var widthRatio = stage.width / stage.defaultWidth;
		var heightRatio = stage.height / stage.defaultHeight;

		background.onResize(width, height, widthRatio);

		var gameContainerMaxWidth;
		var gameContainerMaxHeight;
		if (mode == LayoutMode.Landscape)
		{
			gameContainerMaxWidth = stage.width - gameContainerLandscapeHorizontalMinPadding * 2 * heightRatio;
			gameContainerMaxHeight = stage.height - gameContainerLandscapeVerticalMinPadding * 2 * heightRatio;
		}
		else
		{
			gameContainerMaxWidth = stage.width - gameContainerPortraitHorizontalMinPadding * 2 * widthRatio;
			gameContainerMaxHeight = stage.height - gameContainerPortraitVerticalMinPadding * 2 * widthRatio;
		}
		if (gameContainerMaxWidth < gameContainerMaxHeight)
			gameContainer.setScale(gameContainerMaxWidth / gameContainerDefaultWidth);
		else
			gameContainer.setScale(gameContainerMaxHeight / gameContainerDefaultHeight);
		gameContainer.x = stage.width / 2 - gameContainer.getSize().width / 2;
		gameContainer.y = stage.height / 2 - gameContainer.getSize().height / 2;

		if (mode == LayoutMode.Landscape)
		{
			gameUI.setScale(heightRatio);
			gameDialog.setScale(heightRatio);

			gameContainer.x += gameContainerLandscapeXOffset;
			gameContainer.y += gameContainerLandscapeYOffset;
		}
		else
		{
			gameUI.setScale(widthRatio);
			gameDialog.setScale(widthRatio);

			gameContainer.x += gameContainerPortraitXOffset;
			gameContainer.y += gameContainerPortraitYOffset;
		}

		gameUI.setLayoutMode(mode);

		gameDialog.x = gameContainer.x + gameContainer.getSize().width / 2;
		gameDialog.y = gameContainer.y + gameContainer.getSize().height / 2;

		interactiveArea.width = stage.width;
		interactiveArea.height = stage.height;
	}

	function calculateLayoutMode(width:UInt, height:UInt)
	{
		mode = (width > height && width > gameContainerDefaultWidth)
			? LayoutMode.Landscape
			: LayoutMode.Portrait;
	}
}

enum LayoutMode
{
	Portrait;
	Landscape;
}