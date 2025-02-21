package options;

import song.Song;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxBar;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import alphabet.Alphabet;

using StringTools;

class SongPlayer extends MusicBeatState
{
	var songs:Array<FreeplayState.SongMetadata> = [];
    var custom:Array<FreeplayState.SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var bopIcon:Int = -1;
    var errorMessageTime:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
    private var instIsPlaying:Bool = false;
	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
    var text:FlxText;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		// IGNORE THIS!!!
		var titleJSON = haxe.Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));
		Conductor.changeBPM(titleJSON.bpm);
		
		persistentUpdate = true;
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
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

        //The songs from psych
        addSong("tea time", 0, "flicky", 0xFF9E29CF, true);
        addSong("psync", 0, "flicky", 0xFF9E29CF, true); // its called psync, as stated by the credits
        addSong("breakfast", 0, "kawaisprite", 0xFF378FC7, true);
        addSong("main menu", 0, "none", 0xFF378FC7, true);
        //addSong("main menuuuuuuuuuuuuuuu dumb", 0, "none", 0xFF378FC7); thiss was for testing the alphabet lenght

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
			grpSongs.add(songText);

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

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
        changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "WARNING: #cpp active compilation block must be active for sound pitch.", 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
        FlxG.sound.music.onComplete = null;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, custom:Bool = false)
	{
		songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter, color));
        if (!custom)
            this.custom.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	var holdTime:Float = 0;
    public static var queuedCamZooms:Int = 0;
    public static var holdingOnBar:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

        if (queuedCamZooms > 0 && ClientPrefs.camZooms && !holdingOnBar) {
            FlxG.camera.zoom += 0.015;
            queuedCamZooms--;
        }

		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
		for (icon in iconArray) {
			icon.scale.x = FlxMath.lerp(1, icon.scale.x, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
			icon.scale.y = FlxMath.lerp(1, icon.scale.y, CoolUtil.boundTo(1 - (elapsed * 3.125 * 1), 0, 1));
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

        #if cpp
        text.text = Language.g('song_player_bottom').replace('%d', CoolUtil.difficultyString(curDifficulty));
        #else
        text.text = Language.g('song_player_no_cpp').replace('%d', CoolUtil.difficultyString(curDifficulty));
        #end

		if (!instIsPlaying) {
            if(songs.length > 1)
            {
                if (upP)
                {
                    changeSelection(-shiftMult);
                    changeDiff();
                    holdTime = 0;
                }
                if (downP)
                {
                    changeSelection(shiftMult);
                    changeDiff();
                    holdTime = 0;
                }
    
                if(controls.UI_DOWN || controls.UI_UP)
                {
                    var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                    holdTime += elapsed;
                    var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
    
                    if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                    {
                        changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                        changeDiff();
                    }
                }
    
                if(FlxG.mouse.wheel != 0)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
                    changeDiff();
                    changeSelection(-shiftMult * FlxG.mouse.wheel, false);
                }
            }

            if (controls.UI_LEFT_P)
                changeDiff(-1);
            else if (controls.UI_RIGHT_P)
                changeDiff(1);
    
            if (controls.BACK)
            {
                persistentUpdate = false;
                if(colorTween != null) {
                    colorTween.cancel();
                }
                FlxG.sound.play(Paths.sound('cancelMenu'));

                MusicBeatState.switchState(new OptionsState());
            }
            else if(accepted)
            {
                var changedTheSong:Bool = false;
                if(instPlaying != curSelected)
                {
                    bopIcon = curSelected;
                    instPlaying = curSelected;
                    changedTheSong = true;
                    instIsPlaying = true;
                }
                openSubState(new PlayerSubstate(songs[curSelected], curDifficulty, changedTheSong));
            }
        }
		super.update(elapsed);
	}

    function changeDiff(change:Int = 0)
    {
        if (custom.length > 0) {
            curDifficulty += change;

            if (curDifficulty < 0)
                curDifficulty = CoolUtil.difficulties.length-1;
            if (curDifficulty >= CoolUtil.difficulties.length)
                curDifficulty = 0;

            lastDifficultyName = CoolUtil.difficulties[curDifficulty];
        }
    }

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
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

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.autoAlpha = true;
		}

        instIsPlaying = false;
		
		if (custom.length > 0) {
            Paths.currentModDirectory = songs[curSelected].folder;
            PlayState.storyWeek = songs[curSelected].week;

            CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
            var diffStr:String = WeekData.getCurrentWeek().difficulties;
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
	}

	override function beatHit() {
		if (curBeat % 4 == 0) {
			if (FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && !holdingOnBar)
			{
				FlxG.camera.zoom += 0.015;
			} else {
                queuedCamZooms ++;
            }
			if (bopIcon > -1) {
				iconArray[bopIcon].scale.x += 0.15;
				iconArray[bopIcon].scale.y += 0.15;
			}
		}

		super.beatHit();
	}
}

