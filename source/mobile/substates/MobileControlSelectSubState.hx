package mobile.substates;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import mobile.backend.TouchFunctions;
import mobile.flixel.FlxButton;
import flixel.input.touch.FlxTouch;
import flixel.ui.FlxButton as UIButton;

class MobileControlSelectSubState extends MusicBeatSubstate
{
	var options:Array<String> = [#if ALL_CONTROLS 'Pad-Right', 'Pad-Left', 'Pad-Custom', 'Pad-Duo', #end 'Hitbox', 'Keyboard'];
	var control:MobileControls;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var itemText:Alphabet;
	var positionText:FlxText;
	var positionTextBg:FlxSprite;
	var bg:FlxBackdrop;
	var ui:FlxCamera;
	var curOption:Int = MobileControls.mode;
	var buttonBinded:Bool = false;
	var bindButton:FlxButton;
	var reset:UIButton;
	var tweenieShit:Float = 0;
	var keyboardText:FlxText;
	var warningText:FlxText;

	public function new()
	{
		super();
		#if ALL_CONTROLS
		if (ClientPrefs.data.extraButtons != 'NONE')
			options.push('Pad-Extra');
		#end

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true,
			FlxColor.fromRGB(255, 255, 0),
			FlxColor.fromRGB(139, 74, 255)));
		bg.velocity.set(40, 40);
		bg.alpha = 0;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.tween(bg, {alpha: 0.45}, 0.3, {
			ease: FlxEase.quadOut,
			onComplete: (twn:FlxTween) ->
			{
				FlxTween.tween(ui, {alpha: 1}, 0.2, {ease: FlxEase.circOut});
			}
		});
		add(bg);

		ui = new FlxCamera();
		ui.bgColor.alpha = 0;
		ui.alpha = 0;
		FlxG.cameras.add(ui, false);

		itemText = new Alphabet(0, 60, '');
		itemText.alignment = LEFT;
		itemText.cameras = [ui];
		add(itemText);

		leftArrow = new FlxSprite(0, itemText.y - 25);
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.cameras = [ui];
		add(leftArrow);

		itemText.x = leftArrow.width + 70;
		leftArrow.x = itemText.x - 60;

		rightArrow = new FlxSprite().loadGraphicFromSprite(leftArrow);
		rightArrow.flipX = true;
		rightArrow.setPosition(itemText.x + itemText.width + 10, itemText.y - 25);
		rightArrow.cameras = [ui];
		add(rightArrow);

		warningText = new FlxText(leftArrow.x, itemText.y + itemText.height + 100, 0, #if !ALL_CONTROLS 'Only Hitbox and Keyboard can be used in Extra Keys.' #else 'Define ALL_CONTROLS is active, some controls may not work properly.' #end, 16);
		warningText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warningText.borderSize = 2;
		add(warningText);

		positionText = new FlxText(0, FlxG.height, FlxG.width / 4, '');
		positionText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		positionText.visible = false;

		positionTextBg = FlxGradient.createGradientFlxSprite(250, 150, [FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 360);
		positionTextBg.setPosition(0, FlxG.height - positionTextBg.height);
		positionTextBg.visible = false;
		positionTextBg.alpha = 0.8;
		add(positionTextBg);
		positionText.cameras = [ui];
		add(positionText);

		keyboardText = new FlxText(0, 0, FlxG.width, "-- No Controls --", 14);
		keyboardText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, FlxTextAlign.CENTER);
		keyboardText.screenCenter();
		keyboardText.cameras = [ui];
		add(keyboardText);
		keyboardText.kill();

		var exit = new UIButton(0, itemText.y - 25, "Exit & Save", () ->
		{
			#if ALL_CONTROLS
			if (options[curOption] == 'Pad-Extra')
			{
				var nuhuh = new FlxText(0, 0, FlxG.width / 2, 'Pad-Extra Is Just A Binding Option\nPlease Select A Different Option To Exit.');
				nuhuh.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER);
				nuhuh.screenCenter();
				nuhuh.cameras = [ui];
				add(nuhuh);
				FlxTween.tween(nuhuh, {alpha: 0}, 3.4, {
					ease: FlxEase.quadInOut,
					onComplete: (twn:FlxTween) ->
					{
						nuhuh.destroy();
						remove(nuhuh);
					}
				});
				control.virtualPad.setExtrasDefaultPos();
				return;
			}
			#end
			MobileControls.mode = curOption;
			#if ALL_CONTROLS
			if (options[curOption] == 'Pad-Custom')
				MobileControls.setCustomMode(control.virtualPad);
			#end
			controls.isInSubstate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		});
		exit.color = FlxColor.LIME;
		exit.setGraphicSize(Std.int(exit.width) * 3);
		exit.updateHitbox();
		exit.x = FlxG.width - exit.width - 70;
		exit.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		exit.label.fieldWidth = exit.width;
		exit.label.x = ((exit.width - exit.label.width) / 2) + exit.x;
		exit.label.offset.y = -10; // WHY THE FUCK I CAN'T CHANGE THE LABEL Y
		exit.cameras = [ui];
		add(exit);

