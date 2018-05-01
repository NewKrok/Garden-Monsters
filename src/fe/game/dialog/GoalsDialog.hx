package fe.game.dialog;

import fe.asset.Fonts;
import fe.game.Elem.ElemType;
import fe.game.GameModel.ElemGoalData;
import fe.game.ui.GoalEntry;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Sprite;
import h2d.Text;
import hpp.util.Language;
import hxd.Res;
import tink.state.Observable;
import hpp.util.NumberUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GoalsDialog extends BaseDialog
{
	public function new(parent, levelId:UInt, elemGoals:Map<ElemType, ElemGoalData>, playersBestScore:Observable<UInt>)
	{
		super(parent, Res.image.game.dialog.dialog_background_m.toTile(), { x: -5, y: -5 });

		var content:Flow = new Flow(this);
		content.isVertical = true;
		content.verticalSpacing = 12;
		content.horizontalAlign = FlowAlign.Middle;

		buildHeader(content, levelId);
		buildGoalsView(content, elemGoals);
		buildFooter(content, playersBestScore);

		content.x = getSize().width / 2 - content.getSize().width / 2 - 5;
		content.y = getSize().height / 2 - content.getSize().height / 2 - 8;
	}

	function buildHeader(parent:Sprite, levelId:UInt):Void
	{
		var header:Sprite = new Sprite(parent);

		var levelText = new Text(Fonts.DEFAULT_L, header);
		levelText.smooth = true;
		levelText.textColor = 0xFFBF00;
		levelText.textAlign = Align.Left;
		levelText.y = 10;
		Language.registerTextHolder(cast levelText, "level_num", ["${level}" => levelId]);

		var goalsText = new Text(Fonts.DEFAULT_L, header);
		goalsText.smooth = true;
		goalsText.textColor = 0xFFBF00;
		goalsText.textAlign = Align.Right;
		goalsText.x = getSize().width - 90;
		goalsText.y = 10;
		Language.registerTextHolder(cast goalsText, "goals");
	}

	function buildGoalsView(parent:Sprite, elemGoals:Map<ElemType, ElemGoalData>)
	{
		var container:Layers = new Layers(parent);

		var back = new Bitmap(Res.image.game.dialog.start_dialog_goals_back.toTile(), container);
		back.smooth = true;
		back.setScale(AppConfig.GAME_BITMAP_SCALE);

		var goalsContainer:Flow = new Flow(container);
		goalsContainer.isVertical = false;
		goalsContainer.horizontalSpacing = 10;
		goalsContainer.verticalAlign = FlowAlign.Bottom;

		for (key in elemGoals.keys())
			new GoalEntry(goalsContainer, key, elemGoals.get(key).expected, elemGoals.get(key).collected, true);

		goalsContainer.x = back.getSize().width / 2 - goalsContainer.getSize().width / 2;
		goalsContainer.y = back.getSize().height / 2 - goalsContainer.getSize().height / 2 + 48;
	}

	function buildFooter(parent:Sprite, playersBestScore:Observable<UInt>):Void
	{
		var footer:Flow = new Flow(parent);
		footer.isVertical = false;
		footer.horizontalSpacing = 20;
		footer.verticalAlign = FlowAlign.Middle;

		var playersBestScoreLabel = new Text(Fonts.DEFAULT_M, footer);
		playersBestScoreLabel.smooth = true;
		playersBestScoreLabel.textColor = 0xFFBF00;
		playersBestScoreLabel.textAlign = Align.Left;
		playersBestScoreLabel.y = 10;
		Language.registerTextHolder(cast playersBestScoreLabel, "your_best");

		var playersBestScoreText = new Text(Fonts.DEFAULT_L, footer);
		playersBestScoreText.smooth = true;
		playersBestScoreText.textColor = 0xFFFFFF;
		playersBestScoreText.textAlign = Align.Left;
		playersBestScoreText.x = getSize().width - 90;
		playersBestScoreText.y = 10;

		playersBestScore.bind(function(v) {
			playersBestScoreText.text = playersBestScore.value == 0 ? "N/A" : NumberUtil.formatNumber(v);
		});
	}
}