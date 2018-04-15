package fe;

import fe.Layout.LayoutMode;
import h2d.Interactive;
import h2d.Layers;
import hpp.heaps.Base2dStage;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Layout
{
	static inline var gameContainerDefaultWidth = 1050;
	static inline var gameContainerDefaultHeight = 835;
	static inline var gameContainerLandscapeLeftPadding = 55;
	static inline var gameContainerPortraitTopPadding = 55;

	var mode:LayoutMode = LayoutMode.Landscape;
	var gameContainer:Layers;
	var interactiveArea:Interactive;
	var stage:Base2dStage;

	public function new(
		stage:Base2dStage,
		gameContainer:Layers,
		interactiveArea:Interactive
	){
		this.stage = stage;
		this.gameContainer = gameContainer;
		this.interactiveArea = interactiveArea;
	}

	public function update(width:UInt, height:UInt):Void
	{
		calculateLayoutMode(width, height);

		var widthRatio = stage.width / stage.defaultWidth;
		var heightRatio = stage.height / stage.defaultHeight;

		interactiveArea.setScale(widthRatio);

		if (mode == LayoutMode.Landscape)
		{
			gameContainer.setScale((heightRatio * gameContainerDefaultHeight) / gameContainerDefaultHeight);
			gameContainer.x = gameContainerLandscapeLeftPadding;
			gameContainer.y = stage.height / 2 - gameContainerDefaultHeight * heightRatio / 2;
		}
		else
		{
			gameContainer.setScale((widthRatio * gameContainerDefaultWidth) / Layout.gameContainerDefaultWidth);
			gameContainer.x = stage.width / 2 - gameContainerDefaultWidth * widthRatio / 2;
			gameContainer.y = gameContainerPortraitTopPadding;
		}

		interactiveArea.width = gameContainerDefaultWidth;
		interactiveArea.height = gameContainerDefaultHeight;
		interactiveArea.x = gameContainer.x;
		interactiveArea.y = gameContainer.y;
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