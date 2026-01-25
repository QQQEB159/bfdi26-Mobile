package funkin.utils;

import openfl.utils.Assets;
import openfl.Lib;
import openfl.system.Capabilities;

import lime.graphics.Image;
import lime.utils.Assets as LimeAssets;
import lime.app.Application;

import flixel.math.FlxPoint;

import funkin.backend.Song;
import funkin.data.WeekData;
import funkin.data.ClientPrefs;
import funkin.backend.MusicBeatState;
import funkin.states.PlayState;
import funkin.data.Highscore;

import tjson.TJSON;

class CoolUtil
{
	/**
	returns the last camera in FlxG.cameras.list
	equivalent to `FlxG.cameras.list[FlxG.cameras.list.length - 1]`
	**/
	public static var lastCamera(get, never):FlxCamera;
	
	static function get_lastCamera():FlxCamera return FlxG.cameras.list[FlxG.cameras.list.length - 1];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		//trace(snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	inline public static function betterLerp(val:Float, desiredVal:Float, ratio:Float, constantRatio:Bool = false)
	{
		if (constantRatio) return FlxMath.lerp(val, desiredVal, ratio);
		else return FlxMath.lerp(val, desiredVal, ratio * 60 * FlxG.elapsed);
	}

	public static function centerWindow()
	{
		var width = Capabilities.screenResolutionX;
		var height = Capabilities.screenResolutionY;

		Lib.application.window.x = Std.int((width / 2) - (Lib.application.window.width / 2));
		Lib.application.window.y = Std.int((height / 2) - (Lib.application.window.height / 2));
	}

	public static inline function centerWindowOnPoint(?point:FlxPoint) 
	{
		Lib.application.window.x = Std.int(point.x - (Lib.application.window.width / 2));
		Lib.application.window.y = Std.int(point.y - (Lib.application.window.height / 2));
	}

	public static inline function getCenterWindowPoint():FlxPoint 
	{
		return FlxPoint.get(
			Lib.application.window.x + (Lib.application.window.width / 2),
			Lib.application.window.y + (Lib.application.window.height / 2)
		);
	}

	public static var _windowTween:FlxTween = null;
	public static var _windowRes:FlxPoint;
	public static var _windowPos:FlxPoint;

	public static function tweenWindowResize(values:Dynamic, time:Float = 0.3 * 4, ?onComplete:Void->Void = null, big:Bool = false) 
	{
		FlxG.updateFramerate = 30; //makes it smoother and consistant

		FlxG.mouse.visible = false;

		_windowRes = FlxPoint.get(Lib.application.window.width, Lib.application.window.height); //Lib.application.window.width, Lib.application.window.height
		_windowPos = getCenterWindowPoint();
								
		_windowTween = FlxTween.tween(_windowRes, values, time, {ease: FlxEase.circInOut, onUpdate: (_) -> 
		{
			FlxG.resizeWindow(Std.int(_windowRes.x), Std.int(_windowRes.y));
			
			centerWindowOnPoint(_windowPos);
		}, onComplete: _ -> 
		{
			if (onComplete != null) onComplete();

			var finalvalues = [big ? 1280 : 960, 720];

			flixel.system.scaleModes.BaseScaleMode.ogSize = FlxPoint.get(finalvalues[0], finalvalues[1]); //921, 691
			FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

			FlxG.updateFramerate = ClientPrefs.data.framerate;

			FlxG.resizeWindow(finalvalues[0], finalvalues[1]);
			FlxG.resizeGame(finalvalues[0], finalvalues[1]);

			centerWindowOnPoint(_windowPos);
			
			_windowPos.put(); 
			_windowPos.put();
			FlxG.mouse.visible = true;
		}});
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0) {
					if(countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key in countByColor.keys()) {
			if(countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function parseJson(json:String):Dynamic {
		// the reason we do this is to make it easy to swap out json parsers
		return TJSON.parse(json);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder =  Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			#if linux
			var command:String = '/usr/bin/xdg-open';
			#else
			var command:String = 'explorer.exe';
			#end
			Sys.command(command, [folder]);
			trace('$command $folder');
		#else
			FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch(border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}
	
	public static function showPopUp(message:String, title:String):Void
	{
		/*#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else*/
		FlxG.stage.window.alert(message, title);
		//#end
	}
}
