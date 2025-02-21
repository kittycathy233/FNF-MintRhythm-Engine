package;

import flixel.util.FlxStringUtil;
import flixel.addons.transition.FlxTransitionableState;
import song.Song;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import background.PropertyFlxSprite.PropertySprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

class GitarooPause extends MusicBeatSubstate
{
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var menuItems:Array<String> = [];
	var difficultyChoices = [];

	var buttons:Array<PropertySprite> = [];
	var texts:Array<FlxText> = [];
	var curSelected:Int = 0;
	var distancePerball:Float = 330;
	var skipTimeText:FlxText;
	var skipTimeTrack:FlxText;

	var curTime:Float = Math.max(0, Conductor.songPosition);

	public function new()
	{
		super();

		if(CoolUtil.difficulties.length < 2)
			menuItemsOG.remove('Change Difficulty');

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		add(bf);
		bf.screenCenter(X);

		/*replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		add(cancelButton);*/

		changeThing();

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	function regenMenu() {
		for (i in 0...buttons.length) {
			var obj = buttons[0];
			obj.kill();
			buttons.remove(obj);
			obj.destroy();
		}

		for (i in 0...texts.length) {
			var obj = texts[0];
			obj.kill();
			texts.remove(obj);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var mid:Float = FlxG.width / 2;
			var ball:PropertySprite = new PropertySprite(mid + (distancePerball * i), FlxG.height * 0.7);
			ball.loadGraphic(Paths.image('pauseAlt/button-frames', 'shared'), true, 200, 200);
			ball.animation.add('idle', [0]);
			ball.animation.add('select', [1]);
			buttons.push(ball);
			ball.x -= 100;

			ball.properties.set('targetY', i);

			add(ball);

			var itemTranslationStr = 'pause_' + Language.convert(menuItems[i]);
			var text:String = Language.g(itemTranslationStr, menuItems[i]);
			var item = new FlxText(90, 320, 300, text.toUpperCase());
			item.setFormat(Paths.font('vcr.ttf'), 38, 0xFF3F50C2, 'center');

			item.x = ball.x + (ball.width / 2);
			item.x -= item.width / 2;

			item.y = ball.y + (ball.height / 2);
			item.y -= item.height / 2;

			texts.push(item);
			add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(item.x, item.y + item.height, item.width, '0:00');
				skipTimeText.setFormat(Paths.font('vcr.ttf'), 34, 0xFF3F50C2, 'center');
				add(skipTimeText);
				skipTimeTrack = item;
				skipTextStuff();
			}
		}
		curSelected = 0;
		changeThing();
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		for (i in 0...buttons.length)
		{
			var item = buttons[i];
			var targetY:Float = item.properties.get('targetY');
			var mid:Float = FlxG.width / 2;
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 11.6, 0, 1);
			
			item.x = FlxMath.lerp(item.x, (targetY * distancePerball) + (mid - 100), lerpVal);
			
			var text = texts[i];
			text.x = item.x + (item.width / 2);
			text.x -= text.width / 2;
		}

		if (skipTimeText != null && skipTimeTrack != null) {
			skipTimeText.color = skipTimeTrack.color;
			skipTimeText.x = skipTimeTrack.x;
		}

		if (controls.UI_LEFT_P)
			changeThing(-1);
		if (controls.UI_RIGHT_P)
			changeThing(1);

		var daSelected:String = menuItems[curSelected];

		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_UP || controls.UI_DOWN)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_UP ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					skipTextStuff();
				}
		}

		if (controls.ACCEPT && cantUnpause <= 0)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					skipTextStuff(true);
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
				case "Restart Song":
					restartSong();
					if (PlayState.replayMode) PlayState._replay = PlayState._ogReplay;
				case "Leave Charting Mode":
					restartSong();
					//close();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					//close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					if(PlayState.replayMode) {
						PlayState.replayMode = false;
						PlayState._replay = null;
					}
					close();
			}
		}

		super.update(elapsed);
	}

	function changeThing(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...buttons.length)
		{
			var item = buttons[i];
			item.properties.set('targetY', bullShit - curSelected);
			bullShit++;

			item.animation.play('idle');
			texts[i].color = 0xFF3F50C2;

			if (item.properties.get('targetY') == 0)
			{
				item.animation.play('select');
				texts[i].color = FlxColor.BLACK;
			}
		}

		/*replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}*/
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	public function skipTextStuff(donull:Bool = false) {
		if (!donull) {
			skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
		} else {
			if(skipTimeText != null)
			{
				skipTimeText.kill();
				remove(skipTimeText);
				skipTimeText.destroy();
			}
			skipTimeText = null;
			skipTimeTrack = null;
		}
	}
}
