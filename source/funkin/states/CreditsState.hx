package funkin.states;

import flixel.FlxObject;
import funkin.shaders.WiggleEffect;
import funkin.shaders.WiggleEffect.WiggleEffectType;

class CreditsState extends MusicBeatState
{
	var coolwiggle:WiggleEffect;
	var bg:FlxSprite;

	var credits:FlxTypedGroup<FlxObject>;
	var descriptions:Array<Array<String>> = [
		// ----- MAIN CREDITS -----
        ["Composer", "https://x.com/uncommonblin"], ["Composer", "https://x.com/Legogodzilla702"], ["Charter", "https://x.com/FlootenaDX"], ["Artist, Voice Actor", "https://x.com/dommiexists"], ["Composer", "https://x.com/VanillaaVani"], // first row
		["Composer", "https://x.com/koviklutz"], ["Coder", "https://x.com/ivyanimations"], ["Composer", "https://x.com/ChucksterTL"], ["Composer", "https://x.com/kobai_kid"], ["Voice Actor", "https://x.com/GoodieBag78"], // second row
		["Artist", "https://x.com/percjac0"], ["Composer", "https://x.com/Jautrey10"], ["Composer", "https://x.com/existnt_k"], ["Composer", "https://x.com/thegabim_"], ["Composer", "https://x.com/Ascenti4"], // third row
		["Composer, Chromatics", "https://youtube.com/@pt_award"], ["Chromatics, Voice Actor", ""], ["Composer", "https://x.com/nerdemoji2763"], ["Composer", "https://x.com/funkypoppp"], ["Artist", "https://x.com/michimoomo"], // fourth row
		["Chromatics", "https://www.youtube.com/@KrunchyK/"], ["Artist, Composer", "https://x.com/hypsk8r"], ["Composer", "https://x.com/ahhhloof"], ["Composer, Chromatics \n Xara", "https://x.com/YtSwolfy"], ["Artist", "https://x.com/Nyantaktt"], // fifth row
		["Artist, Chromatics", "https://x.com/wrptoonz"], ["Coder", "https://x.com/MichellePVZ"], ["Composer", "https://x.com/vaderlings"], ["Composer", "https://x.com/phynsiclemusic"], ["Coder", "https://x.com/staticfyre"], // sixth row
		["Artist, Animator", "https://x.com/Deroxx12"], ["Composer", "https://x.com/spikeish_"], ["Artist", "https://x.com/cherryuplol"], ["Artist", "https://x.com/_NinjaMonk_"], ["Composer", "https://x.com/EmperorKhanz"], // seventh row
		["Artist", "https://x.com/JObjects"], ["Artist", "https://x.com/OLLIEE617283"], ["Artist, Composer", "https://x.com/azuwure_"], ["Artist, Composer","https://x.com/heyitsmekayla__"], ["Coder", "https://x.com/vechettlol"], // eighth row

		// ----- SPECIAL THANKS -----
		["Made the original concept Yoylefake was based on", "https://x.com/bryin64"], ["Started the wiki page", "https://www.youtube.com/@cheesefarmer6139"], ["Guest Composor on Invitational Dearest Mix", "https://x.com/sp0reshroom"],
		["Made the website", "https://x.com/whiteninja00"], ["Former Charter, Wiki starter", "https://x.com/ColeRocks08"], ["Made the Human Hourglass design used in Webcrasher GF Mix", "https://x.com/LLOR0MANN1C"],
		["Guest 3D modeler and Animator for Aldi", "https://x.com/Coolbacon10"], ["Voice Actor for Strawberry Milk", "https://x.com/slinkyraccoon"], ["Former Composer", "https://x.com/n1ffirg"],

		// ----- DIRECTORS -----
		["Artist, Animator, Composer", "https://x.com/AidenDoesStuff1"], ["Lead Coder, Charter", "https://x.com/Blam_Daylight"], ["Lead Artist, Animator, Voice Actor", "https://x.com/flaskcastle"], ["Composer, Charter", "https://www.youtube.com/@ezzythecat"]

    ];

	var curSelected:Int = -1;
    var frame:CreditFrame;
	var hitbox:FlxObject;

