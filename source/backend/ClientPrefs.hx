package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import states.TitleState;

// Add a variable here and it will get automatically saved
class SaveVariables {
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var autoPause:Bool = true;
	public var antialiasing:Bool = true;
	public var noteSkin:String = 'Default';
	public var splashSkin:String = 'Psych';
	public var splashAlpha:Float = 0.6;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; //From Stilic
	public var framerate:Int = 60;
	public var camZooms:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56], 
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038],
		[0xFF999999, 0xFFFFFFFF, 0xFF201E31],
		[0xFFFFFF00, 0xFFFFFFFF, 0xFF993300], //Piss note
		[0xFF8B4AFF, 0xFFFFFFFF, 0xFF3B177D],
		[0xFFFF0000, 0xFFFFFFFF, 0xFF660000],
		[0xFF0033FF, 0xFFFFFFFF, 0xFF000066],
	//	9 keys ↑ 					  	  10 keys ↓
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56], 
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038],
		[0xFF999999, 0xFFFFFFFF, 0xFF201E31],
		[0xFFFFFF00, 0xFFFFFFFF, 0xFF993300], //Piss note (Again)
		[0xFF8B4AFF, 0xFFFFFFFF, 0xFF3B177D],
		[0xFFFF0000, 0xFFFFFFFF, 0xFF660000],
		[0xFF0033FF, 0xFFFFFFFF, 0xFF000066],
	];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000],
		[0xFFB6B6B6, 0xFFFFF9FF, 0xFF444444],
		[0xFFFFD94A, 0xFFF4FFFF, 0xFF663500],
		[0xFFB055BC, 0xFFF6FFE6, 0xFF4D0060],
		[0xFFDF3E23, 0xFFFFFAF5, 0xFF440000],
		[0xFF2F69E5, 0xFFFFF9FF, 0xFF000F5D],
	//	9 keys ↑ 					  	  10 keys ↓
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000],
		[0xFFB6B6B6, 0xFFFFF9FF, 0xFF444444],
		[0xFFFFD94A, 0xFFF4FFFF, 0xFF663500],
		[0xFFB055BC, 0xFFF6FFE6, 0xFF4D0060],
		[0xFFDF3E23, 0xFFFFFAF5, 0xFF440000],
		[0xFF2F69E5, 0xFFFFF9FF, 0xFF000F5D],];

	public var ghostTapping:Bool = true;
	public var timeBarType:String = 'Time Left';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var hitsoundVolume:Float = 0;
	public var pauseMusic:String = 'Tea Time';
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;
	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		// -kade
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
	public var discordRPC:Bool = true;

	public function new()
	{
		//Why does haxe needs this again?
	}
}

class ClientPrefs {
	public static var data:SaveVariables = null;
	public static var defaultData:SaveVariables = null;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_up'		=> [W, UP],
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_right'	=> [D, RIGHT],

		'1_key_0'		=> [SPACE, W],

		'2_key_0'		=> [A, NONE],
		'2_key_1'		=> [D, S],
	
		'3_key_0'		=> [A, NONE],
		'3_key_1'		=> [S, NONE],
		'3_key_2'		=> [D, NONE],
	
		'4_key_0'		=> [A, LEFT],
		'4_key_1'		=> [S, DOWN],
		'4_key_2'		=> [W, UP],
		'4_key_3'		=> [D, RIGHT],
	
		'5_key_0'		=> [A, LEFT],
		'5_key_1'		=> [S, DOWN],
		'5_key_2'		=> [SPACE, NONE],
		'5_key_3'		=> [W, UP],
		'5_key_4'		=> [D, RIGHT],
	
		'6_key_0'		=> [S, NONE],
		'6_key_1'		=> [D, NONE],
		'6_key_2'		=> [F, NONE],
		'6_key_3'		=> [J, NONE],
		'6_key_4'		=> [K, NONE],
		'6_key_5'		=> [L, NONE],
	
		'7_key_0'		=> [S, NONE],
		'7_key_1'		=> [D, NONE],
		'7_key_2'		=> [F, NONE],
		'7_key_3'		=> [SPACE, NONE],
		'7_key_4'		=> [J, NONE],
		'7_key_5'		=> [K, NONE],
		'7_key_6'		=> [L, NONE],
	
		'8_key_0'		=> [A, NONE],
		'8_key_1'		=> [S, NONE],
		'8_key_2'		=> [D, NONE],
		'8_key_3'		=> [F, NONE],
		'8_key_4'		=> [H, NONE],
		'8_key_5'		=> [J, NONE],
		'8_key_6'		=> [K, NONE],
		'8_key_7'		=> [L, NONE],
	
