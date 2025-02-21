package mobile.psychlua;

#if LUA_ALLOWED
import llua.*;
import llua.Lua;
import lime.ui.Haptic;
import psychlua.FunkinLua;
import mobile.backend.TouchFunctions;

class MobileFunctions
{
	public static function implement(funk:FunkinLua)
	{
		funk.set('mobileControlsMode', getMobileControlsAsString());

		funk.set("extraButtonPressed", function(button:String)
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.pressed;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.pressed;
				}
			}
			return false;
		});

		funk.set("extraButtonJustPressed", function(button:String)
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.justPressed;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.justPressed;
				}
			}
			return false;
		});

		funk.set("extraButtonJustReleased", function(button:String)
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.justReleased;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.justReleased;
				}
			}
			return false;
		});

		funk.set("vibrate", function(duration:Null<Int>, ?period:Null<Int>)
		{
			if (period == null)
				period = 0;
			if (duration == null)
				return FunkinLua.luaTrace('vibrate: No duration specified.');
			return Haptic.vibrate(period, duration);
		});

		funk.set("addVirtualPad", (DPadMode:String, ActionMode:String) ->
		{
			PlayState.instance.makeLuaVirtualPad(DPadMode, ActionMode);
			PlayState.instance.addLuaVirtualPad();
		});

		funk.set("removeVirtualPad", () ->
		{
			PlayState.instance.removeLuaVirtualPad();
		});

		funk.set("addVirtualPadCamera", () ->
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				FunkinLua.luaTrace('addVirtualPadCamera: VPAD does not exist.');
				return;
			}
			PlayState.instance.addLuaVirtualPadCamera();
		});

		funk.set("virtualPadJustPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				//FunkinLua.luaTrace('virtualPadJustPressed: VPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadJustPressed(button);
		});

		funk.set("virtualPadPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				//FunkinLua.luaTrace('virtualPadPressed: VPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadPressed(button);
		});

		funk.set("virtualPadJustReleased", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				//FunkinLua.luaTrace('virtualPadJustReleased: VPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadJustReleased(button);
		});

		funk.set("touchJustPressed", TouchFunctions.touchJustPressed);
		funk.set("touchPressed", TouchFunctions.touchPressed);
		funk.set("touchJustReleased", TouchFunctions.touchJustReleased);
		funk.set("touchPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchPressed;
		});

		funk.set("touchJustPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustPressed;
		});

		funk.set("touchJustReleasedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustReleased;
		});

		funk.set("touchOverlapsObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchOverlapsObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj);
		});
	}

	public static function getMobileControlsAsString():String
	{
		switch (MobileControls.mode)
		{
			case 0:
				return 'left';
			case 1:
				return 'right';
			case 2:
				return 'custom';
			case 3:
				return 'duo';
			case 4:
				return 'hitbox';
			case 5:
				return 'none';
		}
		return 'uknown';
	}
}

#if android
class AndroidFunctions
{
	public static function implement(funk:FunkinLua)
	{
		funk.set("backJustPressed", FlxG.android.justPressed.BACK);
		funk.set("backPressed", FlxG.android.pressed.BACK);
		funk.set("backJustReleased", FlxG.android.justReleased.BACK);

		funk.set("menuJustPressed", FlxG.android.justPressed.MENU);
		funk.set("menuPressed", FlxG.android.pressed.MENU);
		funk.set("menuJustReleased", FlxG.android.justReleased.MENU);
	}
}
#end
#end
