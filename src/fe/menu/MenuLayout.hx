package fe.menu;

import h2d.Interactive;
import h2d.Layers;
import h2d.Sprite;
import hpp.heaps.Base2dStage;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuLayout
{
	static var menuContainerDefaultWidth = 1136;

	var mode:LayoutMode = LayoutMode.Landscape;
	var stage:Base2dStage;

	var menuContainer:Sprite;
	var interactiveArea:Interactive;

	public function new(
		stage:Base2dStage,
		menuContainer:Layers,
		interactiveArea:Interactive
	){
		this.stage = stage;
		this.menuContainer = menuContainer;
		this.interactiveArea = interactiveArea;
	}

	public function update(width:UInt, height:UInt):Void
	{
		calculateLayoutMode(width, height);

		var widthRatio = stage.width / stage.defaultWidth;
		var heightRatio = stage.height / stage.defaultHeight;

		menuContainer.setScale(stage.width / menuContainerDefaultWidth);

		if (mode == LayoutMode.Landscape)
		{
		}
		else
		{
		}

		interactiveArea.width = stage.width;
		interactiveArea.height = stage.height;
	}

	function calculateLayoutMode(width:UInt, height:UInt)
	{
		mode = (width > height)
			? LayoutMode.Landscape
			: LayoutMode.Portrait;
	}
}

enum LayoutMode
{
	Portrait;
	Landscape;
}