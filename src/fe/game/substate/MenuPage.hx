package fe.game.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import fe.common.ScalebaleSubState;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Flow.FlowAlign;
import h2d.Graphics;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import h2d.Text.Align;
import h2d.Tile;
import haxe.Json;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.heaps.ui.LinkedButton;
import hpp.util.Language;
import hxd.Res;
import motion.Actuate;
import motion.easing.Linear;
import tink.CoreApi.Future;
import tink.CoreApi.Noise;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuPage extends Base2dSubState implements ScalebaleSubState
{
	var background:Graphics;
	var dialogWrapper:Sprite;
	var dialog:BaseDialog;
	var closeButton:BaseButton;
	var content:Flow;

	var closeRequestCallBack:Void->Void;

	public function new(
		closeRequestCallBack:Void->Void
	){
		this.closeRequestCallBack = closeRequestCallBack;

		super();
	}

	override function build()
	{
		background = new Graphics(container);
		dialogWrapper = new Sprite(container);

		dialog = new BaseDialog(dialogWrapper, Res.image.common.dialog.dialog_background_m.toTile());
		dialog.visible = false;

		content = new Flow(dialog);
		content.isVertical = false;
		content.horizontalSpacing = 30;
		content.verticalAlign = FlowAlign.Top;
		content.horizontalAlign = FlowAlign.Middle;

		var titleFlow = new Flow(content);
		titleFlow.verticalSpacing = 20;
		titleFlow.isVertical = true;
		titleFlow.horizontalAlign = FlowAlign.Right;

		var selectLangText = new Text(Fonts.DEFAULT_L, titleFlow);
		selectLangText.smooth = true;
		selectLangText.textColor = 0xFFBF00;
		selectLangText.textAlign = Align.Left;
		selectLangText.y = 10;
		Language.registerTextHolder(cast selectLangText, "select_lang");

		var soundText = new Text(Fonts.DEFAULT_L, titleFlow);
		soundText.smooth = true;
		soundText.textColor = 0xFFBF00;
		soundText.textAlign = Align.Left;
		soundText.y = 10;
		Language.registerTextHolder(cast soundText, "sound");

		var musicText = new Text(Fonts.DEFAULT_L, titleFlow);
		musicText.smooth = true;
		musicText.textColor = 0xFFBF00;
		musicText.textAlign = Align.Left;
		musicText.y = 10;
		Language.registerTextHolder(cast musicText, "music");

		var actionFlow = new Flow(content);
		actionFlow.verticalSpacing = 20;
		actionFlow.isVertical = true;

		var flagFlow = new Flow(actionFlow);
		flagFlow.horizontalSpacing = 15;
		flagFlow.isVertical = false;

		var engButton = createFlagButton(flagFlow, Res.image.common.ui.flag_en.toTile(), Res.lang.lang_en.entry.getText());
		var hunButton = createFlagButton(flagFlow, Res.image.common.ui.flag_hu.toTile(), Res.lang.lang_hu.entry.getText());
		engButton.linkToButton(hunButton);
		engButton.isSelected = true;

		closeButton = new BaseButton(dialogWrapper, {
			onClick: closeRequest,
			baseGraphic: Res.image.menu.ui.close_button.toTile(),
			overGraphic: Res.image.menu.ui.close_button_over.toTile()
		});
		closeButton.setScale(AppConfig.GAME_BITMAP_SCALE);

		content.x = dialog.getSize().width / 2 - content.getSize().width / 2 - 10;
		content.y = dialog.getSize().height / 2 - content.getSize().height / 2 - 5;
	}

	function createFlagButton(parent:Sprite, flagTile:Tile, langString:String):LinkedButton
	{
		var button = new LinkedButton(parent, {
			onClick: function(_) { Language.setLang(Json.parse(langString)); },
			baseGraphic: Res.image.common.ui.lang_back.toTile(),
			overGraphic: Res.image.common.ui.lang_back_selected.toTile(),
			selectedGraphic: Res.image.common.ui.lang_back_selected.toTile(),
			disabledGraphic: Res.image.common.ui.lang_back_selected.toTile(),
			isSelectable: true
		});

		var f = new Bitmap(flagTile, button);
		f.smooth = true;
		f.x = button.getSize().width / 2 - flagTile.width / 2;
		f.y = button.getSize().height / 2 - flagTile.height / 2;

		button.setScale(AppConfig.GAME_BITMAP_SCALE);

		return button;
	}

	public function closeRequest(_)
	{
		Actuate.tween(background, .5, { alpha: 0 }).ease(Linear.easeNone);
		closeButton.visible = false;

		dialog.close().handle(function(){ closeRequestCallBack(); });
	}

	override public function onOpen()
	{
		onStageResize(HppG.stage2d.width, HppG.stage2d.height);
		dialog.open();

		background.alpha = 0;
		Actuate.tween(background, .5, { alpha: 1 }).ease(Linear.easeNone);
		closeButton.visible = true;
	}

	override public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, stage.width, stage.height);
		background.endFill();

		dialogWrapper.x = stage.width / 2;
		dialogWrapper.y = stage.height / 2;

		closeButton.x = 315;
		closeButton.y = -195;
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