package options;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import Language as Lang;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	var timebarOptions:Array<String> = [
		'Time Left',
		'Time Left (Corrected)',
		'Time Elapsed',
		'Time Elapsed - Length',
		'Song Name',
		'Song Name [Difficulty]',
		'Song Name (xPB Rate)',
		'Song Percent',
		'Steps left',
		'Beats left',
		'Sections left',
		'S:B:Steps left',
		'Disabled'
	];

	public function new()
	{
		title = 'Visuals and UI';
		title = Lang.g(Lang.convert(title));
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option(Lang.g('options_opp_note_splash'),
			Lang.g('options_opp_note_splash_desc'),
			'opponentNoteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_note_splash'),
			Lang.g('options_note_splash_desc'),
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_hide_hud'),
			Lang.g('options_hide_hud_desc'),
			'hideHud',
			'bool',
			false);
		addOption(option);

		var nums = CoolUtil.numberStringArray(timebarOptions.length);
		var option:Option = new Option(Lang.g('options_time_bar'),
			Lang.g('options_time_bar_desc'),
			'timeBarType',
			'string',
			'2',
			nums);
		//trace(nums);
		addOption(option);
		option.isTimebar = true;
		option.onChange = onUpdateTimebarType;

		var option:Option = new Option(Lang.g('options_flashing_lights'),
			Lang.g('options_flashing_lights_desc'),
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_camera_zoom'),
			Lang.g('options_camera_zoom_desc'),
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_score'),
			Lang.g('options_score_desc'),
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_healthbar'),
			Lang.g('options_healthbar_desc'),
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option(Lang.g('options_fps'),
			Lang.g('options_fps_desc'),
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option(Lang.g('options_pause_song'),
			Lang.g('options_pause_song_desc'),
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option(Lang.g('options_check_for_updates'),
			Lang.g('options_check_for_updates_desc'),
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option(Lang.g('options_combostacking'),
			Lang.g('options_combostacking_desc'),
			'comboStacking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_language'),
			Lang.g('options_language_desc'),
			'language',
			'string',
			'english',
			Language.getAllLanguages());
		option.isLanguage = true;
		option.onChange = onUpdateLanguage;
		addOption(option);

		var option:Option = new Option('Transition',
			'Changes the transition between states. Press ACCEPT to preview.',
			'transition',
			'string',
			'Vertical Fade',
			['Vertical Fade', 'Horizontal Fade']);
		option.onEnter = onPreviewTransition;
		addOption(option);

		var option:Option = new Option('Show Score',
			'Toggles showing your score.',
			'showScore',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Misses',
			'Toggles showing your misses.',
			'showMisses',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Accuracy',
			'Toggles showing your accuracy.',
			'showAccuracy',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Rating',
			'Toggles showing your song rating.',
			'showRating',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show NPS',
			'Toggles showing your NPS (notes per second).',
			'showNPS',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Max NPS',
			'Toggles showing your max NPS (max notes per second).',
			'showMaxNPS',
			'bool',
			false);
		addOption(option);

		super();

		onUpdateLanguage(); //At the end of super because then it will crash
		//(the options werent added yet)
		onUpdateTimebarType(); // applies too
	}

	var changedMusic:Bool = false;
	function onPreviewTransition() {
		var daFade:CustomFadeTransition = new CustomFadeTransition(0.4, false);
		openSubState(daFade);
		CustomFadeTransition.finishCallback = function() {
			daFade.close();
			daFade = new CustomFadeTransition(0.5, true);
			openSubState(daFade);
		}
	}

	function onUpdateTimebarType() {
		for (option in optionsArray){
			if (option.isTimebar) {
				if (option.child != null) {
					option.child.text = timebarOptions[Std.parseInt(ClientPrefs.timeBarType)];
					//trace(text);
				}
			}
		}
	}

	function onUpdateLanguage()
	{
		for (option in optionsArray){
			if (option.isLanguage) {
				if (option.child != null) {
					option.child.text = Language.getLanguageDisplayStr(ClientPrefs.language);
				}
			}
		}
		descText.text = Language.g('options_language_desc');
	}

	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
