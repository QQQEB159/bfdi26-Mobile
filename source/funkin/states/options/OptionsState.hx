package funkin.states.options;

import funkin.data.StageData;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', /*'Adjust Delay and Combo',*/ 'Graphics', 'Visuals and UI', 'Gameplay', 'Reset Data'];
	private static var curSelected:Int = 0;
	public static var onPlayState:Bool = false;

	private var optionText:FlxText;
	private var optionsArray:Array<FlxText> = [];

	var border:FlxSprite;

	var sel:FlxText;
	var sel2:FlxText;

	function openSelectedSubstate(label:String) 
	{
		border.visible = false;

		switch(label) 
		{
			case 'Controls':
				openSubState(new funkin.states.options.ControlsSubState());
			case 'Graphics':
				openSubState(new funkin.states.options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new funkin.states.options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new funkin.states.options.GameplaySettingsSubState());
			/*case 'Adjust Delay and Combo':
				FlxG.switchState(funkin.states.options.NoteOffsetState.new);*/ //we reallt arent using this for jack
			case 'Reset Data':
				openSubState(new funkin.states.options.DataReset());
				border.visible = true;
		}
	}

	override function create() 
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("SORTING OUT THEIR OPTIONS", null);
		#end

		trace(PlayState.FUCKMYLIFE);

		for (i in 0...options.length)
		{
			optionText = new FlxText(0, 0, 0, options[i], 32);
			optionText.setFormat(Paths.font("Digiface Regular.ttf"), 84, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			add(optionText);
			optionsArray.push(optionText);
		}

		sel = new FlxText(0, 0, 0, '<');
		sel.setFormat(Paths.font("Digiface Regular.ttf"), 84, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sel);

		border = new FlxSprite().loadGraphic(Paths.image('menus/border'));
		border.scale.set(0.72, 0.72);
		border.screenCenter();
		add(border);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() 
	{
		super.closeSubState();
		ClientPrefs.saveSettings();

		border.visible = true;
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1);

		if(FlxG.mouse.wheel != 0) changeSelection(-1 * FlxG.mouse.wheel);

		if (controls.BACK) 
		{
			FlxG.sound.play(Paths.sound('spaceunpause'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				FlxG.sound.music.volume = 0;

				if (PlayState.FUCKMYLIFE) 
					{
						//tweeningExit();
						openfl.Lib.application.window.resizable = false;
						CoolUtil.tweenWindowResize({x: 960, y: 720}, 0.3 * 4, function ()
						{
							FlxG.switchState(()-> new PlayState());
						}, false);
					} else FlxG.switchState(PlayState.new);
			}
			else FlxG.switchState(funkin.states.NewMain.new);
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) 
	{
		if (change != 0) FlxG.sound.play(Paths.sound('scrollup1'));

		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);

		sel.x = optionsArray[curSelected].x + optionsArray[curSelected].width;
		sel.y = optionsArray[curSelected].y;
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}