		'9_key_0'		=> [A, NONE],
		'9_key_1'		=> [S, NONE],
		'9_key_2'		=> [D, NONE],
		'9_key_3'		=> [F, NONE],
		'9_key_4'		=> [SPACE, NONE],
		'9_key_5'		=> [H, NONE],
		'9_key_6'		=> [J, NONE],
		'9_key_7'		=> [K, NONE],
		'9_key_8'		=> [L, NONE],
	
		'10_key_0'		=> [A, NONE],
		'10_key_1'		=> [S, NONE],
		'10_key_2'		=> [D, NONE],
		'10_key_3'		=> [F, NONE],
		'10_key_4'		=> [G, NONE],
		'10_key_5'		=> [SPACE, NONE],
		'10_key_6'		=> [H, NONE],
		'10_key_7'		=> [J, NONE],
		'10_key_8'		=> [K, NONE],
		'10_key_9'		=> [L, NONE],
	
		'11_key_0'		=> [A, NONE],
		'11_key_1'		=> [S, NONE],
		'11_key_2'		=> [D, NONE],
		'11_key_3'		=> [F, NONE],
		'11_key_4'		=> [G, NONE],
		'11_key_5'		=> [SPACE, NONE],
		'11_key_6'		=> [H, NONE],
		'11_key_7'		=> [J, NONE],
		'11_key_8'		=> [K, NONE],
		'11_key_9'		=> [L, NONE],
		'11_key_10'		=> [PERIOD, NONE],
	
		// submitted by @btoad on discord (formerly: btoad#2337)
		'12_key_0'		=> [A, NONE],
		'12_key_1'		=> [S, NONE],
		'12_key_2'		=> [D, NONE],
		'12_key_3'		=> [F, NONE],
		'12_key_4'		=> [C, NONE],
		'12_key_5'		=> [V, NONE],
		'12_key_6'		=> [N, NONE],
		'12_key_7'		=> [M, NONE],
		'12_key_8'		=> [H, NONE],
		'12_key_9'		=> [J, NONE],
		'12_key_10'		=> [K, NONE],
		'12_key_11'		=> [L, NONE],
	
		'13_key_0'		=> [A, NONE],
		'13_key_1'		=> [S, NONE],
		'13_key_2'		=> [D, NONE],
		'13_key_3'		=> [F, NONE],
		'13_key_4'		=> [C, NONE],
		'13_key_5'		=> [V, NONE],
		'13_key_6'		=> [SPACE, NONE],
		'13_key_7'		=> [N, NONE],
		'13_key_8'		=> [M, NONE],
		'13_key_9'		=> [H, NONE],
		'13_key_10'		=> [J, NONE],
		'13_key_11'		=> [K, NONE],
		'13_key_12'		=> [L, NONE],
	
		'14_key_0'		=> [A, NONE],
		'14_key_1'		=> [S, NONE],
		'14_key_2'		=> [D, NONE],
		'14_key_3'		=> [F, NONE],
		'14_key_4'		=> [C, NONE],
		'14_key_5'		=> [V, NONE],
		'14_key_6'		=> [T, NONE],
		'14_key_7'		=> [Y, NONE],
		'14_key_8'		=> [N, NONE],
		'14_key_9'		=> [M, NONE],
		'14_key_10'		=> [H, NONE],
		'14_key_11'		=> [J, NONE],
		'14_key_12'		=> [K, NONE],
		'14_key_13'		=> [L, NONE],
	
		'15_key_0'		=> [A, NONE],
		'15_key_1'		=> [S, NONE],
		'15_key_2'		=> [D, NONE],
		'15_key_3'		=> [F, NONE],
		'15_key_4'		=> [C, NONE],
		'15_key_5'		=> [V, NONE],
		'15_key_6'		=> [T, NONE],
		'15_key_7'		=> [Y, NONE],
		'15_key_8'		=> [U, NONE],
		'15_key_9'		=> [N, NONE],
		'15_key_10'		=> [M, NONE],
		'15_key_11'		=> [H, NONE],
		'15_key_12'		=> [J, NONE],
		'15_key_13'		=> [K, NONE],
		'15_key_14'		=> [L, NONE],
	
		'16_key_0'		=> [A, NONE],
		'16_key_1'		=> [S, NONE],
		'16_key_2'		=> [D, NONE],
		'16_key_3'		=> [F, NONE],
		'16_key_4'		=> [Q, NONE],
		'16_key_5'		=> [W, NONE],
		'16_key_6'		=> [E, NONE],
		'16_key_7'		=> [R, NONE],
		'16_key_8'		=> [Y, NONE],
		'16_key_9'		=> [U, NONE],
		'16_key_10'		=> [I, NONE],
		'16_key_11'		=> [O, NONE],
		'16_key_12'		=> [H, NONE],
		'16_key_13'		=> [J, NONE],
		'16_key_14'		=> [K, NONE],
		'16_key_15'		=> [L, NONE],
	
