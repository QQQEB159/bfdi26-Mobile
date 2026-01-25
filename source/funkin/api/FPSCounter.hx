package funkin.api;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.system.System;

class FPSCounter extends Sprite
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	
	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	
	@:noCompletion private var times:Array<Float>;
	
	var textDisplay:TextField;
	var underlay:Bitmap;

	var memPeak:Float = 0;
	
	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		this.x = x;
		this.y = y;

		underlay = new Bitmap();
		underlay.bitmapData = new BitmapData(1, 1, true, 0x6F000000);
		underlay.alpha = 0.5;
		addChild(underlay);
		
		textDisplay = new TextField();
		textDisplay.defaultTextFormat = new TextFormat("flashing.ttf", 11, color);
		textDisplay.text = "FPS: ";
		textDisplay.selectable = false;
		textDisplay.mouseEnabled = false;
		textDisplay.autoSize = LEFT;
		textDisplay.multiline = true;
		addChild(textDisplay);
		
		currentFPS = 0;
		
		times = [];
	}
	
	var deltaTimeout:Float = 0.0;
	
	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();
			
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}
			
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		
		deltaTimeout = 0.0;

		if (underlay.alpha == 0) return;
		
		underlay.width = textDisplay.width + 5;
		underlay.height = textDisplay.height;
	}
	
	public function updateText():Void
	{
		memPeak = Math.max(memPeak,memoryMegas);
		textDisplay.text = 'FPS: ' + currentFPS + ' • ' + 'Memory: ' + flixel.util.FlxStringUtil.formatBytes(memoryMegas).toLowerCase() + ' / ' + flixel.util.FlxStringUtil.formatBytes(memPeak).toLowerCase();
		
		textDisplay.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5) textDisplay.textColor = 0xFFFF0000;
	}
	
	inline function get_memoryMegas():UInt return cast #if (openfl < "9.4.0") System.totalMemory #else System.totalMemoryNumber #end;
	
	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}
}