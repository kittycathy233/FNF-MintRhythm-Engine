package mobile.flixel.input;

import flixel.system.macros.FlxMacroUtil;

/**
 * A high-level list of unique values for mobile input buttons.
 * Maps enum values and strings to unique integer codes
 * @author Karim Akra & Lily(mcagabe19)
 */
@:runtimeValue
enum abstract FlxMobileInputID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, FlxMobileInputID> = FlxMacroUtil.buildMap("mobile.flixel.input.FlxMobileInputID");
	public static var toStringMap(default, null):Map<FlxMobileInputID, String> = FlxMacroUtil.buildMap("mobile.flixel.input.FlxMobileInputID", true);
	// Nothing & Anything
	var ANY = -2;
	var NONE = -1;
	// Buttons
	var A = 1;
	var B = 2;
	var C = 3;
	var D = 4;
	var E = 5;
	var F = 6;
	var G = 7;
	var P = 8;
	var S = 9;
	var V = 10;
	var X = 11;
	var Y = 12;
	var Z = 13;
	// VPAD Buttons
	var UP = 14;
	var UP2 = 15;
	var DOWN = 16;
	var DOWN2 = 17;
	var LEFT = 18;
	var LEFT2 = 19;
	var RIGHT = 20;
	var RIGHT2 = 21;
	// HITBOX
	var hitboxUP = 22;
	var hitboxDOWN = 23;
	var hitboxLEFT = 24;
	var hitboxRIGHT = 25;
	// PlayState Releated
	var noteUP = 26;
	var noteDOWN = 27;
	var noteLEFT = 28;
	var noteRIGHT = 29;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}
