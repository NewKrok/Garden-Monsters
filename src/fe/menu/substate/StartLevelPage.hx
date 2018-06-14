package fe.menu.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import fe.common.ScalebaleSubState;
import fe.menu.ui.MapPreview;
import h2d.Flow;
import h2d.Graphics;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.util.Language;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StartLevelPage extends Base2dSubState implements ScalebaleSubState
{
	var background:Graphics;
	var dialogWrapper:Layers;
	var dialog:BaseDialog;
	var content:Flow;
	var levelText:Text;
	var mapPreview:MapPreview;
	var playersBestScoreText:Text;
	var closeButton:BaseButton;
	var startButton:BaseButton;

	var startRequest:Void->Void;
	var closeRequestCallBack:Void->Void;
	var selectedLevelId:Observable<UInt>;
	var selectedRawMap:Observable<Array<Array<Int>>>;

	public function new(
		startRequest:Void->Void,
		closeRequestCallBack:Void->Void,
		selectedLevelId:Observable<UInt>,
		selectedRawMap:Observable<Array<Array<Int>>>
	){
		this.startRequest = startRequest;
		this.closeRequestCallBack = closeRequestCallBack;
		this.selectedLevelId = selectedLevelId;
		this.selectedRawMap = selectedRawMap;

		super();
	}

	override function build()
	{
		background = new Graphics(container);
		dialogWrapper = new Layers(container);

		dialog = new BaseDialog(dialogWrapper, Res.image.common.dialog.dialog_background_high.toTile());
		dialog.visible = false;

		content = new Flow(dialog);
		content.isVertical = true;
		content.verticalSpacing = 20;
		content.horizontalAlign = FlowAlign.Middle;

		buildHeader(content);
		mapPreview = new MapPreview(content, selectedRawMap);
		buildFooter(content);

		closeButton = new BaseButton(dialogWrapper, {
			onClick: closeRequest,
			baseGraphic: Res.image.common.ui.close_button.toTile(),
			overGraphic: Res.image.common.ui.close_button_over.toTile()
		});
		closeButton.setScale(AppConfig.GAME_BITMAP_SCALE);

		startButton = new BaseButton(dialogWrapper, {
			font: Fonts.DEFAULT_XXL,
			textOffset: { x:0, y: -10 },
			onClick: function(_){ startRequest(); },
			baseGraphic: Res.image.common.ui.button_s.toTile(),
			overGraphic: Res.image.common.ui.button_over_s.toTile()
		});
		Language.registerTextHolder(cast startButton.label, "play");
		startButton.setScale(AppConfig.GAME_BITMAP_SCALE);

		content.x = dialog.getSize().width / 2 - content.getSize().width / 2;
		content.y = dialog.getSize().height / 2 - content.getSize().height / 2 - 5;

		Actuate.timer(.2).onComplete(function() { dialog.open(); });
	}

	function buildHeader(parent:Sprite):Void
	{
		levelText = new Text(Fonts.DEFAULT_XL, parent);
		levelText.smooth = true;
		levelText.textColor = 0xFFBF00;
		levelText.textAlign = Align.Left;
		levelText.y = 10;
		levelText.text = "PlaceHolder";

		selectedLevelId.bind(function(v){
			if (levelText.text != "PlaceHolder") Language.unregisterTextHolder(cast levelText);
			Language.registerTextHolder(cast levelText, "level_num", ["${level}" => v + 1]);
		});
	}

	function buildFooter(parent:Sprite):Void
	{
		var footer:Flow = new Flow(parent);
		footer.isVertical = false;
		footer.horizontalSpacing = 20;
		footer.verticalAlign = FlowAlign.Middle;

		var playersBestScoreLabel = new Text(Fonts.DEFAULT_L, footer);
		playersBestScoreLabel.smooth = true;
		playersBestScoreLabel.textColor = 0xFFBF00;
		playersBestScoreLabel.textAlign = Align.Left;
		Language.registerTextHolder(cast playersBestScoreLabel, "your_best");

		playersBestScoreText = new Text(Fonts.DEFAULT_XL, footer);
		playersBestScoreText.smooth = true;
		playersBestScoreText.textColor = 0xFFFFFF;
		playersBestScoreText.textAlign = Align.Left;
		playersBestScoreText.text = "N/A";

		//TODO update
		//playersBestScoreText.text = playersBestScore.value == 0 ? "N/A" : NumberUtil.formatNumber(v);
	}

	override public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, stage.width, stage.height);
		background.endFill();

		dialogWrapper.x = stage.width / 2;
		dialogWrapper.y = stage.height / 2 - 100;

		closeButton.x = 270;
		closeButton.y = -425;

		startButton.x = -startButton.getSize().width / 2;
		startButton.y = 390;
	}

	override public function onOpen()
	{
		onStageResize(HppG.stage2d.width, HppG.stage2d.height);
		mapPreview.updateView();
		dialog.open();

		background.alpha = 0;
		Actuate.tween(background, .5, { alpha: 1 }).ease(Linear.easeNone);
		startButton.visible = true;
		closeButton.visible = true;
	}

	public function closeRequest(_)
	{
		Actuate.tween(background, .5, { alpha: 0 }).ease(Linear.easeNone);
		startButton.visible = false;
		closeButton.visible = false;

		dialog.close().handle(function(){ closeRequestCallBack(); });
	}

	public function setScale(v:Float):Void
	{
		dialogWrapper.setScale(v);

		if (stage != null)
		{
			dialogWrapper.x = stage.width / 2;
			dialogWrapper.y = stage.height / 2 - 100;
		}
	}
}