package openfl.display;

import openfl.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
import flixel.FlxG;
import openfl.Assets;
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end
import openfl.system.System;

using StringTools;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
	
	some of these functions were taken from https://github.com/EyeDaleHim/FNF-Mechanics/blob/main/source/openfl/display/FPS.hx
	because i'm stupid!
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(getFont(Paths.font("vcr.ttf")), 16, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		//border = null;
		//borderColor = 0xFF000000; this actually made a boundary box

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	public function getFont(Font:String):String
	{
		embedFonts = true;

		var newFontName:String = Font;

		if (Font != null)
		{
			if (Assets.exists(Font, AssetType.FONT))
			{
				newFontName = Assets.getFont(Font).fontName;
			}
		}
		return newFontName;
	}
	public var maxMemory:Float;
	public var realFps:Int = 0;
	public var theLagIsReal:Bool = false;
	public var memOverloaded:Bool = false;
	public var _ms:Float;
	public var updateMemTimer:Float = 0.0;
	public var textUpdates:Int = 0;
	public var textCanBecomeRed:Bool = true;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;

		currentFPS = Math.round((currentCount + cacheCount) / 2);
		realFps = currentFPS;

		if (currentFPS > ClientPrefs.framerate && ClientPrefs.framerate != 241)
			currentFPS = ClientPrefs.framerate;

		updateMemTimer += FlxG.elapsed;

		if (currentCount != cacheCount || updateMemTimer >= 1 /*&& visible*/)
		{
			textUpdates++;
			stupidFuckingShit();
		}

		cacheCount = currentCount;
	}

	function stupidFuckingShit() {
		text = "FPS: " + currentFPS #if (debug && stats) + ", un-rounded: " + realFps #end;
		var memoryMegas:Float = 0;

		updateMemTimer = 0.0;

		#if openfl
		memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
		text += "\n" + Language.g('fps_memory', "Memory") + ": " + memoryMegas + " MB";

		if (memoryMegas >= maxMemory)
			maxMemory = memoryMegas;

		#if (debug && stats)
		text += ", peak: " + maxMemory + " MB";
		#end
		#end

		theLagIsReal = false;
		textColor = 0xFFFFFFFF;
		alpha = 1;
		var lowFramerate:Int = 40;
		if (ClientPrefs.framerate <= 40) lowFramerate = 20;
		if (currentFPS <= lowFramerate || memoryMegas > 2500) { // You cant say its bad fps if you have 240 & its 120
			theLagIsReal = true;
			if (memoryMegas > 2500)
				memOverloaded = true;

			if (textCanBecomeRed)
				textColor = 0xFFFF0000;
		}
	
		if (theLagIsReal) {
			#if debug
			if (memOverloaded) {
				text += "\nMemory overloaded!";
			}
			#end
		} else {
			alpha = 0.8;
		}
		
		#if (debug && stats)
		text += "\n";
		text += "\nDEBUG:";

		_ms = FlxMath.lerp(_ms, 1 / Math.round(currentFPS) * 1000, CoolUtil.boundTo(FlxG.elapsed * 3.75 * ((Math.abs(_ms - 1 / Math.round(currentFPS) * 1000) < 0.45) ? 2.5 : 1.0), 0, 1));
		text += '\nMs: ${FlxMath.roundDecimal(_ms, 2)}';
		text += '\nRuntime: ${FlxStringUtil.formatTime(currentTime / 1000)}';
		text += '\nText updates: $textUpdates';
		text += '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}';
		if (FlxG.state.subState != null)
			text += '\nSubstate: ${Type.getClassName(Type.getClass(FlxG.state.subState))}';
		text += '\nObjects: ${FlxG.state.members.length}';
		#end
				
		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += "\n";
		text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
		text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
		text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end
		text += "\n";
	}
}
