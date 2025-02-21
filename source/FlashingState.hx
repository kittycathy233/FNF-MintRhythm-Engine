package;


import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
#if lime
import lime.system.System;
#end

using StringTools;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var saveDataPath:String = '';
	var displaySaveDataPath:String = '';
	
	var bg:FlxSprite;
	var warnTextY:Float = 0;
	var manual:FlxSprite;
	var textNoAdvanced:String = "Hey, watch out!\n
								This Mod contains some flashing lights!\n
								Press ENTER to disable them now or go to Options Menu.\nPress ESCAPE to ignore this message.\n
								You've been warned!";
	var textAdvanced:String = "";

	override function create()
	{
		super.create();

		FlxG.save.data.firstTime = true;
		FlxG.save.flush();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		FlxG.mouse.visible = true;
		#if lime
	 	saveDataPath = System.applicationStorageDirectory + 'tposejank\\';
		displaySaveDataPath = StringTools.replace(saveDataPath, "\\", "/");

		textAdvanced = 	
		"Before use:\n\nEK uses a different save data folder than normal\nPsych Engine, so you are going to have to set your\noptions to what you're using.\n" + 
		#if lime
		"Save data creation path:\n\n" + displaySaveDataPath + "\n" +
		#if windows
		"Press RESET to open this folder" +
		#end
		#end
		"\n\n\n";
		#end

		manual = new FlxSprite(0, 0);
		manual.frames = Paths.getSparrowAtlas('extra-keys/manual_book');
		manual.animation.addByPrefix('normal', 'manual icon', 30, true);
		manual.animation.addByPrefix('hover', 'manual icon hover', 30, true);
		add(manual);
		manual.x = FlxG.width - manual.width;
		manual.y = FlxG.height - manual.height;
		manual.animation.play('normal', true);

		warnText = new FlxText(0, 0, FlxG.width,
			textNoAdvanced,
			8);
		warnText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (FlxG.mouse.overlaps(manual)) {
				if (manual.animation.curAnim.name != 'hover') {
					manual.animation.play('hover', true);
				}
				warnText.text = textAdvanced + textNoAdvanced;
			} else {
				if (manual.animation.curAnim != null && manual.animation.curAnim.name != 'normal') {
					manual.animation.play('normal', true);
				}
				warnText.text = textNoAdvanced;
			}
			warnText.screenCenter(Y);

			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				FlxG.mouse.visible = false;
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
			#if (lime && windows)
			if (controls.RESET) {
				var command = "explorer " + saveDataPath.toLowerCase();
				Sys.command(command);
				trace("doing command: " + command);
			}
			#end
		}
		super.update(elapsed);
	}
}