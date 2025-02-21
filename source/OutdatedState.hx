package;

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

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var newVersion:String = '';
	var updateEK:Bool = false;
	var updateEKVer:String = '';

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey! The Psych Engine version you're using
			is currently out of date. \nTo update to the
			latest one, wait until \nPsych Engine with
			Extra Keys is updated. To check and
			download\n the latest version press your ACCEPT key,
			if you wish to ignore, press your BACK key.\n\n
			Current version: " + MainMenuState.psychEngineVersion + " - Newest version: " + newVersion + "\n
			\nPlease be patient until Psych Engine with
			Extra Keys is updated.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		if (updateEK) {
			warnText.text = "Hey! The Psych Engine EK version you're using 
			is currently out of date. \nTo update to the latest EK version,
			press your ACCEPT key!\nIf you wish to ignore, press BACK.\n
			\nCurrent version: " + MainMenuState.extraKeysVersion + " - Newest version: " + updateEKVer + "\n";
			warnText.screenCenter(Y);
		}
	}

	public function new(newVer:String, mustUpdateEK:Bool = false, updateEKVer:String = '')
	{
		newVersion = newVer;
		updateEK = mustUpdateEK;
		this.updateEKVer = updateEKVer;
		super();
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://gamebanana.com/mods/333373");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
