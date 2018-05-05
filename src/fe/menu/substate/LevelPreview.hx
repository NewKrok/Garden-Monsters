package fe.menu.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Graphics;
import h2d.Sprite;
import h2d.Text;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.util.Language;
import hxd.Res;
import motion.Actuate;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelPreview extends Base2dSubState
{
	var background:Graphics;
	var dialogWrapper:Sprite;
	var dialog:BaseDialog;
	var content:Flow;
	var levelText:Text;
	var playersBestScoreText:Text;

	override function build()
	{
		background = new Graphics(container);
		dialogWrapper = new Sprite(container);

		dialog = new BaseDialog(dialogWrapper, Res.image.common.dialog.dialog_background_high.toTile());
		dialog.visible = false;

		content = new Flow(dialog);
		content.isVertical = true;
		content.verticalSpacing = 3;
		content.horizontalAlign = FlowAlign.Middle;

		levelText = new Text(Fonts.DEFAULT_L, content);
		levelText.smooth = true;
		levelText.textColor = 0xFFBF00;
		levelText.textAlign = Align.Left;
		levelText.y = 10;
		levelText.text = "PlaceHolder";

		buildFooter(content);

		content.x = dialog.getSize().width / 2 - content.getSize().width / 2 - 5;
		content.y = dialog.getSize().height / 2 - content.getSize().height / 2 - 5;

		Actuate.timer(.2).onComplete(function() { dialog.open(); });
	}

	function buildFooter(parent:Sprite):Void
	{
		var footer:Flow = new Flow(parent);
		footer.isVertical = false;
		footer.horizontalSpacing = 20;
		footer.verticalAlign = FlowAlign.Middle;

		var playersBestScoreLabel = new Text(Fonts.DEFAULT_M, footer);
		playersBestScoreLabel.smooth = true;
		playersBestScoreLabel.textColor = 0xFFBF00;
		playersBestScoreLabel.textAlign = Align.Left;
		Language.registerTextHolder(cast playersBestScoreLabel, "your_best");

		playersBestScoreText = new Text(Fonts.DEFAULT_L, footer);
		playersBestScoreText.smooth = true;
		playersBestScoreText.textColor = 0xFFFFFF;
		playersBestScoreText.textAlign = Align.Left;
		playersBestScoreText.text = "N/A";
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

	public function updateContent(levelId:UInt)
	{
		Language.unregisterTextHolder(cast levelText);
		Language.registerTextHolder(cast levelText, "level_num", ["${level}" => levelId + 1]);

		//TODO update
		//playersBestScoreText.text = playersBestScore.value == 0 ? "N/A" : NumberUtil.formatNumber(v);
	}

	override public function onOpen()
	{
		onStageResize(HppG.stage2d.width, HppG.stage2d.height);
	}
}