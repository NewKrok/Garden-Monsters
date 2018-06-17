package fe.menu.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import fe.common.ScalebaleSubState;
import h2d.Flow;
import h2d.Flow.FlowAlign;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Sprite;
import h2d.Text;
import h2d.Text.Align;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.util.Language;
import hxd.Cursor;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import tink.CoreApi.Future;
import tink.CoreApi.Noise;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WelcomePage extends Base2dSubState implements ScalebaleSubState
{
	var background:Graphics;
	var dialogWrapper:Sprite;
	var dialog:BaseDialog;
	var content:Flow;
	var interactiveArea:Interactive;
	var onCloseRequest:Void->Void;

	public function new(onCloseRequest:Void->Void)
	{
		super();
		this.onCloseRequest = onCloseRequest;
	}

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
		Actuate.tween(background, .5, { alpha: 1 });

		interactiveArea = new Interactive(HppG.stage2d.width, HppG.stage2d.height, container);
		interactiveArea.cursor = Cursor.Button;

		interactiveArea.onClick = function(e:Event)
		{
			Actuate.tween(background, .5, { alpha: 0 }).ease(Linear.easeNone);
			dialog.close().handle(onCloseRequest);
		}
	}

	override public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, stage.width, stage.height);
		background.endFill();

		dialogWrapper.x = stage.width / 2;
		dialogWrapper.y = stage.height / 2;

		interactiveArea.width = HppG.stage2d.width;
		interactiveArea.height = HppG.stage2d.height;
	}

	public function setScale(v:Float):Void
	{
		dialogWrapper.setScale(v);

		if (stage != null)
		{
			dialogWrapper.x = stage.width / 2;
			dialogWrapper.y = stage.height / 2;
		}
	}
}