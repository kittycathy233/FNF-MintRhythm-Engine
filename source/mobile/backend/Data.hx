package mobile.backend;

import haxe.ds.StringMap;

class Data
{
	public static var dpadMode:StringMap<FlxDPadMode> = new StringMap<FlxDPadMode>();
	public static var actionMode:StringMap<FlxActionMode> = new StringMap<FlxActionMode>();
	public static var extraActions:StringMap<ExtraActions> = new StringMap<ExtraActions>();

	public static function setup()
	{
		for (data in FlxDPadMode.createAll())
			dpadMode.set(data.getName(), data);

		for (data in FlxActionMode.createAll())
			actionMode.set(data.getName(), data);

		for (data in ExtraActions.createAll())
			extraActions.set(data.getName(), data);
	}
}

enum FlxDPadMode
{
	UP_DOWN;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	LEFT_FULL;
	RIGHT_FULL;
	BOTH;
	DIALOGUE_PORTRAIT;
	MENU_CHARACTER;
	NOTE_SPLASH_DEBUG;
	NONE;
}

enum FlxActionMode
{
	A;
	B;
	B_X;
	A_B;
	A_B_C;
	A_B_E;
	A_B_X_Y;
	A_B_C_X_Y;
	A_B_C_X_Y_Z;
	A_B_C_D_V_X_Y_Z;
	CHARACTER_EDITOR;
	DIALOGUE_PORTRAIT;
	MENU_CHARACTER;
	NOTE_SPLASH_DEBUG;
	P;
	B_C;
	NONE;
}

enum ExtraActions
{
	SINGLE;
	DOUBLE;
	NONE;
}
