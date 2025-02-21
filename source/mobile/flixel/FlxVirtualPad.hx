package mobile.flixel;

import flixel.graphics.frames.FlxTileFrames;
import mobile.flixel.input.FlxMobileInputManager;
import mobile.flixel.FlxButton;
import flixel.math.FlxPoint;

/**
 * A gamepad.
 * It's easy to customize the layout.
 *
 * @original author Ka Wing Chin & Mihai Alexandru
 * @modification's author: Karim Akra & Lily (mcagabe19)
 */
class FlxVirtualPad extends FlxMobileInputManager
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.LEFT, FlxMobileInputID.noteLEFT]);
	public var buttonUp:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.UP, FlxMobileInputID.noteUP]);
	public var buttonRight:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.RIGHT, FlxMobileInputID.noteRIGHT]);
	public var buttonDown:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.DOWN, FlxMobileInputID.noteDOWN]);
	public var buttonLeft2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.LEFT2, FlxMobileInputID.noteLEFT]);
	public var buttonUp2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.UP2, FlxMobileInputID.noteUP]);
	public var buttonRight2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.RIGHT2, FlxMobileInputID.noteRIGHT]);
	public var buttonDown2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.DOWN2, FlxMobileInputID.noteDOWN]);
	public var buttonA:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.A]);
	public var buttonB:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.B]);
	public var buttonC:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.C]);
	public var buttonD:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.D]);
	public var buttonE:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.E]);
	public var buttonF:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.F]);
	public var buttonG:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.G]);
	public var buttonS:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.S]);
	public var buttonV:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.V]);
	public var buttonX:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.X]);
	public var buttonY:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.Y]);
	public var buttonZ:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.Z]);
	public var buttonP:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.P]);
	public var buttonExtra:FlxButton = new FlxButton(0, 0);
	public var buttonExtra2:FlxButton = new FlxButton(0, 0);

	var storedButtonsIDs:Map<String, Array<FlxMobileInputID>> = new Map<String, Array<FlxMobileInputID>>();

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:FlxDPadMode, Action:FlxActionMode, ?Extra:ExtraActions = NONE)
	{
		super();

		for (button in Reflect.fields(this))
		{
			if (Std.isOfType(Reflect.field(this, button), FlxButton))
				storedButtonsIDs.set(button, Reflect.getProperty(Reflect.field(this, button), 'IDs'));
		}

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 255, 132, 127, 'up', 0xFF12FA05));
				add(buttonDown = createButton(0, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(127, FlxG.height - 135, 132, 127, 'right', 0xFFF9393F));
			case UP_LEFT_RIGHT:
				add(buttonUp = createButton(105, FlxG.height - 243, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 135, 132, 127, 'right', 0xFFF9393F));
			case LEFT_FULL:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF));
			case BOTH:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF));
			// PSYCH RELEATED BUTTONS
			case DIALOGUE_PORTRAIT:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(105, 0, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft2 = createButton(0, 82, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight2 = createButton(207, 82, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown2 = createButton(105, 190, 132, 127, 'down', 0xFF00FFFF));
			case MENU_CHARACTER:
				add(buttonUp = createButton(105, 0, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, 82, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(207, 82, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(105, 190, 132, 127, 'down', 0xFF00FFFF));
			case NOTE_SPLASH_DEBUG:
				add(buttonUp = createButton(0, 125, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft = createButton(0, 0, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight = createButton(127, 0, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown = createButton(127, 125, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(127, 393, 132, 127, 'up', 0xFF12FA05));
				add(buttonLeft2 = createButton(0, 393, 132, 127, 'left', 0xFFC24B99));
				add(buttonRight2 = createButton(1145, 393, 132, 127, 'right', 0xFFF9393F));
				add(buttonDown2 = createButton(1015, 393, 132, 127, 'down', 0xFF00FFFF));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case B:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
			case B_X:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonX = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'x', 0x99062D));
			case A_B:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_E:
				add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'e', 0xFF7D00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_X_Y:
				add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_X_Y:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_X_Y_Z:
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_D_V_X_Y_Z:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			// PSYCH RELEATED BUTTONS
			case CHARACTER_EDITOR:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonS = createButton(FlxG.width - 636, FlxG.height - 135, 132, 127, 's', 0xEA00FF));
				add(buttonF = createButton(FlxG.width - 410, 0, 132, 127, 'f', 0xFF009D));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case DIALOGUE_PORTRAIT:
				add(buttonX = createButton(FlxG.width - 384, 0, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, 125, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, 0, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, 125, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, 0, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, 125, 132, 127, 'a', 0xFF0000));
			case MENU_CHARACTER:
				add(buttonC = createButton(FlxG.width - 384, 0, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, 0, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, 0, 132, 127, 'a', 0xFF0000));
			case NOTE_SPLASH_DEBUG:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonE = createButton(FlxG.width - 132, 0, 132, 127, 'e', 0xFF7D00));
				add(buttonX = createButton(FlxG.width - 258, 0, 132, 127, 'x', 0x99062D));
				add(buttonY = createButton(FlxG.width - 132, 250, 132, 127, 'y', 0x4A35B9));
				add(buttonZ = createButton(FlxG.width - 258, 250, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
				add(buttonC = createButton(FlxG.width - 132, 125, 132, 127, 'c', 0x44FF00));
				add(buttonV = createButton(FlxG.width - 258, 125, 132, 127, 'v', 0x49A9B2));
			case P:
				add(buttonP = createButton(FlxG.width - 132, 0, 132, 127, 'x', 0x99062D));
			case B_C:
				add(buttonC = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
			case NONE: // do nothing
		}

		switch (Extra)
		{
			case SINGLE:
				add(buttonExtra = createButton(0, FlxG.height - 135, 132, 127, 's', 0xFF0066FF));
				setExtrasPos();
			case DOUBLE:
				add(buttonExtra = createButton(0, FlxG.height - 135, 132, 127, 's', 0xFF0066FF));
				add(buttonExtra2 = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'g', 0xA6FF00));
				setExtrasPos();
			case NONE: // nothing
		}

		for (button in Reflect.fields(this))
		{
			if (Std.isOfType(Reflect.field(this, button), FlxButton))
				Reflect.setProperty(Reflect.getProperty(this, button), 'IDs', storedButtonsIDs.get(button));
		}
		scrollFactor.set();
		updateTrackedButtons();
	}

	public function setExtrasDefaultPos()
	{
		var int:Int = 0;

		if (FlxG.save.data.extraData == null)
			FlxG.save.data.extraData = new Array();

		for (button in Reflect.fields(this))
		{
			if (button.toLowerCase().contains('extra') && Std.isOfType(Reflect.field(this, button), FlxButton))
			{
				var daButton = Reflect.field(this, button);
				if (FlxG.save.data.extraData[int] == null)
					FlxG.save.data.extraData.push(FlxPoint.get(daButton.x, daButton.y));
				else
					FlxG.save.data.extraData[int] = FlxPoint.get(daButton.x, daButton.y);
				++int;
			}
		}
		FlxG.save.flush();
	}

	public function setExtrasPos()
	{
		var int:Int = 0;
		if (FlxG.save.data.extraData == null)
			return;

		for (button in Reflect.fields(this))
		{
			if (button.toLowerCase().contains('extra') && Std.isOfType(Reflect.field(this, button), FlxButton))
			{
				var daButton = Reflect.field(this, button);
				daButton.x = FlxG.save.data.extraData[int].x;
				daButton.y = FlxG.save.data.extraData[int].y;
				int++;
			}
		}
	}

	private function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?Color:Int = 0xFFFFFF):FlxButton
	{
		var button = new FlxButton(X, Y);
		button.frames = FlxTileFrames.fromFrame(Paths.getSparrowAtlas('virtualpad').getByName(Graphic), FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.moves = false;
		button.scrollFactor.set();
		button.color = Color;
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.tag = Graphic.toUpperCase();
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		return button;
	}

	override public function destroy():Void
	{
		super.destroy();

		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
		buttonLeft2 = FlxDestroyUtil.destroy(buttonLeft2);
		buttonUp2 = FlxDestroyUtil.destroy(buttonUp2);
		buttonDown2 = FlxDestroyUtil.destroy(buttonDown2);
		buttonRight2 = FlxDestroyUtil.destroy(buttonRight2);
		buttonA = FlxDestroyUtil.destroy(buttonA);
		buttonB = FlxDestroyUtil.destroy(buttonB);
		buttonC = FlxDestroyUtil.destroy(buttonC);
		buttonD = FlxDestroyUtil.destroy(buttonD);
		buttonE = FlxDestroyUtil.destroy(buttonE);
		buttonF = FlxDestroyUtil.destroy(buttonF);
		buttonG = FlxDestroyUtil.destroy(buttonG);
		buttonS = FlxDestroyUtil.destroy(buttonS);
		buttonV = FlxDestroyUtil.destroy(buttonV);
		buttonX = FlxDestroyUtil.destroy(buttonX);
		buttonY = FlxDestroyUtil.destroy(buttonY);
		buttonZ = FlxDestroyUtil.destroy(buttonZ);
		buttonP = FlxDestroyUtil.destroy(buttonP);
		buttonExtra = FlxDestroyUtil.destroy(buttonExtra);
		buttonExtra2 = FlxDestroyUtil.destroy(buttonExtra2);
	}
}