		'17_key_0'		=> [A, NONE],
		'17_key_1'		=> [S, NONE],
		'17_key_2'		=> [D, NONE],
		'17_key_3'		=> [F, NONE],
		'17_key_4'		=> [Q, NONE],
		'17_key_5'		=> [W, NONE],
		'17_key_6'		=> [E, NONE],
		'17_key_7'		=> [R, NONE],
		'17_key_8'		=> [SPACE, NONE],
		'17_key_9'		=> [Y, NONE],
		'17_key_10'		=> [U, NONE],
		'17_key_11'		=> [I, NONE],
		'17_key_12'		=> [O, NONE],
		'17_key_13'		=> [H, NONE],
		'17_key_14'		=> [J, NONE],
		'17_key_15'		=> [K, NONE],
		'17_key_16'		=> [L, NONE],
	
		'18_key_0'		=> [A, NONE],
		'18_key_1'		=> [S, NONE],
		'18_key_2'		=> [D, NONE],
		'18_key_3'		=> [F, NONE],
		'18_key_4'		=> [SPACE, NONE],
		'18_key_5'		=> [H, NONE],
		'18_key_6'		=> [J, NONE],
		'18_key_7'		=> [K, NONE],
		'18_key_8'		=> [L, NONE],
		'18_key_9'		=> [Q, NONE],
		'18_key_10'		=> [W, NONE],
		'18_key_11'		=> [E, NONE],
		'18_key_12'		=> [R, NONE],
		'18_key_13'		=> [T, NONE],
		'18_key_14'		=> [Y, NONE],
		'18_key_15'		=> [U, NONE],
		'18_key_16'		=> [I, NONE],
		'18_key_17'		=> [O, NONE],
		
