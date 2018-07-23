package fe.common.ui;

import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Sprite;
import hpp.heaps.ui.BaseButton;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SocialUI extends Layers
{
	public function new(parent:Sprite)
	{
		super(parent);

		var back = new Bitmap(Res.image.common.ui.social_back.toTile(), this);
		back.smooth = true;

		var container:Flow = new Flow(this);
		container.isVertical = true;
		container.verticalSpacing = 20;

		var facebookButton = new BaseButton(container, {
			onClick: function(_){ navigateToUrl("https://www.facebook.com/flashplusplus"); },
			baseGraphic: Res.image.common.ui.social_facebook.toTile(),
			overScale: .9
		});

		var githubButton = new BaseButton(container, {
			onClick: function(_){ navigateToUrl("https://github.com/NewKrok/Garden-Monsters"); },
			baseGraphic: Res.image.common.ui.social_github.toTile(),
			overScale: .9
		});

		var homeButton = new BaseButton(container, {
			onClick: function(_){ navigateToUrl("https://flashplusplus.net/"); },
			baseGraphic: Res.image.common.ui.social_home.toTile(),
			overScale: .9
		});

		container.x = 20;
		container.y = back.getSize().height / 2 - container.getSize().height / 2;
	}

	function navigateToUrl(url:String)
	{
		untyped __js__("window.open('$url', '_blank')");
	}
}