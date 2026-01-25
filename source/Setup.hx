package;

import flixel.input.keyboard.FlxKey;
import openfl.display.BitmapData;
import openfl.system.Capabilities;
import flixel.util.typeLimit.NextState;

#if COPYSTATE_ALLOWED
import funkin.states.CopyState;
#end

class Setup extends flixel.FlxState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var mouseIdle:BitmapData = BitmapData.fromFile('assets/shared/images/mouse.png');
	public static var mouseHover:BitmapData = BitmapData.fromFile('assets/shared/images/mouse2.png');

	public static var monitorResolutionWidth(get, never):Float;
	public static var monitorResolutionHeight(get, never):Float;

	static function get_monitorResolutionWidth():Float return Capabilities.screenResolutionX;
	static function get_monitorResolutionHeight():Float return Capabilities.screenResolutionY;

	public static function loadSave()
	{
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		funkin.data.ModSave.loadModSave();
	}

    override function create() 
    {
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(funkin.scripting.CallbackHandler.call)); #end

        #if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		ClientPrefs.loadPrefs();
		
		MobileData.init();

		if (Main.fpsVar.visible) Main.fpsVar.visible = false;

		#if VIDEOS_ALLOWED
		funkin.objects.Video4.init();
		#end

		#if HSCRIPT_ALLOWED
		funkin.scripting.HScript.setIrisLogger();
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if DISCORD_ALLOWED
		if (!DiscordClient.isInitialized) //fancy
		{
			DiscordClient.initialize();
			lime.app.Application.current.onExit.add((ec) -> DiscordClient.shutdown());
		}
		#end
		
		CoolUtil.tweenWindowResize({x: 1280, y: 720}, 0.3 * 4, function ()
		{
			openfl.Lib.application.window.resizable = true;
			
			final nextState:Null<NextState> = (!FlxG.save.data.modNotice ? funkin.states.BootFlashingState.new : Splash.new);
			#if COPYSTATE_ALLOWED
			if(!CopyState.checkExistingFiles())
			{
			    FlxG.switchState(CopyState.new);
			}
			else FlxG.switchState(nextState);
			
			#else
			FlxG.switchState(nextState);
			#end
		}, true);

		trace(FlxG.save.data.bannedhaha);

		super.create();
    }
}