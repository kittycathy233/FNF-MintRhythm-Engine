package;

import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import song.Song;
import editors.charter.ChartingState;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import alphabet.Alphabet;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var bopIcon:Int = -1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	
	var textBG:FlxSprite;
	var infoText:FlxText;

	public static var infScroll:Bool = false;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		// IGNORE THIS!!!
		var titleJSON = haxe.Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));
		Conductor.changeBPM(titleJSON.bpm);
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				var cover:String = song[3];
				if (cover == null && cover.length < 1) cover = 'classic';
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), cover);
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			songText.autoAlpha = true;
			grpSongs.add(songText);

			//if (i % 2 == 0) songText.scroll = DEFAULT_RIGHT; lol

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			switch (songText.scroll) {
				case C | C_SHARP | DEFAULT_RIGHT:
					icon.sprTrackerXOffset = -(icon.width + 24);
				default:
					icon.sprTrackerXOffset = songText.width;
			}

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		if (songs.length > 0)
			bg.color = songs[curSelected].color;
		else
			bg.color = 0xFF4C0000;

		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		textBG = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = Language.g('freeplay_bottom');
		#else
		var leText:String = Language.g('freeplay_bottom_no_preload_all');
		#end
		if (songs.length < 1)
			leText = Language.g('freeplay_no_songs');

		infoText = new FlxText(textBG.x, FlxG.height, FlxG.width, leText, 16);
		infoText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		infoText.scrollFactor.set();
		add(infoText);

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();

		FlxTween.tween(textBG, {y: FlxG.height - infoText.height - 8}, 1.5, {
			ease: FlxEase.bounceOut,
			onUpdate: function(twn) {
				infoText.y = textBG.y + 4;
			}
		});
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, cover:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, cover));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
		for (icon in iconArray) {
			icon.scale.x = FlxMath.lerp(1, icon.scale.x, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
			icon.scale.y = FlxMath.lerp(1, icon.scale.y, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = Language.g('freeplay_pb').replace('%r', ': ' + lerpScore);
		scoreText.text += '\n' + Language.g('freeplay_ba').replace('%r', ': ' + ratingSplit.join('.') + '%\n');
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;
		var shift = FlxG.keys.pressed.SHIFT;
		var alt = FlxG.keys.pressed.ALT;

		var scrollMult:Int = 1;
		if(alt) scrollMult = 2;

		holdTime += elapsed;
		if(songs.length > 0)
		{
			if (upP || (controls.UI_UP && shift && holdTime > 0.05))
			{
				changeSelection(-scrollMult);
				holdTime = 0;
			}
			if (downP || (controls.UI_DOWN && shift && holdTime > 0.05))
			{
				changeSelection(scrollMult);
				holdTime = 0;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-scrollMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if ((upP || downP || controls.UI_RIGHT_P || controls.UI_LEFT_P) && songs.length < 1)
			FlxG.sound.play(Paths.sound('cancelMenu'));

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if (songs.length > 0) {
				if(instPlaying != curSelected)
				{
					#if PRELOAD_ALL
					openSubState(new options.SongPlayer.PlayerSubstate(songs[curSelected], curDifficulty, true));
					persistentUpdate = false;
					#end
				}
			}
		}

		else if (accepted)
		{
			if (songs.length > 0) {
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				/*#if MODS_ALLOWED
				if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				#else
				if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
				}*/
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
				
				if (FlxG.keys.pressed.SHIFT){
					LoadingState.loadAndSwitchState(new ChartingState());
				}else{
					LoadingState.loadAndSwitchState(new PlayState());
				}

				FlxG.sound.music.volume = 0;
						
				destroyFreeplayVocals();
				options.SongPlayer.PlayerSubstate.destroyFreeplayVocals();
			} else {
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (songs.length > 0) {
			curDifficulty += change;

			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficulties.length-1;
			if (curDifficulty >= CoolUtil.difficulties.length)
				curDifficulty = 0;
	
			lastDifficultyName = CoolUtil.difficulties[curDifficulty];
	
			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
			#end
	
			PlayState.storyDifficulty = curDifficulty;
			diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		}
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = 0;
		if (songs.length > 0)
			newColor = songs[curSelected].color;
		else
			newColor = 0xFF4C0000;

		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		if (songs.length > 0) {
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		}
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		if (songs.length > 0)
			iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.autoAlpha = true;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (infScroll) {
				var lastT = item.targetY;
				var skipNum = 6;
				if (item.targetY < (-songs.length + skipNum)) { // On the bottom
					item.targetY = songs.length + lastT;
				} else if (item.targetY > songs.length - skipNum) { // On the top
					item.targetY = -songs.length + lastT;
				}
			}
		}

		var diffStr:String = '';
		if (songs.length > 0) {
			Paths.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
			diffStr = WeekData.getCurrentWeek().difficulties;
		}

		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreBG.setGraphicSize(Std.int(scoreText.width + 12), 64 + 24 + 12);
		scoreBG.updateHitbox();
		scoreBG.setPosition(FlxG.width - scoreBG.width, 0);
		scoreText.x = scoreBG.x + 6;

		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
		diffText.y = 68;
	}

	override function beatHit() {
		if (curBeat % 4 == 0) {
			if (FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015;
			}
			if (bopIcon > -1) {
				iconArray[bopIcon].scale.x += 0.15;
				iconArray[bopIcon].scale.y += 0.15;
			}
		}

		super.beatHit();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var cover:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, ?cover:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
		if(cover != null) this.cover = cover;
	}
}