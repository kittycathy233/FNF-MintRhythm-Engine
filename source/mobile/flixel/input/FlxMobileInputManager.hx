package mobile.flixel.input;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import mobile.flixel.input.FlxMobileInputID;
import mobile.flixel.FlxButton;
import haxe.ds.Map;

/**
 * A FlxButton group with functions for input handling 
 */
class FlxMobileInputManager extends FlxTypedSpriteGroup<FlxButton>
{
	/**
	 * A map to keep track of all the buttons using it's ID
	 */
	public var trackedButtons:Map<FlxMobileInputID, FlxButton> = new Map<FlxMobileInputID, FlxButton>();

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
	public function buttonPressed(button:FlxMobileInputID):Bool
	{
		return anyPressed([button]);
	}

	/**
	 * Check to see if the button was just pressed.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	public function buttonJustPressed(button:FlxMobileInputID):Bool
	{
		return anyJustPressed([button]);
	}

	/**
	 * Check to see if the button was just released.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	public function buttonJustReleased(button:FlxMobileInputID):Bool
	{
		return anyJustReleased([button]);
	}

	/**
	 * Check to see if at least one button from an array of buttons is pressed.
	 *
	 * @param	buttonsArray 	An array of buttos names
	 * @return	Whether at least one of the buttons passed in is pressed.
	 */
	public function anyPressed(buttonsArray:Array<Dynamic>):Bool
	{
		return checkButtonArrayState(buttonsArray, PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just pressed.
	 *
	 * @param	buttonsArray 	An array of buttons names
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	public function anyJustPressed(buttonsArray:Array<Dynamic>):Bool
	{
		return checkButtonArrayState(buttonsArray, JUST_PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just released.
	 *
	 * @param	buttonsArray 	An array of button names
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	public function anyJustReleased(buttonsArray:Array<Dynamic>):Bool
	{
		return checkButtonArrayState(buttonsArray, JUST_RELEASED);
	}

	/**
	 * Check the status of a single button
	 *
	 * @param	Button		button to be checked.
	 * @param	state		The button state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	public function checkStatus(button:Dynamic, state:ButtonsStates = JUST_PRESSED):Bool
	{
		switch (button)
		{
			case FlxMobileInputID.ANY:
				for (button in trackedButtons.keys())
				{
					checkStatusUnsafe(button, state);
				}
			case FlxMobileInputID.NONE:
				return false;

			default:
				if (trackedButtons.exists(button))
					return checkStatusUnsafe(button, state);
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
	function checkButtonArrayState(Buttons:Array<Dynamic>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons)
			if (checkStatus(button, state))
				return true;

		return false;
	}

	function checkStatusUnsafe(button:Dynamic, state:ButtonsStates = JUST_PRESSED):Bool
	{
		return switch (state)
		{
			case JUST_RELEASED: trackedButtons.get(button).justReleased;
			case PRESSED: trackedButtons.get(button).pressed;
			case JUST_PRESSED: trackedButtons.get(button).justPressed;
		}
	}

	public function updateTrackedButtons()
	{
		trackedButtons.clear();
		forEachExists(function(button:FlxButton)
		{
			if (button.IDs != null)
			{
				for (id in button.IDs)
				{
					if (!trackedButtons.exists(id))
					{
						trackedButtons.set(id, button);
					}
				}
			}
		});
	}
}

enum ButtonsStates
{
	PRESSED;
	JUST_PRESSED;
	JUST_RELEASED;
}
