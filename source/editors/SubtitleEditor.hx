package editors;

import misc.Subtitle.SubtitleHandler;
import misc.Subtitle.SubProperties;
import flixel.addons.ui.FlxUIDropDownMenu;
import song.Song;
import flixel.FlxCamera;
#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import song.Section.SwagSection;
import song.Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import flixel.util.FlxSort;
#if sys
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
#end
import editors.charter.ChartingState.AttachedFlxText;

using StringTools;

class SubtitleEditor extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	public static var curSec:Int = 0;
	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var curSong:String = 'Test';
	var amountSteps:Int = 0;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;
	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;
	var curRenderedSubs:FlxTypedGroup<StoredSubData>;
    var curRenderedTexts:FlxTypedGroup<FlxText>;

	var gridBG:FlxSprite;
	var nextGridBG:FlxSprite;
	var prevGridBG:FlxSprite;

	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED SUBTITLE
	**/
	var curSelected:SubProperties = null;

	var tempBpm:Float = 0;

	var vocals:FlxSound = null;

	var subTextInput:FlxUIInputText;

	var zoomTxt:FlxText;
	var zoomList:Array<Float> = [
		0.25,
		0.5,
		1,
		2,
		3,
		4,
		6,
		8,
		12,
		16,
		24
	];
	var curZoom:Int = 2;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenu> = [];

    var currentSongName:String = "";
	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	var stupidCam:FlxCamera;

	public var quantizations:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];

	var text:String = "";
	override function create()
	{
		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150.0,
				needsVoices: true,
				arrowSkin: '',
				splashSkin: 'noteSplashes',//idk it would crash if i didn't
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				stage: 'stage',
				validScore: false,
				subtitles: []
			};

			addSection();
			PlayState.SONG = _song;
		}

		// Paths.clearMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.song, '-', ' '));
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF0A0A0A;
		add(bg);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		curRenderedSubs = new FlxTypedGroup<StoredSubData>();
        curRenderedTexts = new FlxTypedGroup<FlxText>();

		if(curSec >= _song.notes.length) curSec = _song.notes.length - 1;

		FlxG.mouse.visible = true;
		//FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		currentSongName = Paths.formatToSongPath(_song.song);
		loadSong();
        reloadGridLayer();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 420 + 10).makeGraphic(5, Std.int(GRID_SIZE * 6), FlxColor.RED);
		add(strumLine);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x, FlxG.height / 2);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Other", label: "Other"},
			{name: "Subtitle", label: "Subtitle"}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 200;
		UI_box.y = 20;
		UI_box.scrollFactor.set();

		add(UI_box);
		
		zoomTxt = new FlxText(UI_box.x + UI_box.width + 10, UI_box.y + 10, 0, "Zoom: 1 / 1\nSection: 0\nBeat: \nStep: ", 16);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);

		text =
		"W/S - Change time
		\nA/D - Switch sections
		\nHold Shift to move 4x faster
		\nHold Control and click on a subtitle to select it
		\nZ/X - Zoom in/out
		\nHold Shift+Drag up/down subtitle to move the selected subtitle
		\n
		\nQ/E - Decrease/Increase subtitle length
		\nClick - Delete or add subtitle
		\nSpace - Stop/Resume song";

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length) {
			var tipText:FlxText = new FlxText(UI_box.x + UI_box.width + 10, UI_box.y + zoomTxt.height + 10, 0, tipTextArray[i], 16);
			tipText.y += i * 12;
			tipText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
			//tipText.borderSize = 2;
			tipText.scrollFactor.set();
			add(tipText);
		}

		addSubtitleUI();
		addOtherUI();
		//UI_box.selected_tab = 4;

		add(curRenderedSubs);
        add(curRenderedTexts);

		if(lastSong != currentSongName) {
			changeSection();
		}
		lastSong = currentSongName;

		updateZoom();
		updateGrid();

		stupidCam = new FlxCamera();
		stupidCam.bgColor.alpha = 0;
		FlxG.cameras.add(stupidCam, false);
		SubtitleHandler.camera = stupidCam;

		super.create();
	}

	var UI_songTitle:FlxUIInputText;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; //I wanted to use a stepper but we can't scale these as far as i know :(

	var stepperSubSize:FlxUINumericStepper;
	var fontInputText:FlxUIInputText;
	var borderCheckbox:FlxUICheckBox;
	var alignmentDrop:FlxUIDropDownMenu;

	var deletePrevCheckbox:FlxUICheckBox;
	var fadeOut:FlxUICheckBox;
	var fadeIn:FlxUICheckBox;
	var typeIn:FlxUICheckBox;
	var typeOut:FlxUICheckBox;
	var raisesLast:FlxUICheckBox;

	function addSubtitleUI():Void
	{
        FlxG.camera.follow(camPos);
                
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Subtitle';

        UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Voices", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			//trace('CHECKED!');
		};

		var saveButton:FlxUIButton = new FlxUIButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxUIButton = new FlxUIButton(saveButton.x + 90, saveButton.y, "Reload Audio", function()
		{
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			loadSong();
        });

		var reloadSongJson:FlxUIButton = new FlxUIButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', function(){loadJson(_song.song.toLowerCase()); }, null,false));
		});

		var loadEventJson:FlxUIButton = new FlxUIButton(saveButton.x, saveButton.y + 30, 'Load', function()
		{
			var songName:String = Paths.formatToSongPath(_song.song);
			var file:String = Paths.json(songName + '/subtitles');
			#if sys
			if (#if MODS_ALLOWED FileSystem.exists(Paths.modsJson(songName + '/subtitles')) || #end FileSystem.exists(file))
			#else
			if (OpenFlAssets.exists(file))
			#end
			{
				clearEvents();
				var events:SwagSong = Song.loadFromJson('subtitles', songName);
				_song.events = events.events;
				changeSection(curSec);
			}
		});

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 1, 1, 1, 400, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);
        tab_group_event.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, "BPM"));

        var clear_events:FlxUIButton = new FlxUIButton(320, 310, 'Clear events', clearEvents);
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

        //////// SONG
        //////////////////////////////////////////////////////////
        /////// SUBITLE

		var assSeparatorLine:FlxSprite = new FlxSprite(10, loadEventJson.y + 35).makeGraphic(Std.int(UI_box.width - 20), 5);
		assSeparatorLine.alpha = 0.6;
        tab_group_event.add(assSeparatorLine);

        stepperSusLength = new FlxUINumericStepper(10, loadEventJson.y + 60, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 64);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'stepperSubLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);
        tab_group_event.add(new FlxText(stepperSusLength.x, stepperSusLength.y - 15, 0, "Length"));

		strumTimeInputText = new FlxUIInputText(stepperSusLength.x + stepperSusLength.width + 10, stepperSusLength.y, 180, "0");
		blockPressWhileTypingOn.push(strumTimeInputText);
        strumTimeInputText.x = (UI_box.width - 10) - strumTimeInputText.width;
        tab_group_event.add(new FlxText(strumTimeInputText.x, strumTimeInputText.y - 15, 0, "Time (in ms)"));

		subTextInput = new FlxUIInputText(10, strumTimeInputText.y + 30, Std.int(UI_box.width - 20), "");
		blockPressWhileTypingOn.push(subTextInput);
        var text:FlxText = new FlxText(10, subTextInput.y - 15, 0, "Text:");
		tab_group_event.add(text);

		stepperSubSize = new FlxUINumericStepper(10, subTextInput.y + 30, 1, 24, 1, 108, 3);
		stepperSubSize.name = 'stepperSubSize';
		blockPressWhileTypingOnStepper.push(stepperBPM);
        tab_group_event.add(new FlxText(stepperSubSize.x, stepperSubSize.y - 15, 0, "Size:"));

		fontInputText = new FlxUIInputText(stepperSubSize.x + stepperSubSize.width + 10, stepperSubSize.y, 180, "vcr.ttf");
		blockPressWhileTypingOn.push(fontInputText);
        fontInputText.x = (UI_box.width - 10) - fontInputText.width;
        tab_group_event.add(new FlxText(fontInputText.x, fontInputText.y - 15, 0, "Font:"));

		borderCheckbox = new FlxUICheckBox(stepperSubSize.x, fontInputText.y + 30, null, null, "Has border", 100);

		var alignments:Array<String> = ["LEFT", "RIGHT", "CENTER"];
		alignmentDrop = new FlxUIDropDownMenu(fontInputText.x, borderCheckbox.y, FlxUIDropDownMenu.makeStrIdLabelArray(alignments, true), function(alignment:String)
		{
			trace('alignment is ' + alignments[Std.parseInt(alignment)]);
			if(curSelected != null) {
				updateCurShit();
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(alignmentDrop);
		tab_group_event.add(new FlxText(alignmentDrop.x, alignmentDrop.y - 15, 0, "Alignment:"));

		deletePrevCheckbox = new FlxUICheckBox(stepperSubSize.x, borderCheckbox.y + 30, null, null, "Delete previous", 90);
		fadeOut = new FlxUICheckBox(deletePrevCheckbox.x + deletePrevCheckbox.width + 5, deletePrevCheckbox.y, null, null, "Fade out", 90);
		fadeIn = new FlxUICheckBox(fadeOut.x + fadeOut.width + 5, deletePrevCheckbox.y, null, null, "Fade in", 90);
		typeIn = new FlxUICheckBox(deletePrevCheckbox.x, deletePrevCheckbox.y + 30, null, null, "Type in", 90);
		typeOut = new FlxUICheckBox(typeIn.x + typeIn.width + 5, typeIn.y, null, null, "Type out", 90);
		raisesLast = new FlxUICheckBox(typeOut.x + typeOut.width + 5, typeOut.y, null, null, "Raise last", 90);

        ///////////////////////////////////////////////////////
        /////////// SECTION
		
		var assSeparatorLine:FlxSprite = new FlxSprite(10, clear_events.y - 10).makeGraphic(Std.int(UI_box.width - 20), 5);
		assSeparatorLine.alpha = 0.6;
        tab_group_event.add(assSeparatorLine);

        var copyButton:FlxUIButton = new FlxUIButton(10, clear_events.y, "Copy Section", function()
        {
            notesCopied = [];
            sectionToCopy = curSec;

            var startThing:Float = sectionStartTime();
            var endThing:Float = sectionStartTime(1);
            for (event in _song.events)
            {
                var strumTime:Float = event[0];
                if(endThing > event[0] && event[0] >= startThing)
                {
                    var copiedEventArray:Array<Dynamic> = [];
                    for (i in 0...event[1].length)
                    {
                        var eventToPush:Array<Dynamic> = event[1][i];
                        copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
                    }
                    notesCopied.push([strumTime, -1, copiedEventArray]);
                }
            }
        });

        var pasteButton:FlxUIButton = new FlxUIButton(copyButton.x + 100, copyButton.y, "Paste Section", function()
        {
            if(notesCopied == null || notesCopied.length < 1)
            {
                return;
            }

            var addToTime:Float = Conductor.stepCrochet * (getSectionBeats() * 4 * (curSec - sectionToCopy));
            //trace('Time to add: ' + addToTime);

            for (note in notesCopied)
            {
                var newStrumTime:Float = note[0] + addToTime;
                if(note[1] < 0)
                {
                    var copiedEventArray:Array<Dynamic> = [];
                    for (i in 0...note[2].length)
                    {
                        var eventToPush:Array<Dynamic> = note[2][i];
                        copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
                    }
                    _song.events.push([newStrumTime, copiedEventArray]);
                }
            }
            updateGrid();
        });

        var clearSectionButton:FlxUIButton = new FlxUIButton(pasteButton.x + 100, pasteButton.y, "Clear Section", function()
        {
            var i:Int = _song.events.length - 1;
            var startThing:Float = sectionStartTime();
            var endThing:Float = sectionStartTime(1);
            while(i > -1) {
                var event:Array<Dynamic> = _song.events[i];
                if(event != null && endThing > event[0] && event[0] >= startThing)
                {
                    _song.events.remove(event);
                }
                --i;
            }
            updateGrid();
            updateNoteUI();
        });
        clearSectionButton.color = FlxColor.RED;
        clearSectionButton.label.color = FlxColor.WHITE;

        var stepperCopy:FlxUINumericStepper = null;
        var copyLastButton:FlxUIButton = new FlxUIButton(10, copyButton.y + 30, "Copy last section", function()
        {
            var value:Int = Std.int(stepperCopy.value);
            if(value == 0) return;

            var daSec = FlxMath.maxInt(curSec, value);

            var startThing:Float = sectionStartTime(-value);
            var endThing:Float = sectionStartTime(-value + 1);
            for (event in _song.events)
            {
                var strumTime:Float = event[0];
                if(endThing > event[0] && event[0] >= startThing)
                {
                    strumTime += Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);
                    var copiedEventArray:Array<Dynamic> = [];
                    for (i in 0...event[1].length)
                    {
                        var eventToPush:Array<Dynamic> = event[1][i];
                        copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
                    }
                    _song.events.push([strumTime, copiedEventArray]);
                }
            }
            updateGrid();
        });
        copyLastButton.resize(120, Std.int(copyLastButton.height));
        copyLastButton.label.fieldWidth = 120;
        copyLastButton.updateHitbox();

        stepperCopy = new FlxUINumericStepper(copyLastButton.x + copyLastButton.width + 10, copyLastButton.y, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

        clear_events.x = clearSectionButton.x;
        clear_events.y = stepperCopy.y;

        tab_group_event.add(UI_songTitle);
        tab_group_event.add(check_voices);
        tab_group_event.add(saveButton);
        tab_group_event.add(reloadSong);
        tab_group_event.add(reloadSongJson);
        tab_group_event.add(loadEventJson);
        tab_group_event.add(stepperBPM);
        tab_group_event.add(clear_events);

        tab_group_event.add(stepperSusLength);
        tab_group_event.add(strumTimeInputText);
        tab_group_event.add(subTextInput);
		tab_group_event.add(stepperSubSize);
		tab_group_event.add(fontInputText);
		tab_group_event.add(borderCheckbox);

		tab_group_event.add(deletePrevCheckbox);
		tab_group_event.add(fadeOut);
		tab_group_event.add(fadeIn);
		tab_group_event.add(typeIn);
		tab_group_event.add(typeOut);
		tab_group_event.add(raisesLast);

		tab_group_event.add(alignmentDrop); // it would look weird ngl

        tab_group_event.add(copyButton);
        tab_group_event.add(pasteButton);
        tab_group_event.add(clearSectionButton);
        tab_group_event.add(stepperCopy);
        tab_group_event.add(copyLastButton);

		UI_box.addGroup(tab_group_event);
	}

	var stepperRColor:FlxUINumericStepper;
	var stepperGColor:FlxUINumericStepper;
	var stepperBColor:FlxUINumericStepper;
	var italicCheckbox:FlxUICheckBox;
	var boldCheckbox:FlxUICheckBox;
	var colorVisualizer:FlxSprite;
	function addOtherUI()
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Other';

		stepperRColor = new FlxUINumericStepper(10, 40, 20, 255, 0, 255, 0);
		stepperGColor = new FlxUINumericStepper(80, 40, 20, 255, 0, 255, 0);
		stepperBColor = new FlxUINumericStepper(150, 40, 20, 255, 0, 255, 0);

		stepperRColor.name = 'colorStepper';
		stepperGColor.name = 'colorStepper';
		stepperBColor.name = 'colorStepper';

		colorVisualizer = new FlxSprite(stepperBColor.x + stepperBColor.width + 10, stepperBColor.y);
		colorVisualizer.makeGraphic(Std.int(stepperBColor.height), Std.int(stepperBColor.height), FlxColor.fromRGB(Math.floor(stepperRColor.value), Math.floor(stepperGColor.value), Math.floor(stepperBColor.value)));

		blockPressWhileTypingOnStepper.push(stepperRColor);
		blockPressWhileTypingOnStepper.push(stepperGColor);
		blockPressWhileTypingOnStepper.push(stepperBColor);

		tab_group_event.add(new FlxText(stepperRColor.x, stepperRColor.y - 15, "<c> Tag's colors:"));

		var descTxt:FlxText = new FlxText(stepperRColor.x, stepperRColor.y + 40, "How to add a <c> tag:
		If your text is 'YOU MUST DIE NOW!' and you want
		to add a red color to 'DIE NOW!'
		Write 'YOU MUST <c>DIE NOW!<c>' and
		change the steppers to the color you want.
		You can also use <r> for red,
		<g> for green and <b> for blue.
		It would look like this:");
		tab_group_event.add(descTxt);

		var red:FlxTextFormat = new FlxTextFormat(FlxColor.RED);
		var green:FlxTextFormat = new FlxTextFormat(FlxColor.GREEN);
		var blue:FlxTextFormat = new FlxTextFormat(FlxColor.BLUE);

		var daTxtY:Float = descTxt.y + descTxt.height + 15;
		var example1:FlxText = new FlxText(stepperRColor.x, daTxtY, "YOU MUST <r>DIE NOW!<r>").applyMarkup("YOU MUST <r>DIE NOW!<r>", [new FlxTextFormatMarkerPair(red, "<r>")]);
		var example2:FlxText = new FlxText(150, daTxtY, "<r> tag");
		tab_group_event.add(example1);
		tab_group_event.add(example2);

		daTxtY += 10;
		var example1:FlxText = new FlxText(stepperRColor.x, daTxtY, "YOU MUST <g>DIE NOW!<g>").applyMarkup("YOU MUST <g>DIE NOW!<g>", [new FlxTextFormatMarkerPair(green, "<g>")]);
		var example2:FlxText = new FlxText(150, daTxtY, "<g> tag");
		tab_group_event.add(example1);
		tab_group_event.add(example2);

		daTxtY += 10;
		var example1:FlxText = new FlxText(stepperRColor.x, daTxtY, "YOU MUST <b>DIE NOW!<b>").applyMarkup("YOU MUST <b>DIE NOW!<b>", [new FlxTextFormatMarkerPair(blue, "<b>")]);
		var example2:FlxText = new FlxText(150, daTxtY, "<b> tag");
		tab_group_event.add(example1);
		tab_group_event.add(example2);

		italicCheckbox = new FlxUICheckBox(10, daTxtY + 40, null, null, "Italic", 100);
		boldCheckbox = new FlxUICheckBox(110, italicCheckbox.y, null, null, "Bold", 100);

		tab_group_event.add(stepperRColor);
		tab_group_event.add(stepperGColor);
		tab_group_event.add(stepperBColor);
		tab_group_event.add(colorVisualizer);
		tab_group_event.add(italicCheckbox);
		tab_group_event.add(boldCheckbox);
		UI_box.addGroup(tab_group_event);
	}

	function setAllLabelsOffset(button:FlxUIButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		var file:Dynamic = Paths.voices(currentSongName);
		vocals = new FlxSound();
		if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file)) {
			vocals.loadEmbedded(file);
			FlxG.sound.list.add(vocals);
		}
		generateSong();
		//FlxG.sound.music.pause();
		Conductor.songPosition = sectionStartTime();
		FlxG.sound.music.time = Conductor.songPosition;
	}

	function generateSong() {
		FlxG.sound.playMusic(Paths.inst(currentSongName), 0.6/*, false*/);

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if(vocals != null) {
				vocals.pause();
				vocals.time = 0;
			}
			changeSection();
			curSec = 0;
			updateGrid();
			vocals.play();
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			if (wname == 'stepperSubLength')
			{
				if(curSelected != null) {
					updateCurShit();
					updateGrid();
				} else {
					sender.value = 0;
				}
			}
			else if (wname == 'stepperSubSize')
			{
				if(curSelected != null) {
					updateCurShit();
					updateGrid();
				} else {
					sender.value = 12;
				}
			}
			else if (wname == 'colorStepper')
			{
				if(curSelected != null) {
					updateCurShit();
					updateColorSpr();
					updateGrid();
				}
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			//sender.text = sender.text.replace('=', '').replace('|', '');
			if(sender == strumTimeInputText) {
				var value:Float = Std.parseFloat(strumTimeInputText.text);
				if(Math.isNaN(value)) value = 0;
				curSelected.time = value;
				updateGrid();
			} else if (sender == subTextInput) {
				updateCurShit();
				updateGrid();
			} else if (sender == fontInputText) {
				updateCurShit();
				updateGrid();
			}
		}
		else if(id == FlxUICheckBox.CLICK_EVENT && (sender is FlxUICheckBox)) {
			updateCurShit();
			updateGrid();
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	function getWeed():Float {
		var value:Float = Std.parseFloat(strumTimeInputText.text);
		if(Math.isNaN(value)) value = 0;
		return value;
	}

	function getWeed2():Array<Int> {
		var weed = [stepperRColor.value, stepperGColor.value, stepperBColor.value];
		var weed2:Array<Int> = [];
		for (c in weed) weed2.push(Math.floor(c));
		return weed2;
	}

	function updateCurShit() {
		if (curSelected != null) {
			curSelected.subText = subTextInput.text;
			curSelected.fadeOut = fadeOut.checked;
			curSelected.fadeIn = fadeIn.checked;
			curSelected.deletePrevious = deletePrevCheckbox.checked;
			curSelected.typeIn = typeIn.checked;
			curSelected.typeOut = typeOut.checked;
			curSelected.bold = boldCheckbox.checked;
			curSelected.italic = italicCheckbox.checked;
			curSelected.length = Std.string(stepperSusLength.value);
			curSelected.size = Math.floor(stepperSubSize.value);
			curSelected.font = fontInputText.text;
			curSelected.border = borderCheckbox.checked;
			curSelected.alignment = alignmentDrop.selectedLabel;
			curSelected.colorArray = getWeed2();
			curSelected.time = getWeed();
		} else {
			trace('da curselected null');
		}
	}

	function updateColorSpr() {
		colorVisualizer.color = FlxColor.fromRGB(Math.floor(stepperRColor.value), Math.floor(stepperGColor.value), Math.floor(stepperBColor.value));
	}

	var updatedSection:Bool = false;

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSec + add)
		{
			if(_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLineUpdateX();
        camPos.setPosition(strumLine.x, FlxG.height / 2);

		FlxG.mouse.visible = true;//cause reasons. trust me
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom]
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + gridBG.height)
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.x = FlxG.mouse.x;
			else
			{
				var gridmult = GRID_SIZE;
				dummyArrow.y = -10 + Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
			}
		} else {
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.overlaps(curRenderedSubs))
		{
			curRenderedSubs.forEachAlive(function(spr:StoredSubData)
			{
				if (FlxG.mouse.overlaps(spr))
				{
					if (FlxG.mouse.pressed && FlxG.keys.pressed.SHIFT) { //drag subtitle code
						if (FlxG.mouse.y > gridBG.y &&
							FlxG.mouse.y < gridBG.y + gridBG.height) {
								if (curSelected != null) {
									curSelected.yInEditor = FlxG.mouse.y - (GRID_SIZE / 2);
								}
								updateGrid();
							}
					} else if (FlxG.mouse.justPressed) {
						if (FlxG.keys.pressed.CONTROL) {
							selectNote(spr);
							trace('selected note');
						}
						else deleteNote(spr);
					}
				}
			});
		}
		else
		{
			if (FlxG.mouse.x > gridBG.x
				&& FlxG.mouse.x < gridBG.x + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom]
				&& FlxG.mouse.y > gridBG.y
				&& FlxG.mouse.y < gridBG.y + gridBG.height
				&& FlxG.mouse.justPressed)
			{
				FlxG.log.add('added note');
				addNote();
			}
		}

        var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if(!blockInput) {
			for (stepper in blockPressWhileTypingOnStepper) {
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if(leText.hasFocus) {
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

        if (Math.ceil(strumLine.x) >= gridBG.width)
        {
            if (_song.notes[curSec + 1] == null)
            {
                addSection();
            }

            changeSection(curSec + 1, false);
        } else if(strumLine.x < -10) {
            changeSection(curSec - 1, false);
        }

		zoomTxt.text = zoom + '\nSection: $curSec\nBeat: $curBeat\nStep: $curStep';

        if (!blockInput) {
            var shiftThing:Int = FlxG.keys.pressed.SHIFT ? 4 : 1;
            if (FlxG.keys.justPressed.D)
                changeSection(curSec + shiftThing);
            if (FlxG.keys.justPressed.A) {
                if(curSec <= 0) {
                    changeSection(_song.notes.length-1);
                } else {
                    changeSection(curSec - shiftThing);
                }
            }

            if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
            {
                FlxG.sound.music.pause();

                var holdingShift:Float = 1;
                if (FlxG.keys.pressed.CONTROL) holdingShift = 0.25;
                else if (FlxG.keys.pressed.SHIFT) holdingShift = 4;

                var daTime:Float = 700 * FlxG.elapsed * holdingShift;

                if (FlxG.keys.pressed.W)
                {
                    FlxG.sound.music.time -= daTime;
                }
                else
                    FlxG.sound.music.time += daTime;

                if(vocals != null) {
                    vocals.pause();
                    vocals.time = FlxG.sound.music.time;
                }
            }

            if (FlxG.keys.justPressed.SPACE)
            {
                if (FlxG.sound.music.playing)
                {
                    FlxG.sound.music.pause();
                    if(vocals != null) vocals.pause();
					SubtitleHandler.destroy(false);
                }
                else
                {
                    if(vocals != null) {
                        vocals.play();
                        vocals.pause();
                        vocals.time = FlxG.sound.music.time;
                        vocals.play();
                    }
                    FlxG.sound.music.play();
                }
            }

            if (FlxG.keys.justPressed.R)
            {
                if (FlxG.keys.pressed.SHIFT)
                    resetSection(true);
                else
                    resetSection();
            }

			if(FlxG.keys.justPressed.Z && curZoom > 0 && !FlxG.keys.pressed.CONTROL) {
				--curZoom;
				updateZoom();
			}
			if(FlxG.keys.justPressed.X && curZoom < zoomList.length-1) {
				curZoom++;
				updateZoom();
			}
	
			if(curSelected != null) {
				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}

			if (FlxG.keys.justPressed.ESCAPE) {
				//if(onMasterEditor) {
					MusicBeatState.switchState(new editors.MasterEditorMenu());
					SubtitleHandler.destroy(); //actually destroy
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				//}
				//FlxG.mouse.visible = false;
				return;
			}
        } else if (FlxG.keys.justPressed.ENTER) {
			for (i in 0...blockPressWhileTypingOn.length) {
				if(blockPressWhileTypingOn[i].hasFocus) {
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		curRenderedSubs.forEachAlive(function(spr:StoredSubData) {
			spr.alpha = 1;
			if(curSelected != null) {
				if (curSelected.time == spr.properties.time)
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					spr.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if(spr.properties.time <= Conductor.songPosition) {
				spr.alpha = 0.4;
				if(spr.properties.time > lastConductorPos && FlxG.sound.music.playing) {
					SubtitleHandler.makeline(spr.properties);
				}
			}
		});
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);
	}

	var zoom:String = "";
	function updateZoom() {
		var daZoom:Float = zoomList[curZoom];
		var zoomThing:String = '1 / ' + daZoom;
		if(daZoom < 1) zoomThing = Math.round(1 / daZoom) + ' / 1';
		zoom = 'Zoom: ' + zoomThing;
		reloadGridLayer();
	}

	var lastSecBeats:Float = 0;
	var lastSecBeatsNext:Float = 0;
	function reloadGridLayer() {
		gridLayer.clear();
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  Std.int(GRID_SIZE * getSectionBeats() * 4 * zoomList[curZoom]), Std.int(GRID_SIZE * 6));
        gridBG.x = 0;
        gridBG.y = 420 + 10;

		var leWidth:Int = Std.int(gridBG.width);
		var foundNextSec:Bool = false;
		var foundPrevSec:Bool = false;
		if(sectionStartTime(1) <= FlxG.sound.music.length)
		{
			nextGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  Std.int(GRID_SIZE * getSectionBeats(curSec + 1) * 4 * zoomList[curZoom]), Std.int(GRID_SIZE * 6));
			leWidth = Std.int(gridBG.width + nextGridBG.width);
			foundNextSec = true;
		}
		else nextGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        nextGridBG.y = gridBG.y;
		nextGridBG.x = gridBG.width;

		if(curSec >= 1)
		{
			prevGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  Std.int(GRID_SIZE * getSectionBeats(curSec - 1) * 4 * zoomList[curZoom]), Std.int(GRID_SIZE * 6));
			prevGridBG.x = -gridBG.width;
			foundPrevSec = true;
		}
		else prevGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        prevGridBG.y = gridBG.y;
		
		gridLayer.add(nextGridBG);
		gridLayer.add(gridBG);
		gridLayer.add(prevGridBG);

		if(foundNextSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(gridBG.width, gridBG.y).makeGraphic(Std.int(nextGridBG.width), Std.int(GRID_SIZE * 6), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridLayer.add(gridBlack);
		}

		if(foundPrevSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(-gridBG.width, gridBG.y).makeGraphic(Std.int(prevGridBG.width), Std.int(GRID_SIZE * 6), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridLayer.add(gridBlack);
		}

		lastSecBeats = getSectionBeats();
		if(sectionStartTime(1) > FlxG.sound.music.length) lastSecBeatsNext = 0;
		else getSectionBeats(curSec + 1);
	}

	function strumLineUpdateX()
	{
		strumLine.x = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (getSectionBeats() / 4);
	}


	function changeNoteSustain(value:Float):Void
	{
		if (curSelected != null)
		{
			if (curSelected != null)
			{
				var curVal:Float = Std.parseFloat(curSelected.length);
				curVal += value;
				curVal = Math.max(curVal, 0);
				curSelected.length = ''+ curVal;
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSec = 0;
		}

		if(vocals != null) {
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
		}
		updateCurStep();

		updateGrid();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSec = sec;
			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
				updateCurStep();
			}

			var blah1:Float = getSectionBeats();
			var blah2:Float = getSectionBeats(curSec + 1);
			if(sectionStartTime(1) > FlxG.sound.music.length) blah2 = 0;
	
			if(blah1 != lastSecBeats || blah2 != lastSecBeatsNext)
			{
				reloadGridLayer();
			}
			else
			{
				updateGrid();
			}
			updateGrid();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
	}

	function loadHealthIconFromCharacter(char:String) {
		var characterPath:String = 'characters/' + char + '.json';
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path)) {
			path = Paths.getPreloadPath(characterPath);
		}

		if (!FileSystem.exists(path))
		#else
		var path:String = Paths.getPreloadPath(characterPath);
		if (!OpenFlAssets.exists(path))
		#end
		{
			path = Paths.getPreloadPath('characters/' + Character.DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
		}

		#if MODS_ALLOWED
		var rawJson = File.getContent(path);
		#else
		var rawJson = OpenFlAssets.getText(path);
		#end

		var json:Character.CharacterFile = cast Json.parse(rawJson);
		return json.healthicon;
	}

	function updateNoteUI():Void
	{
		if (curSelected != null) {
			if(curSelected != null) {
				stepperSusLength.value = Std.parseFloat(curSelected.length);
			}
			strumTimeInputText.text = '' + curSelected.time;
		}
	}

	function updateGrid():Void
	{
		curRenderedSubs.clear();
        curRenderedTexts.clear();

		if (_song.notes[curSec].changeBPM && _song.notes[curSec].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSec].bpm);
			//trace('BPM of this section:');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSec)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		// CURRENT EVENTS
		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		for (i in _song.subtitles)
		{
            var strumTime:Float = i.time;
			if(endThing > strumTime && strumTime >= startThing)
			{
				var storeY:Float = i.yInEditor;

                var width:Int = Math.floor(FlxMath.remapToRange(Std.parseFloat(i.length), 0, 
                    Conductor.stepCrochet * 16, 0, GRID_SIZE * 16 * zoomList[curZoom]) + (GRID_SIZE * zoomList[curZoom]) - GRID_SIZE / 2);

                //var editorLane:String = eventValue1[2];
                //if (editorLane == null || editorLane.length < 1) editorLane = "0";

				var spr:StoredSubData = new StoredSubData(getYfromStrumNotes(strumTime - sectionStartTime(), 1), storeY);
				//trace(spr.x + ' ' + spr.y, 'expectedX: ' + getYfromStrumNotes(strumTime - sectionStartTime(), 1));
                spr.makeGraphic(width, GRID_SIZE, FlxColor.BLACK);
                spr.time = strumTime;
                spr.length = Std.parseFloat(i.length);
				spr.properties = i;
				

				curRenderedSubs.add(spr);

				var text:String = i.subText;
				var daText:FlxText = new FlxText(0, 0, width, text, 12);
				daText.setFormat(Paths.font(i.font), i.size, FlxColor.WHITE);

				if (i.border) daText.setFormat(Paths.font(i.font), i.size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);

				switch(i.alignment) {
					case "LEFT": daText.alignment = LEFT;
					case "RIGHT": daText.alignment = RIGHT;
					case "CENTER": daText.alignment = CENTER;
				}
				
                daText.x = (spr.x + (spr.width / 2)) - (daText.width / 2);
                daText.y = spr.y + (spr.height / 2) - (daText.height / 2);
				curRenderedTexts.add(daText);
			}
			//trace('test: ' + i[0], 'startThing: ' + startThing, 'endThing: ' + endThing, 'event: ' + name);
		}
	}

	function getEventName(names:Array<Dynamic>):String
	{
		var retStr:String = '';
		var addedOne:Bool = false;
		for (i in 0...names.length)
		{
			if(addedOne) retStr += ', ';
			retStr += names[i][0];
			addedOne = true;
		}
		return retStr;
	}

	private function addSection(sectionBeats:Float = 4):Void
	{
		var sec:SwagSection = {
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			gfSection: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(spr:StoredSubData):Void
	{
        for (i in _song.subtitles)
        {
            if(i != curSelected && i.time == spr.properties.time)
            {
                curSelected = i;

                break;
            }
        }

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(spr:StoredSubData):Void
	{
        for (i in _song.subtitles)
        {
            if(i.time == spr.properties.time)
            {
                if(i == curSelected)
                {
                    curSelected = null;
                    //changeEventSelected();
                }
                //FlxG.log.add('FOUND EVIL EVENT');
                _song.subtitles.remove(i);
                break;
            }
        }

		updateGrid();
	}

	/*public function doANoteThing(cs, d, style){
		var delnote = false;
		if(strumLineNotes.members[d].overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEachAlive(function(note:Note)
			{
				if (note.overlapsPoint(new FlxPoint(strumLineNotes.members[d].x + 1,strumLine.y+1)) && note.noteData == d%4)
				{
						//trace('tryin to delete note...');
						if(!delnote) deleteNote(note);
						delnote = true;
				}
			});
		}

		if (!delnote){
			addNote(cs, d, style);
		}
	}*/
	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(strum:Null<Float> = null, data:Null<Int> = null, type:Null<Int> = null):Void
	{
		trace('added');
		var noteStrum = getStrumTime(dummyArrow.x, true) + sectionStartTime();

		var newSub:SubProperties = {
			subText: subTextInput.text,
			fadeOut: fadeOut.checked,
			fadeIn: fadeIn.checked,
			deletePrevious: deletePrevCheckbox.checked,
			typeIn: typeIn.checked,
			typeOut: typeOut.checked,
			bold: boldCheckbox.checked,
			italic: italicCheckbox.checked,
			length: Std.string(stepperSusLength.value),
			size: Math.floor(stepperSubSize.value),
			font: fontInputText.text,
			border: borderCheckbox.checked,
			alignment: alignmentDrop.selectedLabel,
			colorArray: getWeed2(),
			time: noteStrum,

			yInEditor: 430
		}

		_song.subtitles.push(newSub);
		curSelected = _song.subtitles[_song.subtitles.length - 1];

		//trace(noteData + ', ' + noteStrum + ', ' + curSec);
		strumTimeInputText.text = '' + curSelected.time;

		updateGrid();
	}

	// will figure this out l8r
	function redo()
	{
		//_song = redos[curRedoIndex];
	}

	function getStrumTime(xPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(xPos, gridBG.x, gridBG.x + gridBG.width * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.x, gridBG.x + gridBG.width * leZoom);
	}
	
	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * zoomList[curZoom] * value + gridBG.x;
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		//shitty null fix, i fucking hate it when this happens
		//make it look sexier if possible
		if (CoolUtil.difficulties[PlayState.storyDifficulty] != CoolUtil.defaultDifficulty) {
			if(CoolUtil.difficulties[PlayState.storyDifficulty] == null){
				PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			}else{
				PlayState.SONG = Song.loadFromJson(song.toLowerCase() + "-" + CoolUtil.difficulties[PlayState.storyDifficulty], song.toLowerCase());
			}
		}else{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		}
		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents() {
		_song.events = [];
		updateGrid();
	}

	private function saveLevel()
	{
		if(_song.subtitles != null && _song.subtitles.length > 1) _song.subtitles.sort(sortByTime);
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "subtitles.json");
		}
	}

	function sortByTime(Obj1:SubProperties, Obj2:SubProperties):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null) section = curSec;
		var val:Null<Float> = null;
		
		if(_song.notes[section] != null) val = _song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}
}

class StoredSubData extends FlxSprite {
    public var time:Float = 0;
    public var length:Float = 0;
	public var properties:SubProperties;
    public function new(x,y) {
        super(x, y);
    }
}