	override function create()
	{
		Paths.clearStoredMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("BFDI 26 - DEVELOPMENT TEAM", null);
		#end

		persistentUpdate = true;

		coolwiggle = new WiggleEffect();
		coolwiggle.effectType = WiggleEffectType.DREAMY;
		coolwiggle.waveAmplitude = 0.4;
		coolwiggle.waveFrequency = 2;
		coolwiggle.waveSpeed = 1.5;

		bg = new FlxSprite().loadImage('CMIX-bg');
		bg.screenCenter();
		bg.setGraphicSize(0,FlxG.width-555);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.shader = coolwiggle.shader;
		add(bg);

		var p = new FlxSprite().loadImage('CMIX-no-bg');
		p.screenCenter();
		p.setGraphicSize(0,FlxG.width-555);
		p.antialiasing = ClientPrefs.data.antialiasing;
		add(p);

		credits = new FlxTypedGroup<FlxObject>();
        add(credits);

		// this sucks
		final pos:Array<Dynamic> = [
			// ----- MAIN CREDITS -----
			[12, 86], [175, 86], [340, 86], [505, 86], [667, 86], // first row
			[12, 157], [175, 157], [340, 157], [505, 157], [667, 157], // second row
			[12, 228], [175, 228], [340, 228], [505, 228], [667, 228], // third row
			[12, 301], [175, 301], [340, 301], [505, 301], [667, 301], // fourth row
			[12, 372], [175, 372], [340, 372], [505, 372], [667, 372], // fifth row
			[12, 443], [175, 443], [340, 443], [505, 443], [667, 443], // sixth row
			[12, 515], [175, 515], [340, 515], [505, 515], [667, 515], // seventh row
			[12, 585], [175, 585], [340, 585], [505, 585], [667, 585], // eighth row

			// ----- SPECIAL THANKS -----
			[855, 113, 130, 50], [995, 113, 130, 50], [1133, 113, 130, 50], // first row
			[855, 174, 130, 50], [995, 174, 130, 50], [1133, 174, 130, 50], // second row
			[855, 235, 130, 50], [995, 235, 130, 50], [1133, 235, 130, 50], // third row

			// ----- DIRECTORS -----
			[848, 593, 120, 25], [970, 406, 120, 25], [1163, 635, 100, 25], [965, 367, 100, 25]
		];

        for (i in 0...pos.length) 
		{
            var hitbox = new FlxObject(pos[i][0], pos[i][1], (pos[i][2] != null ? pos[i][2] : 145), (pos[i][3] != null ? pos[i][3] : 60));
            credits.add(hitbox);
        }

		hitbox = new FlxObject(3, 82, 320, 600);
        add(hitbox);

		FlxG.sound.playMusic(Paths.music('Creditstheme'));
		FlxG.sound.music.volume = 0.8;
		FlxG.camera.zoom += 0.28;
		
		frame = new CreditFrame();
		frame.visible = false;
        add(frame);
		
		super.create();

		Paths.clearUnusedMemory();
	}

	var stop:Bool = false;
	//var amount:Float = 0.0;
	override function update(elapsed:Float)
	{	
		super.update(elapsed);

		//amount += elapsed * 20;
		//if (amount >= 360) amount = 0;
		//bg.color = FlxColor.fromHSL(amount, 1, 0.5, 1);

		if (controls.BACK && !stop) goodbye();
		coolwiggle.update(elapsed);

		if (mouseOverlapsGroup(credits)) 
		{
            for (i in 0...credits.length) 
			{
                if (curSelected != i && mouseOverlap(credits.members[i])) 
				{
                    curSelected = i;

                    if (descriptions[i] != null) 
					{
                        frame.setText(descriptions[i][0]);
                        if (!frame.visible) frame.visible = true;
                    }
                }
            }

			if (FlxG.mouse.justPressed) CoolUtil.browserLoad(descriptions[curSelected][1]);
		} 
		else if (curSelected != -1) 
		{       
            curSelected = -1;
            if (frame.visible) frame.visible = false;
        }

		frame.over = (mouseOverlap(hitbox) ? true : false);
    }

	function goodbye() 
	{
		stop = true;
		
		FlxG.sound.play(Paths.sound('spaceunpause'));
		FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.9},2, {ease: FlxEase.sineInOut});
		
		new FlxTimer().start(0.4,Void -> 
		{
			FlxG.sound.music.fadeOut(0.7);
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function() 
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.switchState(funkin.states.NewMain.new);
			});
		});
	}

	//this is so stupid
	function mouseOverlap(obj:FlxObject = null, ?cam:FlxCamera = null):Bool 
	{
        if (obj == null) return false;
        return ((FlxG.mouse.getScreenPosition(cam).x > obj.x && FlxG.mouse.getScreenPosition(cam).x < obj.x+obj.width) && (FlxG.mouse.getScreenPosition(cam).y > obj.y && FlxG.mouse.getScreenPosition(cam).y < obj.y+obj.height));
    }

	function mouseOverlapsGroup(grp:FlxTypedGroup<Dynamic> = null, ?cam:FlxCamera = null):Bool 
	{
        if (grp == null) return false;

        for (obj in grp.members) 
		{
            if ((FlxG.mouse.getScreenPosition(cam).x > obj.x && FlxG.mouse.getScreenPosition(cam).x < obj.x+obj.width) && (FlxG.mouse.getScreenPosition(cam).y > obj.y && FlxG.mouse.getScreenPosition(cam).y < obj.y+obj.height)) return true;
        }

        return false;
    }
}

class CreditFrame extends FlxSpriteGroup 
{
    public var frameSprite:FlxSprite;
    public var text:FlxText;
	public var over:Bool = false;
	
    public function new() 
	{
        super();
        
        frameSprite = new FlxSprite().makeGraphic(1, 1, 0xFF1F1F1F);
        frameSprite.alpha = 0.5;
        add(frameSprite);

        text = new FlxText(0, 0, 325, "p", 24);
        text.setFormat(Paths.font('YouTubeSansRegular.otf'), 24);
        text.bold = true;
        add(text);

        frameSprite.scale.set(text.frameWidth+2, text.height+2);
        frameSprite.updateHitbox();
    }

    public function setText(t:String = '') 
	{
        text.text = t;
        frameSprite.scale.set(text.frameWidth-10, text.height+2);
		//frameSprite.setGraphicSize((text.textField.textWidth) + 2, (text.textField.textHeight) + 2);
        frameSprite.updateHitbox();
    }

    override function update(elapsed:Float) 
	{
        this.setPosition(FlxG.mouse.getScreenPosition().x + (over ? 20 : -frameSprite.width), FlxG.mouse.getScreenPosition().y);

		super.update(elapsed);
    }
}