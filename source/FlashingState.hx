package;

import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var languageText:FlxText;
	var languages:Array<String> = [];
	var curLang:Int = 0;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 200, FlxG.width,
		Language.g('flashing_lights_warning_text'),
		32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		//warnText.screenCenter();
		add(warnText);

		languages = Language.getAllLanguages();

		languageText = new FlxText(0, 500, FlxG.width,
		Language.g('flashing_lights_language_text').replace('%n', '' + languages.length).replace('%s', languages.length > 1 ? "s" : ""),
		32);
		languageText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		add(languageText);
		updateLanguage();

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function updateLanguage(c:Int = 0) {
		curLang += c;

		if (curLang >= languages.length) curLang = 0;
		else if (curLang < 0) curLang = languages.length - 1;

		Language.changeLanguage(languages[curLang]);

		warnText.text = Language.g('flashing_lights_warning_text');
		languageText.text = Language.g('flashing_lights_language_text').replace('%n', '' + languages.length).replace('%s', languages.length > 1 ? "s" : "") + '\n< ' + Language.getLanguageDisplayStr(Language.currentLanguage) + ' >';

		//thank you ralt for the dialogue text sound suggestion
		//also put c != 0 so that this bitch wont play when launch!
		//also also put shared becasue it wouldnt work !! :sob:
		if (c != 0) FlxG.sound.play(Paths.sound('dialogue', "shared"));
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				} else {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				}
				FlxTween.tween(languageText, {y: FlxG.height}, 0.3, {ease: FlxEase.circOut});
			}
			var left:Bool = controls.UI_LEFT_P;
			if (left || controls.UI_RIGHT_P) {
				if (left) updateLanguage(-1);
				else updateLanguage(1);
			}
		}
		super.update(elapsed);
	}
}