		'ui_up'			=> [W, UP],
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R],
		
		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN],
		'debug_2'		=> [EIGHT]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up'		=> [DPAD_UP, Y],
		'note_left'		=> [DPAD_LEFT, X],
		'note_down'		=> [DPAD_DOWN, A],
		'note_right'	=> [DPAD_RIGHT, B],

		'1_key_0'      => [],
		'2_key_0'      => [],
		'2_key_1'      => [],
		'3_key_0'      => [],
		'3_key_1'      => [],
		'3_key_2'      => [],
		'4_key_0'      => [],
		'4_key_1'      => [],
		'4_key_2'      => [],
		'4_key_3'      => [],
		'5_key_0'      => [],
		'5_key_1'      => [],
		'5_key_2'      => [],
		'5_key_3'      => [],
		'5_key_4'      => [],
		'6_key_0'      => [],
		'6_key_1'      => [],
		'6_key_2'      => [],
		'6_key_3'      => [],
		'6_key_4'      => [],
		'6_key_5'      => [],
		'7_key_0'      => [],
		'7_key_1'      => [],
		'7_key_2'      => [],
		'7_key_3'      => [],
		'7_key_4'      => [],
		'7_key_5'      => [],
		'7_key_6'      => [],
		'8_key_0'      => [],
		'8_key_1'      => [],
		'8_key_2'      => [],
		'8_key_3'      => [],
		'8_key_4'      => [],
		'8_key_5'      => [],
		'8_key_6'      => [],
		'8_key_7'      => [],
		'9_key_0'      => [],
		'9_key_1'      => [],
		'9_key_2'      => [],
		'9_key_3'      => [],
		'9_key_4'      => [],
		'9_key_5'      => [],
		'9_key_6'      => [],
		'9_key_7'      => [],
		'9_key_8'      => [],
		'10_key_0'     => [],
		'10_key_1'     => [],
		'10_key_2'     => [],
		'10_key_3'     => [],
		'10_key_4'     => [],
		'10_key_5'     => [],
		'10_key_6'     => [],
		'10_key_7'     => [],
		'10_key_8'     => [],
		'10_key_9'     => [],
		'11_key_0'     => [],
		'11_key_1'     => [],
		'11_key_2'     => [],
		'11_key_3'     => [],
		'11_key_4'     => [],
		'11_key_5'     => [],
		'11_key_6'     => [],
		'11_key_7'     => [],
		'11_key_8'     => [],
		'11_key_9'     => [],
		'11_key_10'    => [],
		'12_key_0'     => [],
		'12_key_1'     => [],
		'12_key_2'     => [],
		'12_key_3'     => [],
		'12_key_4'     => [],
		'12_key_5'     => [],
		'12_key_6'     => [],
		'12_key_7'     => [],
		'12_key_8'     => [],
		'12_key_9'     => [],
		'12_key_10'    => [],
		'12_key_11'    => [],
		'13_key_0'     => [],
		'13_key_1'     => [],
		'13_key_2'     => [],
		'13_key_3'     => [],
		'13_key_4'     => [],
		'13_key_5'     => [],
		'13_key_6'     => [],
		'13_key_7'     => [],
		'13_key_8'     => [],
		'13_key_9'     => [],
		'13_key_10'    => [],
		'13_key_11'    => [],
		'13_key_12'    => [],
		'14_key_0'     => [],
		'14_key_1'     => [],
		'14_key_2'     => [],
		'14_key_3'     => [],
		'14_key_4'     => [],
		'14_key_5'     => [],
		'14_key_6'     => [],
		'14_key_7'     => [],
		'14_key_8'     => [],
		'14_key_9'     => [],
		'14_key_10'    => [],
		'14_key_11'    => [],
		'14_key_12'    => [],
		'14_key_13'    => [],
		'15_key_0'     => [],
		'15_key_1'     => [],
		'15_key_2'     => [],
		'15_key_3'     => [],
		'15_key_4'     => [],
		'15_key_5'     => [],
		'15_key_6'     => [],
		'15_key_7'     => [],
		'15_key_8'     => [],
		'15_key_9'     => [],
		'15_key_10'    => [],
		'15_key_11'    => [],
		'15_key_12'    => [],
		'15_key_13'    => [],
		'15_key_14'    => [],
		'16_key_0'     => [],
		'16_key_1'     => [],
		'16_key_2'     => [],
		'16_key_3'     => [],
		'16_key_4'     => [],
		'16_key_5'     => [],
		'16_key_6'     => [],
		'16_key_7'     => [],
		'16_key_8'     => [],
		'16_key_9'     => [],
		'16_key_10'    => [],
		'16_key_11'    => [],
		'16_key_12'    => [],
		'16_key_13'    => [],
		'16_key_14'    => [],
		'16_key_15'    => [],
		'17_key_0'     => [],
		'17_key_1'     => [],
		'17_key_2'     => [],
		'17_key_3'     => [],
		'17_key_4'     => [],
		'17_key_5'     => [],
		'17_key_6'     => [],
		'17_key_7'     => [],
		'17_key_8'     => [],
		'17_key_9'     => [],
		'17_key_10'    => [],
		'17_key_11'    => [],
		'17_key_12'    => [],
		'17_key_13'    => [],
		'17_key_14'    => [],
		'17_key_15'    => [],
		'17_key_16'    => [],
		'18_key_0'     => [],
		'18_key_1'     => [],
		'18_key_2'     => [],
		'18_key_3'     => [],
		'18_key_4'     => [],
		'18_key_5'     => [],
		'18_key_6'     => [],
		'18_key_7'     => [],
		'18_key_8'     => [],
		'18_key_9'     => [],
		'18_key_10'    => [],
		'18_key_11'    => [],
		'18_key_12'    => [],
		'18_key_13'    => [],
		'18_key_14'    => [],
		'18_key_15'    => [],
		'18_key_16'    => [],
		'18_key_17'    => [],

		
		'ui_up'			=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left'		=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down'		=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right'		=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'accept'		=> [A, START],
		'back'			=> [B],
		'pause'			=> [START],
		'reset'			=> [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
	{
		if(controller != true)
		{
			for (key in keyBinds.keys())
			{
				if(defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());
			}
		}
		if(controller != false)
		{
			for (button in gamepadBinds.keys())
			{
				if(defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
			}
		}
	}

	public static function clearInvalidKeys(key:String) {
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
	}

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings() {
		for (key in Reflect.fields(data)) {
			//trace('saved variable: $key');
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}
		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

		//Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(data == null) data = new SaveVariables();
		if(defaultData == null) defaultData = new SaveVariables();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		for (key in Reflect.fields(data)) {
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key)) {
				//trace('loaded variable: $key');
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
			}
		}
		
		if(Main.fpsVar != null) {
			Main.fpsVar.visible = data.showFPS;
		}

		#if (!html5 && !switch)
		FlxG.autoPause = ClientPrefs.data.autoPause;
		#end

		if(data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		if(FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if desktop
		DiscordClient.check();
		#end

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if(save != null)
		{
			if(save.data.keyboard != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls) {
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
				}
			}
			if(save.data.gamepad != null) {
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls) {
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
				}
			}
			reloadVolumeKeys();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic {
		if(!customDefaultValue) defaultValue = defaultData.gameplaySettings.get(name);
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys() {
		TitleState.muteKeys = keyBinds.get('volume_mute').copy();
		TitleState.volumeDownKeys = keyBinds.get('volume_down').copy();
		TitleState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}
	public static function toggleVolumeKeys(turnOn:Bool) {
		if(turnOn)
		{
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		}
		else
		{
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
		}
	}
}
