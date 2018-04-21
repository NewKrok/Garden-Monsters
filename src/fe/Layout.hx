package fe;

import fe.Layout.LayoutMode;
import fe.game.Elem;
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
	static inline var gameUILandscapeTopPadding = 55;
	static inline var gameUILandscapeLeftPadding = 55;
	static inline var gameUIPortraitTopPadding = 55;

	static var gameContainerDefaultWidth = Elem.SIZE * 8;
	static var gameContainerDefaultHeight = Elem.SIZE * 8;
	static inline var gameContainerLandscapeLeftPadding = 55;
	static inline var gameContainerPortraitTopPadding = 40;

	var mode:LayoutMode = LayoutMode.Landscape;
	var stage:Base2dStage;

	var gameContainer:Layers;
	var interactiveArea:Interactive;
	var gameUI:GameUI;

	public function new(
		stage:Base2dStage,
		gameContainer:Layers,
		interactiveArea:Interactive,
		gameUI:GameUI
	){
		this.stage = stage;
		this.gameContainer = gameContainer;
		this.interactiveArea = interactiveArea;
		this.gameUI = gameUI;
	}

	public function update(width:UInt, height:UInt):Void
	{
		calculateLayoutMode(width, height);

		var widthRatio = stage.width / stage.defaultWidth;
		var heightRatio = stage.height / stage.defaultHeight;

		if (mode == LayoutMode.Landscape)
		{
			gameUI.setScale(widthRatio);
			gameUI.x = gameUILandscapeLeftPadding;
			gameUI.y = gameUILandscapeTopPadding;

			gameContainer.setScale((heightRatio * gameContainerDefaultHeight) / gameContainerDefaultHeight);
			gameContainer.x = gameContainerLandscapeLeftPadding;
			gameContainer.y = stage.height / 2 - gameContainerDefaultHeight * heightRatio / 2;
		}
		else
		{
			gameUI.setScale(widthRatio);
			gameUI.x = stage.width / 2 - gameUI.getSize().width / 2;
			gameUI.y = gameUIPortraitTopPadding * widthRatio;

			gameContainer.setScale((widthRatio * gameContainerDefaultWidth) / Layout.gameContainerDefaultWidth);
			gameContainer.x = stage.width / 2 - gameContainerDefaultWidth * widthRatio / 2;
			gameContainer.y = gameUI.y + gameUI.getSize().height + gameContainerPortraitTopPadding * widthRatio;
		}

		interactiveArea.width = stage.width;
		interactiveArea.height = stage.height;
	}

	function calculateLayoutMode(width:UInt, height:UInt)
	{
		mode = (width > height && width > gameContainerDefaultWidth + gameContainerLandscapeLeftPadding * 2)
			? LayoutMode.Landscape
			: LayoutMode.Portrait;
	}
}

enum LayoutMode
{
	Portrait;
	Landscape;
}