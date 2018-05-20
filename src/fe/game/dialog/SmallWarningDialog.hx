package fe.game.dialog;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import h2d.Flow;
import h2d.Text;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SmallWarningDialog extends BaseDialog
{
	var title:Text;
	var description:Text;
	var content:Flow;

	public function new(parent)
	{
		super(parent, Res.image.common.dialog.dialog_background_s.toTile(), { x: -5, y: 0 });

		content = new Flow(this);
		content.isVertical = true;
		content.verticalSpacing = 8;
		content.horizontalAlign = FlowAlign.Middle;

		title = new Text(Fonts.DEFAULT_M, content);
		title.maxWidth = getSize().width - 30;
		title.text = "Default";
		title.smooth = true;
		title.textColor = 0xFFBF00;
		title.textAlign = Align.Left;

		description = new Text(Fonts.DEFAULT_L, content);
		description.maxWidth = getSize().width - 30;
		description.text = "Default";
		description.smooth = true;
		description.textColor = 0xFFFFFF;
		description.textAlign = Align.MultilineCenter;

		content.x = baseWidth / 2 - content.getSize().width / 2 - 5;
		content.y = getSize().height / 2 - content.getSize().height / 2 - 5;
	}

	public function updateData(titleText:String, descriptionText:String):Void
	{
		title.text = titleText;
		description.text = descriptionText;

		content.x = baseWidth / 2 - content.getSize().width / 2 - 5;
		content.y = getSize().height / 2 - content.getSize().height / 2 - 5;
	}
}