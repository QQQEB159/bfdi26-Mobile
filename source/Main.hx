package;

import Type;

import funkin.api.FPSCounter;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.text.TextField;
import openfl.text.TextFormat;

import lime.app.Application;
import lime.graphics.Image;
import lime.system.System as LimeSystem;

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

#if COPYSTATE_ALLOWED
import funkin.states.CopyState;
#end

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	public static final game = 
	{
		width: 1025,
		height: 577,
		firstState: Setup,
		fps: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsVar:FPSCounter;

	public static var audioDisconnected:Bool = false;
	public static var changeID:Int = 0;

	public static var skipNextDump:Bool = false;

	public static var listentome:Null<Bitmap> = null;
	public static var listentometext:Null<TextField> = null;

	public static var banlist:Array<String> = [];

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
        cpp.NativeGc.enable(true);
        cpp.NativeGc.run(true);
        #end
	}

	public function new()
	{
		super();
		
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		#if (windows && cpp)
		funkin.api.Windows.fixScaling();
		funkin.api.NativeAPI.setDarkMode(null, true);
		funkin.api.system.AudioSwitchFix.init();
		#end

		var _game = new FlxGame(game.width, game.height, game.firstState, game.fps, game.fps, game.skipSplash, game.startFullscreen);
		@:privateAccess _game._customSoundTray = funkin.objects.BFDISoundTray;
		Setup.loadSave();
		addChild(_game);

		FlxG.signals.preStateSwitch.add(function () 
		{
			if (!Main.skipNextDump) 
			{
				Paths.clearStoredMemory();
				#if (flixel < "6.0.0") FlxG.bitmap.dumpCache(); #else FlxG.bitmap.clearCache(); #end
			}
			clearMajor();
		});
		
		FlxG.signals.postStateSwitch.add(function () 
		{
			Paths.clearUnusedMemory();
			clearMajor();
			Main.skipNextDump = false;
		});

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		#if !mobile
		addChild(fpsVar);
		#else
		FlxG.game.addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		fpsVar.visible = ClientPrefs.data.showFPS;

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onFatalCrash);
		#end
		#end

		Lib.application.window.resizable = false;

		loadBanList();

		#if DISCORD_ALLOWED
		if (banlist.contains(DiscordClient.userId))
		{
			FlxG.save.data.bannedhaha = true;

			#if debug trace('ur banned'); #end
		} #if debug else trace('ur not banned'); #end
		trace(banlist);
		#end

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		#end
		
		// shader coords fix
		FlxG.signals.focusGained.add(function() {
			onResize();
		});
		FlxG.signals.gameResized.add(function(w, h) {
			onResize();
		});
		// Prevent flixel from listening to key inputs when switching fullscreen mode
		// also lets you fullscreen with F11
		// thanks @nebulazorua, @crowplexus, @diogotvv
		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) ->
		{
			if (e.keyCode == flixel.input.keyboard.FlxKey.F11)
				FlxG.fullscreen = !FlxG.fullscreen;
			
			if (e.keyCode == flixel.input.keyboard.FlxKey.ENTER && e.altKey)
				e.stopImmediatePropagation();
		}, false, 100);

		#if debug if (FlxG.keys.justPressed.FOUR) null.draw(); #end

		//listne to me. (webcrasher event)
		listentome = new Bitmap(openfl.Assets.getBitmapData((FlxG.save.data.webcrasherSecret ? Paths.getPath('images/listentoMEe.png', IMAGE) : Paths.getPath('images/listentome.png', IMAGE))));
		listentome.visible = false;
		addChild(listentome);

		listentometext = new TextField();
		listentometext.defaultTextFormat = new TextFormat("DejaVuSans.ttf", 11, 0xFFFFFF);
		listentometext.text = "listen to me.";
		listentometext.x = 40;
		listentometext.y = 100;
		listentometext.scaleX = 10;
		listentometext.scaleY = 30;
		listentometext.visible = false;
		addChild(listentometext);
	}

	public static function loadBanList() 
	{
        var loader = new URLLoader();
        
		loader.addEventListener(Event.COMPLETE, function(e:Event) 
		{
            var data:String = cast(loader.data, String);
            banlist = data.split("\n");
            for (i in 0...banlist.length) banlist[i] = StringTools.trim(banlist[i]);
            
			#if debug trace("Ban list: " + banlist); #end
        });

        loader.load(new URLRequest("https://pastebin.com/raw/j4Bg7Nhe"));
    }

	@:access(flixel.FlxCamera)
	public static function onResize(?w,?h)
	{
		if (FlxG.cameras != null)
		{
			for (cam in FlxG.cameras.list)
			{
				if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
			}
		}
		if (FlxG.game != null) resetSpriteCache(FlxG.game);
		
		if (fpsVar != null) fpsVar.scaleX = fpsVar.scaleY = Math.max(1, Math.min(w / FlxG.width, h / FlxG.height));
	}

	static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	//i fw this
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopImmediatePropagation();

		var path:String;
		var exception:String = 'Exception: ${e.error}\n';
		var stackTraceString = exception + StringTools.trim(CallStack.toString(CallStack.exceptionStack(true)));
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		path = 'crash/BFDI26_${dateNow}.txt';
		var normalPath:String = Path.normalize(path);

		#if sys
		if (!FileSystem.exists("crash/")) FileSystem.createDirectory("crash/");
		File.saveContent(path, '${stackTraceString}\n');
		#end

		Sys.println(stackTraceString);
		Sys.println('Crash dump saved in $normalPath');

		#if (flixel < "6.0.0") FlxG.bitmap.dumpCache(); #end
		FlxG.bitmap.clearCache();

		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new funkin.states.CrashHandlerState(stackTraceString + '\n\nCrash log created at: ${normalPath}\nCrashed at state ${Type.getClassName(Type.getClass(FlxG.state))}'));
	}

	function onFatalCrash(e:UncaughtErrorEvent):Void 
	{
		e.preventDefault();
		e.stopImmediatePropagation();

		var path:String;
		var exception:String = 'Exception: ${e.error}\n';
		var stackTraceString = exception + StringTools.trim(CallStack.toString(CallStack.exceptionStack(true)));
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		path = 'crash/BFDI26_${dateNow}.txt';
		var normalPath:String = Path.normalize(path);

		#if sys
		if (!FileSystem.exists("crash/")) FileSystem.createDirectory("crash/");
		File.saveContent(path, '${stackTraceString}\n');
		#end

		Sys.println(stackTraceString);
		Sys.println('Crash dump saved in $normalPath');

		#if (flixel < "6.0.0") FlxG.bitmap.dumpCache(); #end
		FlxG.bitmap.clearCache();

		Application.current.window.alert(stackTraceString, 'Error!\nCrash log created at: ${normalPath}');
		Sys.exit(1);
	}
	#end

	public static function clearMajor() 
	{
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}
}