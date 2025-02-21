package replays.ui;

import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import replays.Replay;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;
import alphabet.Alphabet;

using StringTools;

#if MODS_ALLOWED
class ReplayMenu extends MusicBeatState
{
    var loadedReplays:Array<String> = [];
    var loadedPaths:Array<String> = [];
    var grpOptions:FlxTypedGroup<Alphabet>;
    var curSelected:Int;

    var hostUsername:String;

    public static var returnFile:ReplayData;

    var deleteText:FlxText;
    var statusText:FlxText;
    var createdText:FlxText;
    var locateText:FlxText;
    var dateText:FlxText;

    var state:String = 'select';

    var updateTexts:Bool = true;

    override function create()
    {
        super.create();

        hostUsername = CoolUtil.getHostUsername();

        loadedReplays = [];
        loadedPaths = [];
        loadReplays();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        bg.scrollFactor.set();
        add(bg);

        grpOptions = new FlxTypedGroup<Alphabet>();
        add(grpOptions);

        loadedReplays.push('select from ' + hostUsername);
        loadedPaths.push('select from ' + hostUsername);
        
        for (i in 0...loadedReplays.length) {
            var repOption:Alphabet;
            repOption = new Alphabet(90, 320, loadedReplays[i], true);
			repOption.isMenuItem = true;
			repOption.targetY = i - curSelected;
            grpOptions.add(repOption);
            
            var maxWidth = 1100;
			if (repOption.width > maxWidth)
			{
				repOption.scaleX = (maxWidth / repOption.width);
			}
			repOption.snapToPosition();
        }

        deleteText = new FlxText(5, FlxG.height - 32, 0, '', 24);
		deleteText.scrollFactor.set();
		deleteText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(deleteText);

        statusText = new FlxText(5, 0, 0, '', 24);
		statusText.scrollFactor.set();
		statusText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(statusText);

        locateText = new FlxText(5, FlxG.height - 32, 0, '', 24);
		locateText.scrollFactor.set();
		locateText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(locateText);

        dateText = new FlxText(5, 64, 0, '', 24);
		dateText.scrollFactor.set();
		dateText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dateText);

        createdText = new FlxText(5, 32, 0, '', 24);
		createdText.scrollFactor.set();
		createdText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(createdText);

        #if windows
        deleteText.text = 'Press the DELETE key in your keyboard to delete the selected replay.';
        locateText.text = 'Press the L key in your keyboard to open Windows Explorer on the replays folder.';
        deleteText.y = FlxG.height - 64;
        #end

        state = 'select';

        changeSelection();

        updateTexts = true;
    }

    override function update(elapsed:Float) {
        if (controls.UI_UP_P && state == 'select') {
            changeSelection(-1);
        }
        if (controls.UI_DOWN_P && state == 'select') {
            changeSelection(1);
        }
        if (controls.ACCEPT) {
            if (state == 'select') {
                selectReplay();
            } else if (state == 'confirm') {
                deleteReplay();
            }
        }
        if (controls.BACK) {
            if (state == 'select') {
                MusicBeatState.switchState(new MainMenuState());
            } else if (state == 'confirm') {
                updateTexts = true;
                grpOptions.members[curSelected].text = loadedReplays[curSelected];
                state = 'select';
            }
        }
        if (FlxG.keys.justPressed.DELETE && state == 'select') {
            updateTexts = false;
            if (loadedPaths[curSelected] != 'select from ' + hostUsername) {
                grpOptions.members[curSelected].text = 'This action is irreversible (ACCEPT - BACK)';
                state = 'confirm';
            } else {
                trace('invalid entry');
            }
        }

        #if windows
        if (FlxG.keys.justPressed.L) {
            Sys.command('explorer ' + FileSystem.fullPath(Paths.replays()));
        }
        #elseif macos
        if (FlxG.keys.justPressed.L) {
            Sys.command('open ' + FileSystem.fullPath(Paths.replays()));
        }
        #end

        if (updateTexts) {
            if (loadedPaths[curSelected] != 'select from ' + hostUsername) {
                statusText.text = 'Size: ' + FlxStringUtil.formatBytes(FileSystem.stat(loadedPaths[curSelected]).size);
                createdText.text = 'Created at: ' + FileSystem.stat(loadedPaths[curSelected]).ctime;
                dateText.y = 64;
            } else {
                statusText.text = 'Select a replay';
                createdText.text = '';
                dateText.y = 32;
            }   
        }
    
        dateText.text = Date.now().toString();
        super.update(elapsed);
    }

    function changeSelection(a:Int = 0) {
        curSelected += a;

        if (curSelected > loadedReplays.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = loadedReplays.length - 1;
        var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

        FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    function selectReplay()
    {
        if (loadedReplays[curSelected] != 'select from ' + hostUsername) {
            var raw:String = File.getContent(Paths.replays() + loadedReplays[curSelected]);
            if (raw != null) {
                returnFile = cast Json.parse(raw);
                Replay.doReturn(returnFile);
                return;
            }
        } else {
            Replay.loadReplay();
        }
    }

    function loadReplays()
    {
        for (replay in FileSystem.readDirectory(Paths.replays())) {
            if (replay.endsWith('.json')) {
                loadedReplays.push(replay);

                var lePath:String = Paths.replays() + replay;
                loadedPaths.push(lePath);
            } else {
                trace(replay+ ' excluded');
            }
        }
    }


    function deleteReplay() {
        updateTexts = false;
        FileSystem.deleteFile(loadedPaths[curSelected]);

        trace('deleting replay at ' + loadedPaths[curSelected]);

        var dots:String = '';
        var daTimes:Int = 1;
        var dotTimer:FlxTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {   
            daTimes++;
            if (daTimes > 3) {
                daTimes = 1;
                dots = '';
            }

            for (i in 0...daTimes)
                dots += '.';

            grpOptions.members[curSelected].text = 'Deleting replay' + dots;

            tmr.reset();
        });

        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            dotTimer.cancel();
            dots = '';
            daTimes = 1;
            var dotTimer2:FlxTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                daTimes++;
                if (daTimes > 3) {
                    daTimes = 1;
                    dots = '';
                }
    
                for (i in 0...daTimes)
                    dots += '.';

                grpOptions.members[curSelected].text = 'Checking existance' + dots; 
                if (FileSystem.exists(loadedPaths[curSelected])) {
                    deleteReplay();
                } else {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    MusicBeatState.resetState();
                }
            });
        });
    }
}
#end