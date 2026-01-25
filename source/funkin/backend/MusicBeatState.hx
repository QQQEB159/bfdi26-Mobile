package funkin.backend;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import funkin.backend.PsychCamera;
#if DISCORD_ALLOWED
import funkin.api.DiscordClient;
#end
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.events.Event;

class MusicBeatState extends FlxUIState
{
	public static var banlist:Array<String> = [];

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	public var controls(get, never):Controls;

	private function get_controls()
	{
		return Controls.instance;
	}

	public var touchPad:TouchPad;
	public var touchPadCam:FlxCamera;
	public var mobileControls:IMobileControls;
	public var mobileControlsCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if(touchPadCam != null)
		{
			FlxG.cameras.remove(touchPadCam);
			touchPadCam = FlxDestroyUtil.destroy(touchPadCam);
		}
	}

	public function addMobileControls(defaultDrawTarget:Bool = false):Void
	{
		var extraMode = MobileData.extraActions.get(ClientPrefs.data.extraButtons);

		switch (MobileData.mode)
		{
			case 0: // RIGHT_FULL
				mobileControls = new TouchPad('RIGHT_FULL', 'NONE', extraMode);
			case 1: // LEFT_FULL
				mobileControls = new TouchPad('LEFT_FULL', 'NONE', extraMode);
			case 2: // CUSTOM
				mobileControls = MobileData.getTouchPadCustom(new TouchPad('RIGHT_FULL', 'NONE', extraMode));
			case 3: // HITBOX
				mobileControls = new Hitbox(extraMode);
		}

		mobileControls.instance = MobileData.setButtonsColors(mobileControls.instance);
		mobileControlsCam = new FlxCamera();
		mobileControlsCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobileControlsCam, defaultDrawTarget);

		mobileControls.instance.cameras = [mobileControlsCam];
		mobileControls.instance.visible = false;
		add(mobileControls.instance);
	}

	public function removeMobileControls()
	{
		if (mobileControls != null)
		{
			remove(mobileControls.instance);
			mobileControls.instance = FlxDestroyUtil.destroy(mobileControls.instance);
			mobileControls = null;
		}

		if (mobileControlsCam != null)
		{
			FlxG.cameras.remove(mobileControlsCam);
			mobileControlsCam = FlxDestroyUtil.destroy(mobileControlsCam);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			touchPadCam = new FlxCamera();
			touchPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(touchPadCam, defaultDrawTarget);
			touchPad.cameras = [touchPadCam];
		}
	}

	override function destroy()
	{
		removeTouchPad();
		removeMobileControls();
		
		super.destroy();
	}
	
	var _psychCameraInitialized:Bool = false;

	public function new() super();

	override function create() 
	{
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if (!_psychCameraInitialized) initPsychCamera();

		super.create();

		if(!skip) findActiveState().openSubState(new CustomFadeTransition(0.7, true));
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;

		/*if (Type.getClassName(Type.getClass(FlxG.state)) != 'funkin.states.Banned')
		{
			loadBanList();

			if (banlist.contains(DiscordClient.userId))
			{
				FlxG.save.data.bannedhaha = true;

				FlxG.switchState(funkin.states.Banned.new);
				#if debug trace('ur banned'); #end
			} #if debug else trace('ur not banned'); #end
		}*/
	}

	/*public static function loadBanList() 
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
    }*/

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;

		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0) stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep) updateSection();
				else rollbackSection();
			}
		}

		if (FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) 
		{
			stage.update(elapsed);
		});

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if (curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	override function startOutro(onOutroComplete:() -> Void)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			findActiveState().openSubState(new CustomFadeTransition(0.7, false));
			CustomFadeTransition.finishCallback = onOutroComplete;
			
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		super.startOutro(onOutroComplete);
	}

	public static function getState():MusicBeatState
	{
		return cast FlxG.state;
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) 
		{
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0) beatHit();
	}

	public var stages:Array<BaseStage> = [];

	public function beatHit():Void
	{
		stagesFunc(function(stage:BaseStage) 
		{
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		stagesFunc(function(stage:BaseStage) 
		{
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages) if (stage != null && stage.exists && stage.active) func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;

		return val == null ? 4 : val;
	}

	public static function findActiveState(?state:FlxState)
	{
		state ??= FlxG.state;

		var deepest = state;
		if (state.subState != null) state = MusicBeatState.findActiveState(state.subState);

		return state;
	}
}