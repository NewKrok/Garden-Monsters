package fe.game.ui;

import fe.AppConfig;
import fe.Layout.LayoutMode;
import fe.asset.Fonts;
import fe.game.Elem.ElemType;
import fe.game.GameModel.ElemGoalData;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalUI extends Layers
{
	var goalEntries:Array<GoalEntry> = [];
	var back:Bitmap;
	var infoTextBack:Bitmap;
	var label:Text;
	var goals:Flow;

	public function new(parent, elemGoals:Map<ElemType, ElemGoalData>)
	{
		super(parent);

		back = new Bitmap(Res.image.game.ui.goals_back.toTile(), this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		infoTextBack = new Bitmap(Res.image.game.ui.goals_text_back.toTile(), this);
		infoTextBack.smooth = true;
		infoTextBack.setScale(AppConfig.GAME_BITMAP_SCALE);

		label = new Text(Fonts.DEFAULT_M, this);
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Left;

		Language.registerTextHolder(cast label, "goals");

		goals = new Flow(this);

		for (key in elemGoals.keys())
		{
			var entry = new GoalEntry(goals, key, elemGoals.get(key).expected, elemGoals.get(key).collected);
			goalEntries.push(entry);
		}
	}

	public function setLayoutMode(mode:LayoutMode)
	{
		if (mode == LayoutMode.Landscape)
		{
			back.rotation = Math.PI / 2;

			infoTextBack.x = -152;
			infoTextBack.y = back.getSize().height - infoTextBack.getSize().height / 2 - 44;

			label.x = infoTextBack.x + infoTextBack.getSize().width / 2 - label.textWidth / 2;
			label.y = infoTextBack.y + 5;

			goals.isVertical = true;
			goals.horizontalSpacing = 0;
			goals.verticalSpacing = 120;
			goals.x = -152;
			goals.y = back.getSize().height / 2 - goals.getSize().height / 2 + 70;
		}
		else
		{
			back.rotation = 0;

			infoTextBack.x = back.getSize().width - infoTextBack.getSize().width - 50;
			infoTextBack.y = -19;

			label.x = infoTextBack.x + infoTextBack.getSize().width / 2 - label.textWidth / 2;
			label.y = infoTextBack.y + 5;

			goals.isVertical = false;
			goals.horizontalSpacing = 30;
			goals.verticalSpacing = 0;
			goals.x = back.getSize().width / 2 - goals.getSize().width / 2 + 40;
			goals.y = back.getSize().height / 2 - goals.getSize().height / 2 + 40;
		}
	}
}