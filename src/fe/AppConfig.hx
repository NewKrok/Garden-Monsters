package fe;

import hxd.snd.ChannelGroup;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AppConfig
{
	public static inline var APP_WIDTH:Int = 1136;
	public static inline var APP_HEIGHT:Int = 1136;

	public static inline var GAME_BITMAP_SCALE:Float = .53;

	public static var MUSIC_VOLUME:Float = 1;
	public static var CHANNEL_GROUP_MUSIC:ChannelGroup = new ChannelGroup("music");
}