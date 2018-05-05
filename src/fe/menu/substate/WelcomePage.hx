package fe.menu.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import h2d.Flow;
import h2d.Flow.FlowAlign;
import h2d.Graphics;
import h2d.Sprite;
import h2d.Text;
import h2d.Text.Align;
import hpp.heaps.Base2dSubState;
import hpp.util.Language;
import hxd.Res;
import motion.Actuate;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WelcomePage extends Base2dSubState
{
	var background:Graphics;
	var dialogWrapper:Sprite;
	var dialog:BaseDialog;
	var content:Flow;

	override function build()
	{
		background = new Graphics(container);
		dialogWrapper = new Sprite(container);

		dialog = new BaseDialog(dialogWrapper, Res.image.common.dialog.dialog_background_s.toTile());
		dialog.visible = false;

		content = new Flow(dialog);
		content.isVertical = true;
		content.verticalSpacing = 3;
		content.horizontalAlign = FlowAlign.Middle;

		var welcomeText = new Text(Fonts.DEFAULT_L, content);
		welcomeText.smooth = true;
		welcomeText.textColor = 0xFFBF00;
		welcomeText.textAlign = Align.Left;
		welcomeText.y = 10;
		Language.registerTextHolder(cast welcomeText, "welcome");

		var clickText = new Text(Fonts.DEFAULT_L, content);
		clickText.smooth = true;
		clickText.textColor = 0xFFFFFF;
		clickText.textAlign = Align.Left;
		clickText.y = 10;
		Language.registerTextHolder(cast clickText, "click_to_continue");

		content.x = dialog.getSize().width / 2 - content.getSize().width / 2;
		content.y = dialog.getSize().height / 2 - content.getSize().height / 2 - 5;

		Actuate.timer(.2).onComplete(function() { dialog.open(); });
	}

	override public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, stage.width, stage.height);
		background.endFill();

		dialogWrapper.x = stage.width / 2;
		dialogWrapper.y = stage.height / 2;
	}
}