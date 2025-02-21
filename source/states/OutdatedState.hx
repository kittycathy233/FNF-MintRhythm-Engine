package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	private var defaultPsychEnginePrompt:String = "Sup bro, looks like you're running an   \n
	outdated version of Psych Engine (" + MainMenuState.psychEngineVersion + "),\n
	please update to " + TitleState.updateVersion + "!\n
	Press ESCAPE to proceed anyway.\n
	\n
	Thank you for using the Engine!";
	
	private var updatePrompts:Map<String, String> = [
		'psych-engine' => "Sup bro, looks like you're running an
		outdated version of Psych Engine (" + MainMenuState.psychEngineVersion + "),
		you can download the latest version (if available)
		with the included installer in the exe's folder...
		The latest Psych Engine version is " + TitleState.updateVersion + ".
		Press ESCAPE to proceed anyway.
		\n
		Thank you for using Extra Keys!",

		'extra-keys' => "Sup bro, looks like you're running an
		outdated version of Extra Keys (" + MainMenuState.extraKeysVersion + "),
		you can download the latest version (if available)
		with the included installer in the exe's folder...
		The latest Extra Keys version is " + TitleState.updateVersion + ".
		Press ESCAPE to proceed anyway.
		\n
		Thank you for using Extra Keys!",

		'both-softwares' => "Sup bro, looks like you need to
		update both Psych Engine and Extra Keys...
		you can download the latest version (if available)
		with the included installer in the exe's folder...
		Press ESCAPE to proceed anyway.
		\n
		Thank you for using Extra Keys!"
	];

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			updatePrompts.get(TitleState.updateType),
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				//CoolUtil.browserLoad("https://github.com/ShadowMario/FNF-PsychEngine/releases");
			}
			if(controls.BACK) {
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
