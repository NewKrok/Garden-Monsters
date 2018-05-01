package fe.game.dialog;

import fe.asset.Fonts;
import h2d.Flow;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class NoMoreMovesDialog extends BaseDialog
{
	public function new(parent)
	{
		super(parent, Res.image.game.dialog.dialog_background_s.toTile(), { x: -5, y: 0 });

		var content:Flow = new Flow(this);
		content.isVertical = true;
		content.verticalSpacing = 8;
		content.horizontalAlign = FlowAlign.Middle;

		var title = new Text(Fonts.DEFAULT_M, content);
		title.smooth = true;
		title.textColor = 0xFFBF00;
		title.textAlign = Align.Left;
		Language.registerTextHolder(cast title, "no_more_moves");

		var description = new Text(Fonts.DEFAULT_XL, content);
		description.smooth = true;
		description.textColor = 0xFFFFFF;
		description.textAlign = Align.Left;
		Language.registerTextHolder(cast description, "shuffle");

		content.x = getSize().width / 2 - content.getSize().width / 2;
		content.y = getSize().height / 2 - content.getSize().height / 2 - 5;
	}
}