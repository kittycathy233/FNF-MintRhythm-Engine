package mobile.flixel.input;

import mobile.flixel.input.FlxMobileInputManager.ButtonsStates;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import mobile.flixel.input.FlxMobileInputID;
import mobile.flixel.FlxButton;
import haxe.ds.Map;

/**
 * A FlxButton group with functions for input handling 
 * The same as FlxMobileInputManager but uses String instead (for ClientPrefs.)
 */
class FlxMobileInputManagerByString extends FlxMobileInputManager
{
	/**
	 * A map to keep track of all the buttons using it's ID
	 */
	public var trackedButtonsTwo:Map<String, FlxButton> = new Map<String, FlxButton>();

	public function new()
	{
		super();
		updateTrackedButtons();
	}

	/**
	 * Check to see if the button was pressed.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was pressed.
	 */
	override public function buttonPressed(button:Dynamic):Bool
	{
		return anyPressed([button]);
	}

	/**
	 * Check to see if the button was just pressed.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	override public function buttonJustPressed(button:Dynamic):Bool
	{
		return anyJustPressed([button]);
	}

	/**
	 * Check to see if the button was just released.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	override public function buttonJustReleased(button:Dynamic):Bool
	{
		return anyJustReleased([button]);
	}

	/**
	 * Check to see if at least one button from an array of buttons is pressed.
	 *
	 * @param	buttonsArray 	An array of buttos names
	 * @return	Whether at least one of the buttons passed in is pressed.
	 */
	override public function anyPressed(buttonsArray:Array<Dynamic>):Bool
	{
        //trace(buttonsArray);
		return checkButtonArrayState(buttonsArray, PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just pressed.
	 *
	 * @param	buttonsArray 	An array of buttons names
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	override public function anyJustPressed(buttonsArray:Array<Dynamic>):Bool
	{
        //trace(buttonsArray);
		return checkButtonArrayState(buttonsArray, JUST_PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just released.
	 *
	 * @param	buttonsArray 	An array of button names
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	override public function anyJustReleased(buttonsArray:Array<Dynamic>):Bool
	{
        //trace(buttonsArray);
		return checkButtonArrayState(buttonsArray, JUST_RELEASED);
	}

	/**
	 * Check the status of a single button
	 *
	 * @param	Button		button to be checked.
	 * @param	state		The button state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	override public function checkStatus(button:Dynamic, state:ButtonsStates = JUST_PRESSED):Bool
	{
		switch (button)
		{
			// case FlxMobileInputID.ANY:
			// 	for (button in trackedButtons.keys())
			// 	{
			// 		checkStatusUnsafe(button, state);
			// 	}
			// case FlxMobileInputID.NONE:
			// 	return false;

			default:
                //trace(button, state);
				if (trackedButtonsTwo.exists(button)) {
                    //trace('exists');
					return checkStatusUnsafe(button, state);
                } //else {
                    //trace('Nope!');
                //}
		}
		return false;
	}

	/**
	 * Helper function to check the status of an array of buttons
	 *
	 * @param	Buttons	An array of buttons as Strings
	 * @param	state		The button state to check for
	 * @return	Whether at least one of the buttons has the specified status
	 */
	override function checkButtonArrayState(Buttons:Array<Dynamic>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons)
			if (checkStatus(button, state))
				return true;

		return false;
	}

    override function checkStatusUnsafe(button:Dynamic, state:ButtonsStates = JUST_PRESSED):Bool
	{
        //trace(button);
		return switch (state)
		{
			case JUST_RELEASED: trackedButtonsTwo.get(button).justReleased;
			case PRESSED: trackedButtonsTwo.get(button).pressed;
			case JUST_PRESSED: trackedButtonsTwo.get(button).justPressed;
		}
	}

	override public function updateTrackedButtons()
	{
		trackedButtonsTwo.clear();
		forEachExists(function(button:FlxButton)
		{
			if (button.stringIDs != null)
			{
				for (id in button.stringIDs)
				{
					if (!trackedButtonsTwo.exists(id))
					{
						trackedButtonsTwo.set(id, button);
					}
				}
			}
		});

        // for (k in trackedButtonsTwo.keys()) {
        //     trace(k);
        // }
	}
}