		reset = new UIButton(exit.x, exit.height + exit.y + 20, "Reset", () ->
		{
			changeOption(0); // realods the current control mode ig?
		});
		reset.color = FlxColor.RED;
		reset.setGraphicSize(Std.int(reset.width) * 3);
		reset.updateHitbox();
		reset.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		reset.label.fieldWidth = reset.width;
		reset.label.x = ((reset.width - reset.label.width) / 2) + reset.x;
		reset.label.offset.y = -10;
		reset.cameras = [ui];
		add(reset);

		changeOption(0);
	}

	override function update(elapsed:Float)
	{
		checkArrowButton(leftArrow, () ->
		{
			changeOption(-1);
		});

		checkArrowButton(rightArrow, () ->
		{
			changeOption(1);
		});

		#if ALL_CONTROLS
		if (options[curOption] == 'Pad-Custom' || options[curOption] == 'Pad-Extra')
		{
			if (buttonBinded)
			{
				if (TouchFunctions.touchJustReleased)
				{
					bindButton = null;
					buttonBinded = false;
				}
				else
					moveButton(TouchFunctions.touch, bindButton);
			}
			else
			{
				control.virtualPad.forEachAlive((button:FlxButton) ->
				{
					if (button.justPressed)
						moveButton(TouchFunctions.touch, button);
				});
			}
		}
		#end

		tweenieShit += 180 * elapsed;
		keyboardText.alpha = 1 - Math.sin((Math.PI * tweenieShit) / 180);

		super.update(elapsed);
	}

	function changeControls(?type:Int = null, ?extraMode:Bool = false)
	{
		if (type == null)
			type = curOption;
		if (control != null)
			control.destroy();
		if (members.contains(control))
			remove(control);
		control = new MobileControls(type #if !ALL_CONTROLS + 4 #end , extraMode);
		add(control);
		control.cameras = [ui];
	}

	function changeOption(change:Int)
	{
		curOption += change;

		if (curOption < 0)
			curOption = options.length - 1;
		if (curOption >= options.length)
			curOption = 0;

		switch (curOption)
		{
			#if ALL_CONTROLS
			case 0 | 1 | 3:
				reset.visible = false;
				keyboardText.kill();
				changeControls();
			case 2:
				reset.visible = true;
				keyboardText.kill();
				changeControls();
			#end
			case #if ALL_CONTROLS 4 #else 0 #end :
				reset.visible = false;
				keyboardText.kill();
				changeControls();
			case #if ALL_CONTROLS 5 #else 1 #end :
				reset.visible = false;
				keyboardText.revive();
				changeControls();
			#if ALL_CONTROLS
			case 6:
				reset.visible = true;
				keyboardText.kill();
				changeControls(0, true);
				control.virtualPad.forEachAlive((button:FlxButton) ->
				{
					var ignore = ['G', 'S'];
					if (!ignore.contains(button.tag.toUpperCase()))
						button.visible = button.active = false;
				});
			#end
		}
		updatePosText();
		setOptionText();
	}

	function setOptionText()
	{
		itemText.text = options[curOption].replace('-', ' ');
		itemText.updateHitbox();
		itemText.offset.set(0, 15);
		FlxTween.tween(rightArrow, {x: itemText.x + itemText.width + 10}, 0.1, {ease: FlxEase.quintOut});
	}

	function updatePosText()
	{
		#if ALL_CONTROLS
		var optionName = options[curOption];
		if (optionName == 'Pad-Custom' || optionName == 'Pad-Extra')
		{
			positionText.visible = positionTextBg.visible = true;
			if (optionName == 'Pad-Custom')
			{
				positionText.text = 'LEFT X: ${control.virtualPad.buttonLeft.x} - Y: ${control.virtualPad.buttonLeft.y}\nDOWN X: ${control.virtualPad.buttonDown.x} - Y: ${control.virtualPad.buttonDown.y}\n\nUP X: ${control.virtualPad.buttonUp.x} - Y: ${control.virtualPad.buttonUp.y}\nRIGHT X: ${control.virtualPad.buttonRight.x} - Y: ${control.virtualPad.buttonRight.y}';
			}
			else
			{
				positionText.text = 'S X: ${control.virtualPad.buttonExtra.x} - Y: ${control.virtualPad.buttonExtra.y}\n\n\n\nG X: ${control.virtualPad.buttonExtra2.x} - Y: ${control.virtualPad.buttonExtra2.y}';
			}
			positionText.setPosition(0, (((positionTextBg.height - positionText.height) / 2) + positionTextBg.y));
		}
		else #end
			positionText.visible = positionTextBg.visible = false;
	}

	function checkArrowButton(button:FlxSprite, func:Void->Void)
	{
		if (TouchFunctions.touchOverlapObject(button))
		{
			if (TouchFunctions.touchPressed)
				button.animation.play('press');
			if (TouchFunctions.touchJustPressed)
			{
				#if ALL_CONTROLS
				if (options[curOption] == "Pad-Extra" && control.virtualPad != null)
					control.virtualPad.setExtrasDefaultPos();
				#end
				func();
			}
		}
		if (TouchFunctions.touchJustReleased && button.animation.curAnim.name == 'press')
			button.animation.play('idle');
		if (FlxG.keys.justPressed.LEFT && button == leftArrow || FlxG.keys.justPressed.RIGHT && button == rightArrow)
			func();
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void
	{
		bindButton = button;
		buttonBinded = bindButton == null ? false : true;
		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);
		updatePosText();
	}
}
