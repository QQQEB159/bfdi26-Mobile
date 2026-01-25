#if !macro
//Discord API
#if DISCORD_ALLOWED
import funkin.api.DiscordClient;
#end

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

//Mobile Controls
import funkin.mobile.objects.MobileControls;
import funkin.mobile.objects.IMobileControls;
import funkin.mobile.objects.Hitbox;
import funkin.mobile.objects.TouchPad;
import funkin.mobile.objects.TouchButton;
import funkin.mobile.input.MobileInputID;
import funkin.mobile.backend.MobileData;
import funkin.mobile.input.MobileInputManager;
import funkin.mobile.backend.TouchUtil;

// Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import funkin.Paths;

import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatSubstate;
import funkin.backend.CustomFadeTransition;
import funkin.backend.Conductor;
import funkin.backend.BaseStage;
import funkin.backend.Difficulty;
import funkin.backend.Mods;
import funkin.mobile.backend.StorageUtil;

import funkin.data.Controls;
import funkin.data.ClientPrefs;

import funkin.utils.CoolUtil;
import funkin.utils.MathUtil;

import funkin.objects.Alphabet;
import funkin.objects.BGSprite;

import funkin.states.PlayState;
import funkin.states.LoadingState;

#if flxanimate
import flxanimate.*;
import funkin.flxanimate.PsychFlxAnimate as FlxAnimate;
#end

#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.openfl.*;
import funkin.objects.Video4;
#end

#if target.threaded
import sys.thread.Thread;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;
using funkin.backend.FlxObjectTools;
#end