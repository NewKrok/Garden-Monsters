package fe.menu;

import fe.common.ScalebaleSubState;
import fe.menu.ui.MenuMap;
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

	var menuMap:MenuMap;
	var welcomePage:ScalebaleSubState;
	var startLevelPage:ScalebaleSubState;

	public function new(
		stage:Base2dStage,
		menuMap:MenuMap,
		welcomePage:ScalebaleSubState,
		startLevelPage:ScalebaleSubState
	){
		this.stage = stage;
		this.menuMap = menuMap;
		this.welcomePage = welcomePage;
		this.startLevelPage = startLevelPage;
	}

	public function update(width:UInt, height:UInt):Void
	{
		calculateLayoutMode(width, height);

		var widthRatio = stage.width / stage.defaultWidth;
		var heightRatio = stage.height / stage.defaultHeight;

		menuMap.updateScale(stage.width / menuContainerDefaultWidth);

		if (mode == LayoutMode.Landscape)
		{
			welcomePage.setScale(heightRatio);
			startLevelPage.setScale(heightRatio);
		}
		else
		{
			welcomePage.setScale(widthRatio);
			startLevelPage.setScale(widthRatio);
		}
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