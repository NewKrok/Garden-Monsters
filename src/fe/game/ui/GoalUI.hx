package fe.game.ui;

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

	public function new(parent, elemGoals:Map<ElemType, ElemGoalData>)
	{
		super(parent);

		var back = new Bitmap(Res.image.game.ui.long_ui_panel.toTile(), this);

		var label = new Text(Fonts.DEFAULT_M, this);
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Center;
		label.x = back.tile.width / 2 + 2;
		label.y = 10;
		Language.registerTextHolder(cast label, "goals");

		var goals:Flow = new Flow(this);
		goals.isVertical = false;
		goals.horizontalSpacing = -12;

		for (key in elemGoals.keys())
		{
			var entry = new GoalEntry(goals, key, elemGoals.get(key).expected, elemGoals.get(key).collected);
			goalEntries.push(entry);
		}

		goals.x = back.getSize().width / 2 - goals.getSize().width / 2;
		goals.y = back.getSize().height - goals.getSize().height - 15;
	}
}