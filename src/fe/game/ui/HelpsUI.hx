package fe.game.ui;

import fe.asset.Fonts;
import fe.asset.HelpTile;
import fe.game.GameLayout.LayoutMode;
import fe.game.Help.HelpType;
import fe.game.ui.HelpEntry;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpsUI extends Layers
{
	var helpEntries:Array<HelpEntry> = [];
	var back:Bitmap;
	var infoTextBack:Bitmap;
	var label:Text;
	var helps:Flow;

	public function new(parent, helpCounts:Map<HelpType, Observable<UInt>>)
	{
		super(parent);

		back = new Bitmap(Res.image.game.ui.goals_back.toTile(), this);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		infoTextBack = new Bitmap(Res.image.game.ui.goals_text_back.toTile(), this);
		infoTextBack.smooth = true;
		infoTextBack.setScale(AppConfig.GAME_BITMAP_SCALE);

		label = new Text(Fonts.DEFAULT_M, this);
		label.smooth = true;
		label.textColor = 0xFFBF00;
		label.textAlign = Align.Left;

		Language.registerTextHolder(cast label, "helps");

		helps = new Flow(this);

		for (key in helpCounts.keys())
		{
			var entry = new HelpEntry(helps, HelpTile.tiles.get(key), helpCounts.get(key));
			helpEntries.push(entry);
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
			label.y = infoTextBack.y + 3;

			helps.isVertical = true;
			helps.horizontalSpacing = 0;
			helps.verticalSpacing = 90;
			helps.x = -83;
			helps.y = back.getSize().height / 2 - helps.getSize().height / 2 + 25;
		}
		else
		{
			back.rotation = 0;

			infoTextBack.x = back.getSize().width - infoTextBack.getSize().width - 50;
			infoTextBack.y = -19;

			label.x = infoTextBack.x + infoTextBack.getSize().width / 2 - label.textWidth / 2;
			label.y = infoTextBack.y + 5;

			helps.isVertical = false;
			helps.horizontalSpacing = 90;
			helps.verticalSpacing = 0;
			helps.x = back.getSize().width / 2 - helps.getSize().width / 2 + 30;
			helps.y = back.getSize().height / 2 - helps.getSize().height / 2 + 43;
		}
	}
}