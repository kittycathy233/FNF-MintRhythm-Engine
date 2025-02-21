package options;

import flixel.math.FlxMath;
import flixel.FlxSprite;
import alphabet.AttachedOptionText;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import Controls;
import Language as Lang;
import alphabet.Alphabet;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay' #if PRELOAD_ALL , 'Song Player' #end];
	var descriptions:Array<String> = ['Edit the notes\' colors.', 'Edit your keybinds.', 'Adjust the music delay and combo positions.', 'Change graphical settings.', 'Change gameplay settings.', 'Change UI settings.', 'Open the Song Player'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	var opening:Bool = false;

	function openSelectedSubstate(label:String) {
		if (!opening) {
			var dumb:String = label.toLowerCase().replace(' ', '');
			if (dumb != 'adjustdelayandcombo' && dumb != 'songplayer') {
				openSubState(new CustomFadeTransition(0.4, false));
				CustomFadeTransition.finishCallback = function() {
					switch(label) {
						case 'Note Colors':
							openSubState(new options.NotesSubState());
						case 'Controls':
							openSubState(new options.ControlsSubState());
						case 'Graphics':
							openSubState(new options.GraphicsSettingsSubState());
						case 'Visuals and UI':
							openSubState(new options.VisualsUISubState());
						case 'Gameplay':
							openSubState(new options.GameplaySettingsSubState());
					}
				}
			} else {
				switch(label){
					case 'Adjust Delay and Combo':
						LoadingState.loadAndSwitchState(new options.NoteOffsetState());
					case 'Song Player':
						MusicBeatState.switchState(new options.SongPlayer());
				}
			}
			persistentUpdate = false;
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var grpDescriptions:FlxTypedGroup<Alphabet>;

	override function create() {
		persistentUpdate = true;
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		grpDescriptions = new FlxTypedGroup<Alphabet>();
		add(grpDescriptions);

		FlxG.mouse.visible = true;
		reloadTexts();

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	function reloadTexts() {
		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(150, 320, Lang.g(Lang.convert(options[i])), true);
			//optionText.screenCenter();
			//optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;
			//optionText.scaleX = 0.7;
			//optionText.scaleY = 0.7;
			optionText.startedAs = options[i];
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var optionDesc:AttachedOptionText = new AttachedOptionText(descriptions[i], 0, -20, false, 0.35, FlxG.width);
			optionDesc.sprTracker = optionText;
			optionDesc.copyAlpha = true;
			grpDescriptions.add(optionDesc);
		}
	}

	override function closeSubState() {
		super.closeSubState();

		persistentUpdate = true;
		if (opening) 
			openSubState(new CustomFadeTransition(0.5, true));

		opening = false;
		ClientPrefs.saveSettings();
		Language.initLanguage();

		for (member in grpOptions.members) {
			member.kill();
			grpOptions.remove(member);
		}
		for (member in grpDescriptions.members) {
			member.kill();
			grpDescriptions.remove(member);
		}
		reloadTexts();

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
			opening = true;
		}

		if (FlxG.mouse.wheel != 0) {
			changeSelection(-FlxG.mouse.wheel);
		}

		for (item in grpOptions.members) {
			if (item.targetY == 0) {
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}

			if (FlxG.mouse.overlaps(item)) {
				if (item.targetY != 0) {
					item.alpha = FlxMath.lerp(item.alpha, 1, elapsed * 3);
				}
				if (FlxG.mouse.justPressed) {
					openSelectedSubstate(item.startedAs);
				}
			} else if (item.targetY != 0) item.alpha = FlxMath.lerp(item.alpha, 0.6, elapsed * 3);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.autoAlpha = true;
			if (item.targetY == 0) {
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}