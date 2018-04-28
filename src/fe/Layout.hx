package fe;

import fe.Layout.LayoutMode;
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
class Layout
{
	static var gameContainerDefaultWidth = Elem.SIZE * 8;
	static var gameContainerDefaultHeight = Elem.SIZE * 8;
	static inline var gameContainerLandscapeLeftPadding = 340;
	static inline var gameContainerPortraitTopPadding = 350;

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

		gameUI.setLayoutMode(mode);

		if (mode == LayoutMode.Landscape)
		{
			gameUI.setScale(heightRatio);
			gameDialog.setScale(heightRatio);

			gameContainer.setScale((heightRatio * gameContainerDefaultHeight) / gameContainerDefaultHeight);
			gameContainer.x = gameUI.x + gameContainerLandscapeLeftPadding;
			gameContainer.y = stage.height / 2 - gameContainerDefaultHeight * heightRatio / 2;
		}
		else
		{
			gameUI.setScale(widthRatio);
			gameDialog.setScale(widthRatio);

			gameContainer.setScale((widthRatio * gameContainerDefaultWidth) / Layout.gameContainerDefaultWidth);
			gameContainer.x = stage.width / 2 - gameContainerDefaultWidth * widthRatio / 2;
			gameContainer.y = gameUI.y + gameContainerPortraitTopPadding * widthRatio;
		}

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