class PlayerSubstate extends MusicBeatSubstate {

    public static var vocals:FlxSound = null;
    var songSpeed:Float = 1;
    var playbackSpeed:Float = 1;
    var paused:Bool = false;
    var disc:FlxSprite;
    var background:FlxSprite;
    var icon:HealthIcon;
    var speedArrows:Array<FlxSprite> = [];
    var songSpeedMultiplier:Alphabet;
    var canPause:Bool = false;
    var startTimer:Float = 0;

    var timeTxt:FlxText;
    var timeBarBG:AttachedSprite;
    var timeBar:FlxBar;
    var songPercent:Float = 0;
    var songText:Alphabet;

    var pauseIcon:FlxSprite;

    public function new(song:FreeplayState.SongMetadata, diff:Int, alreadyPlayingMusic:Bool = false) {
        super();

        background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(background);
        background.alpha = 0;

        disc = new FlxSprite(143, 152).loadGraphic(Paths.image('songplayer/vinildisk'));
        add(disc);
        disc.alpha = 0;

        icon = new HealthIcon(song.songCharacter);
        icon.x = 275;
        icon.y = 281;
        add(icon);
        icon.alpha = 0;

        songText = new Alphabet(966, 220, CoolUtil.coolSongText(song.songName), true);
        var maxWidth = 580;
        if (songText.width > maxWidth)
        {
            songText.scaleX = maxWidth / songText.width;
        }
        songText.snapToPosition();

        songText.setAlignmentFromString("center");
        add(songText);
        songText.alpha = 0;

        var speedArrowL:FlxSprite = new FlxSprite(805, 500).loadGraphic(Paths.image('songplayer/speedchange_arrow'));
        var speedArrowR:FlxSprite = new FlxSprite(1100, 500).loadGraphic(Paths.image('songplayer/speedchange_arrow'));
        speedArrowR.flipX = true;
        speedArrowL.ID = 0;
        speedArrowR.ID = 1;
        speedArrows.push(speedArrowL);
        speedArrows.push(speedArrowR);
        for (arrow in speedArrows) {
            add(arrow);
            arrow.alpha = 0;
        }

        songSpeedMultiplier = new Alphabet(960, 498, playbackSpeed + "x", true);
        songSpeedMultiplier.setAlignmentFromString("center");
        add(songSpeedMultiplier);
        songSpeedMultiplier.alpha = 0;

        pauseIcon = new FlxSprite(960, 300).loadGraphic(Paths.image('songplayer/pause'));
        add(pauseIcon);
        pauseIcon.x -= pauseIcon.width / 2;
        pauseIcon.alpha = 0;

		timeTxt = new FlxText(960 - 200, 450, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
        timeTxt.alpha = 0;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y - 32;
		timeBarBG.scrollFactor.set();
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);
        timeBarBG.alpha = 0;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
        timeBar.alpha = 0;

        FlxTween.tween(background, {alpha: 0.5}, 0.5);
        FlxTween.tween(disc, {alpha: 1}, 0.5);
        FlxTween.tween(icon, {alpha: 1}, 0.5);
        FlxTween.tween(songText, {alpha: 1}, 0.5);
        FlxTween.tween(speedArrows[0], {alpha: 1}, 0.5);
        FlxTween.tween(speedArrows[1], {alpha: 1}, 0.5);
        FlxTween.tween(songSpeedMultiplier, {alpha: 1}, 0.5);
        FlxTween.tween(pauseIcon, {alpha: 1}, 0.5);
        FlxTween.tween(timeTxt, {alpha: 1}, 0.5);
        FlxTween.tween(timeBarBG, {alpha: 1}, 0.5);
        FlxTween.tween(timeBar, {alpha: 1}, 0.5);

        if (alreadyPlayingMusic) {
            destroyFreeplayVocals();
            FlxG.sound.music.volume = 0;
    
            var titleJSON = haxe.Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));
            Conductor.changeBPM(titleJSON.bpm);
    
