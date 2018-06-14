package fe.game.substate;

import fe.asset.Fonts;
import fe.common.BaseDialog;
import fe.common.SaveUtil;
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
	var soundButton:BaseButton;
	var musicButton:BaseButton;
	var backToGameButton:BaseButton;
	var quitButton:BaseButton;
	var buttonContainer:Flow;
	var content:Flow;

	var closeRequestCallBack:Void->Void;
	var quitRequestCallBack:Void->Void;

	public function new(
		closeRequestCallBack:Void->Void,
		quitRequestCallBack:Void->Void
	){
		this.closeRequestCallBack = closeRequestCallBack;
		this.quitRequestCallBack = quitRequestCallBack;

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
		titleFlow.verticalSpacing = 26;
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

		var engButton = createFlagButton(flagFlow, Res.image.common.ui.flag_en.toTile(), Res.lang.lang_en.entry.getText(), "en");
		var hunButton = createFlagButton(flagFlow, Res.image.common.ui.flag_hu.toTile(), Res.lang.lang_hu.entry.getText(), "hu");
		engButton.linkToButton(hunButton);
		if (SaveUtil.data.applicationInfo.lang == "en")
			engButton.isSelected = true;
		else
			hunButton.isSelected = true;

		soundButton = new BaseButton(actionFlow, {
			onClick: function(_) {
				AppConfig.SOUND_VOLUME = AppConfig.SOUND_VOLUME == 1 ? 0 : 1;
				AppConfig.CHANNEL_GROUP_SOUND.volume = AppConfig.SOUND_VOLUME;
				SaveUtil.data.applicationInfo.soundVolume = AppConfig.SOUND_VOLUME;
				SaveUtil.save();
				Language.updateTextHolderText(cast soundButton.label, getSoundButtonLabel());
			},
			baseGraphic: Res.image.common.ui.button_xs.toTile(),
			overGraphic: Res.image.common.ui.button_over_xs.toTile(),
			font: Fonts.DEFAULT_XL
		});
		soundButton.setScale(AppConfig.GAME_BITMAP_SCALE);
		Language.registerTextHolder(cast soundButton.label, getSoundButtonLabel());

		musicButton = new BaseButton(actionFlow, {
			onClick: function(_) {
				AppConfig.MUSIC_VOLUME = AppConfig.MUSIC_VOLUME == 1 ? 0 : 1;
				AppConfig.CHANNEL_GROUP_MUSIC.volume = AppConfig.MUSIC_VOLUME;
				SaveUtil.data.applicationInfo.musicVolume = AppConfig.MUSIC_VOLUME;
				SaveUtil.save();
				Language.updateTextHolderText(cast musicButton.label, getMusicButtonLabel());
			},
			baseGraphic: Res.image.common.ui.button_xs.toTile(),
			overGraphic: Res.image.common.ui.button_over_xs.toTile(),
			font: Fonts.DEFAULT_XL
		});
		musicButton.setScale(AppConfig.GAME_BITMAP_SCALE);
		Language.registerTextHolder(cast musicButton.label, getMusicButtonLabel());

		closeButton = new BaseButton(dialogWrapper, {
			onClick: closeRequest,
			baseGraphic: Res.image.common.ui.close_button.toTile(),
			overGraphic: Res.image.common.ui.close_button_over.toTile()
		});
		closeButton.setScale(AppConfig.GAME_BITMAP_SCALE);

		buttonContainer = new Flow(dialogWrapper);
		buttonContainer.isVertical = false;
		buttonContainer.horizontalSpacing = 20;

		backToGameButton = new BaseButton(buttonContainer, {
			onClick: closeRequest,
			baseGraphic: Res.image.common.ui.button_s.toTile(),
			overGraphic: Res.image.common.ui.button_over_s.toTile(),
			font: Fonts.DEFAULT_XXL
		});
		backToGameButton.setScale(AppConfig.GAME_BITMAP_SCALE);
		Language.registerTextHolder(cast backToGameButton.label, "back_to_game");

		quitButton = new BaseButton(buttonContainer, {
			onClick: function(_) {
				quitRequestCallBack();
			},
			baseGraphic: Res.image.common.ui.button_s.toTile(),
			overGraphic: Res.image.common.ui.button_over_s.toTile(),
			font: Fonts.DEFAULT_XXL
		});
		quitButton.setScale(AppConfig.GAME_BITMAP_SCALE);
		Language.registerTextHolder(cast quitButton.label, "quit_game");

		content.x = dialog.getSize().width / 2 - content.getSize().width / 2 - 10;
		content.y = dialog.getSize().height / 2 - content.getSize().height / 2 - 5;
	}

	function getSoundButtonLabel():String return AppConfig.SOUND_VOLUME == 1 ? "off" : "on";
	function getMusicButtonLabel():String return AppConfig.MUSIC_VOLUME == 1 ? "off" : "on";

	function createFlagButton(parent:Sprite, flagTile:Tile, langString:String, shortcut:String):LinkedButton
	{
		var button = new LinkedButton(parent, {
			onClick: function(_) {
				Language.setLang(Json.parse(langString));
				SaveUtil.data.applicationInfo.lang = shortcut;
				SaveUtil.save();
			},
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
		buttonContainer.visible = false;

		dialog.close().handle(function(){ closeRequestCallBack(); });
	}

	override public function onOpen()
	{
		onStageResize(HppG.stage2d.width, HppG.stage2d.height);
		dialog.open();

		background.alpha = 0;
		Actuate.tween(background, .5, { alpha: 1 }).ease(Linear.easeNone);
		closeButton.visible = true;
		buttonContainer.visible = true;
	}

	override public function onStageResize(width:Float, height:Float)
	{
		background.clear();
		background.beginFill(0x000000, .5);
		background.drawRect(0, 0, stage.width, stage.height);
		background.endFill();

		dialogWrapper.x = stage.width / 2;
		dialogWrapper.y = stage.height / 2 - 100;

		closeButton.x = 315;
		closeButton.y = -195;

		buttonContainer.x = -buttonContainer.getSize().width / 2;
		buttonContainer.y = 160;
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