package funkin.substates;

import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import lime.app.Application;

import flixel.tweens.FlxTween.FlxTweenType;

// this is like    really really simple and probbaly doesnt need to be a substate but idc // you can open it in other states ig ? if u want to do that
class ChangelogSubstate extends MusicBeatSubstate
{
	public var pauseCam:FlxCamera;

	override function create()
	{
		camera = pauseCam = new FlxCamera();
    	FlxG.cameras.add(pauseCam, false);
    	pauseCam.bgColor = 0;
		pauseCam.alpha = 0;
		FlxTween.tween(pauseCam, {alpha: 1}, 0.4, {ease: FlxEase.circOut});

		@:privateAccess FlxG.camera._fxFadeColor = FlxColor.BLACK;
		FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 0.7},0.5);

		var black = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		black.setScale(FlxG.width, FlxG.height);
		black.alpha = 0.8;
		add(black);

		var changelogSpr = new FlxSprite().loadImage('menus/freeplay/changelog/changelog text');
		changelogSpr.setScale(0.95, 0.95);
		changelogSpr.x = (FlxG.width - changelogSpr.width) - 50;
		add(changelogSpr);		

		var bookndb = new FlxSprite().loadFrames('menus/freeplay/changelog/book and bubs cute');
		bookndb.addAndPlay('i', 'book and bubs cute instance 1');
		bookndb.setScale(0.9, 0.9);
		bookndb.x = FlxG.width - bookndb.width - 75;
		bookndb.screenCenter(Y);
		bookndb.y += 75;

		var changelogText = new FlxText(0, 0, 0, Paths.getTextFromFile('images/menus/freeplay/changelog/changelogText.txt'), 30);
		changelogText.font = Paths.font('flashing.ttf');
		changelogText.x = bookndb.x - (changelogText.width - 375);
		changelogText.screenCenter(Y);
		add(changelogText);

		var two = new FlxText(0, 0, 0, '(Press ENTER for the full list!)', 20);
		two.font = Paths.font('flashing.ttf');
		two.x = changelogText.x + 10;
		two.y = FlxG.height - 40;
		two.alpha = 0;
		add(two);

		bookndb.x = FlxG.width;
		FlxTween.tween(bookndb, {x: FlxG.width - bookndb.width}, 0.8, {ease: FlxEase.cubeOut});
		FlxTween.tween(two, {alpha: 0.6}, 1.6, {type: FlxTweenType.PINGPONG});
		
		add(bookndb);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			if (!FlxG.save.data.firstPopup) FlxG.save.data.firstPopup = true;

			FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 0},0.5);
			
			close();
			FlxG.sound.play(Paths.sound('spaceunpause'));
		}

		if (controls.ACCEPT) 
		{
			/*File.saveContent(Sys.getEnv("TEMP")+'\\BFDI 26 V1.7 - Changelog.txt', "BFDI26 v1.7 CHANGELOG
			\n MAIN CHANGES:\n- Yoylefake V1.5 - New chromatic, singing, chart, sprites, cutscenes\n- Oneshot V2 - New song, sprites, cutscenes\n- Hey Two & Who's There resprites + recharts\n- Vocal Chords, Time & Invitational & Oneshot Pico mix & Blue Golfball BF mix & Hard Bargain resprites\n- Web Crasher & Hey Two GF mixes\n- Syskill & Evil Song Pico mixes\n- Bossy resprite + Lunchbox mix\n- Invitational DD mix\n- Funny Fellow Spooky mix\n- One original song..?\n- Lots of new funfacts!
			\n QOL CHANGES:\n- New start screen + notice\n- Functional credits menu\n- New immersive menu sounds\n- Near-complete icon overhaul (save for Himsheys, KMS and Well Rounded)\n- Near-complete titlecard overhaul + new renders\n- Freeplay Dirty Bubble remake\n- RPC image fixes + remakes\n- Hey Two, Who's There, Invitational, Funny Fellow & Bossy thumbnail remakes\n- Swapped vocal tracks for KMS\n- Freeplay asset tweaks + usable scrollbar\n- Himsheys sprite tweaks\n- Hello Operator Chargerblock tweaks\n- Dotted Line sprite tweaks\n- New crash handler screen / bug report screen\n- Usable Data Reset + Individual song reset (Press R in its respective results menu)\n- General optimization
			\n MISC SONG SPECIFIC CHANGES:\n- Yoylefake - New titlecard n' render\n- Funny Fellow - New BG + RPC image\n- Wrong Finger - New titlecard + renders\n- Vocal Chords - New titlecard\n- Time - New titlecard + remade BG/FG boppers\n- Invitational - New titlecard + BG and BG boppers\n- Hey Two - New RPC\n- Blue Golfball - New titlecard + Sour Apple sprite\n- Blue Golfball BF Mix - new titlecard\n- Hello Operator - New RPC\n- Bossy - New RPC + Cutscene\n- Hard Bargain - New BGs and icons\n- Funny Fellow - BF resprite
			\n CUT CONTENT:\n- Removed Pls\n- Remove Xara... permanently");
			new Process("powershell", ['start "'+Sys.getEnv("TEMP")+'\\BFDI 26 V1.7 - Changelog.txt'+'"']);
					
			Application.current.window.focus();*/
		}
	}
}