            //trace(song.songName);
            switch (song.songName) {
                case "tea time" | "breakfast" | "psync" | "main menu":
                    var musicBpm:Float = 160; //Breakfast bpm
                    var songFile:String = song.songName;
                    switch (song.songName) {
                        case "tea time":
                            musicBpm = 105;
                        case "psync":
                            musicBpm = 128;
                            songFile = "offsetSong";
                        case "main menu":
                            musicBpm = titleJSON.bpm;
                            songFile = "freakyMenu";
                    }
        
                    vocals = new FlxSound();
        
                    FlxG.sound.list.add(vocals);
                    FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(songFile)), 0.7);
                    Conductor.changeBPM(musicBpm);
                default:
                    Paths.currentModDirectory = song.folder;
                    var poop:String = Highscore.formatSong(song.songName.toLowerCase(), diff);
                    PlayState.SONG = Song.loadFromJson(poop, song.songName.toLowerCase());
                    if (PlayState.SONG.needsVoices)
                        vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
                    else
                        vocals = new FlxSound();
    
                    FlxG.sound.list.add(vocals);
                    FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
                    Conductor.changeBPM(PlayState.SONG.bpm);
            }
            vocals.play();
            vocals.persist = true;
            FlxG.sound.music.looped = true;
            vocals.looped = true;
            vocals.volume = 0.7;
        }

        FlxG.sound.music.onComplete = initClose;
    }

    function setPitch(value:Float)
    {
        if (canPause) {
            if(vocals != null) vocals.pitch = value;
            FlxG.sound.music.pitch = value;
        }
    }

    var holdTime:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);

        //This is so that you dont start paused
        if (!canPause) startTimer += elapsed;
        if (startTimer > 0.5) canPause = true;

        //Raise/lower the speed
        if (!paused) 
            songSpeed = FlxMath.lerp(songSpeed, playbackSpeed, elapsed * 2);
        else
            songSpeed = FlxMath.lerp(songSpeed, 0, elapsed * 10);

        setPitch(songSpeed);
        
        //Check the values are correct
        if (songSpeed > playbackSpeed) songSpeed = playbackSpeed;
        if (songSpeed < 0) songSpeed = 0;
        
        if (songSpeed == 0) {
            FlxG.sound.music.pause();
            vocals.pause();
        } else if (songSpeed > 0 && !FlxG.sound.music.playing) {
            FlxG.sound.music.resume();
            vocals.resume();
        }

        for (arrow in speedArrows) {
            if (FlxG.mouse.overlaps(arrow) && FlxG.mouse.justPressed) {
                if (arrow.ID == 0) {
                    if (playbackSpeed > 0.25) playbackSpeed -= 0.25;
                } else if (arrow.ID == 1) {
                    if (playbackSpeed < 10) playbackSpeed += 0.25;
                }
                songSpeedMultiplier.text = playbackSpeed + 'x';
                songSpeedMultiplier.setAlignmentFromString("center");
            }
        }

        disc.angle += (180 * elapsed) * songSpeed;
        icon.angle += (180 * elapsed) * songSpeed;
        
        var left = FlxG.keys.pressed.LEFT;
        var right = FlxG.keys.pressed.RIGHT;
        var leftP = FlxG.keys.justPressed.LEFT;
        var rightP = FlxG.keys.justPressed.RIGHT;
        var back = controls.BACK;
        var shiftMult = 5;
        if (FlxG.keys.pressed.SHIFT) shiftMult = 10;

        if (back && canPause) {
            initClose(); 
            canPause = false; 
            FlxG.sound.music.pitch = 1;
            vocals.pitch = 1;
            songSpeed = 1; 
        }
        if ((FlxG.keys.justPressed.ENTER || (FlxG.mouse.overlaps(pauseIcon) && FlxG.mouse.justPressed)) && canPause) 
            pause();
        if (canPause && FlxG.mouse.overlaps(timeBar) && FlxG.mouse.pressed) {
            SongPlayer.holdingOnBar = true;
        } else if (FlxG.mouse.justReleased)
            SongPlayer.holdingOnBar = false;

        if (SongPlayer.holdingOnBar) {
            var setToTime:Float = ((FlxG.mouse.x - timeBar.x) / timeBar.width) * FlxG.sound.music.length; //thank you ralt
            if (FlxG.sound.music.time != setToTime)
                setTime(setToTime);
        }

        if(left || right)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
            {
                changeTime((checkNewHold - checkLastHold) * (left ? -shiftMult : shiftMult));
            }
        }

        if (leftP) {
            changeTime(-shiftMult);
            holdTime = 0;
        }
        if (rightP) {
            changeTime(shiftMult);
            holdTime = 0;
        }

        var curTime:Float = FlxG.sound.music.time;
        if(curTime < 0) curTime = 0;
        songPercent = (curTime / FlxG.sound.music.length);

        var songCalc:Float = curTime;
        var secondsTotal:Int = Math.floor(songCalc / 1000);
        var allSeconds:Int = Math.floor(FlxG.sound.music.length / 1000);
        if(secondsTotal < 0) secondsTotal = 0;
        if (allSeconds < 0) allSeconds = 0;

        timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false) + ' - ' + FlxStringUtil.formatTime(allSeconds, false); 
        if (playbackSpeed != 1) {
            timeTxt.text += ' (' + FlxStringUtil.formatTime((songCalc / 1000) * (1 / playbackSpeed), false) + ')';
        }
    }

    function changeTime(change:Float = 0) {
        if (!canPause) return;
        var newTime = FlxG.sound.music.time + (change * 1000);
        if (newTime < FlxG.sound.music.length && newTime > 0) {
            FlxG.sound.music.time = newTime;
        }
        else if (newTime > FlxG.sound.music.length) FlxG.sound.music.time = FlxG.sound.music.length;
        else if (newTime < 0) FlxG.sound.music.time = 0;
        disc.angle += change * 180;
        icon.angle += change * 180;

        vocals.time = FlxG.sound.music.time;
    }

    function setTime(time:Float = 0) {
        if (!canPause) return;
        var differenceInMs:Float = FlxG.sound.music.time - time;
        disc.angle += -((differenceInMs / 1000) * 180);
        icon.angle += -((differenceInMs / 1000) * 180);

        if (time < FlxG.sound.music.length && time > 0) {
            FlxG.sound.music.time = time;
        }
        else if (time > FlxG.sound.music.length) FlxG.sound.music.time = FlxG.sound.music.length;
        else if (time < 0) FlxG.sound.music.time = 0;

        vocals.time = FlxG.sound.music.time;
    }

    function pause() {
        paused = !paused;

        remove(pauseIcon);

        if (paused) pauseIcon = new FlxSprite(960, 300).loadGraphic(Paths.image('songplayer/play'));
        else pauseIcon = new FlxSprite(960, 300).loadGraphic(Paths.image('songplayer/pause'));

        add(pauseIcon);
        pauseIcon.x -= pauseIcon.width / 2;
    }

    function initClose() {
        FlxTween.tween(background, {alpha: 0}, 0.5, {onComplete: 
            function(_) {
                close();
            }});
        FlxTween.tween(disc, {alpha: 0}, 0.5);
        FlxTween.tween(icon, {alpha: 0}, 0.5);
        FlxTween.tween(songText, {alpha: 0}, 0.5);
        FlxTween.tween(speedArrows[0], {alpha: 0}, 0.5);
        FlxTween.tween(speedArrows[1], {alpha: 0}, 0.5);
        FlxTween.tween(songSpeedMultiplier, {alpha: 0}, 0.5);
        FlxTween.tween(pauseIcon, {alpha: 0}, 0.5);
        FlxTween.tween(timeTxt, {alpha: 0}, 0.5);
        FlxTween.tween(timeBarBG, {alpha: 0}, 0.5);
        FlxTween.tween(timeBar, {alpha: 0}, 0.5);
    }
    
	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}
}