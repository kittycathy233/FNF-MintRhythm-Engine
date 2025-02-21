// "dialogueBox.hx"

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

var box:FlxSprite;
var curCharacter:String = '';
var dialogueList:Array<String> = [];

var resetDialogue:String->Void;
var skipDialogue:Void->Void;
var setAlpha:Float->Void;
var updateDrop:Void->Void;
var setColor:Int->Void;

var finishThing:Void->Void = PlayState.startCountdown;
var nextDialogueThing:Void->Void = PlayState.startNextDialogue;
var skipDialogueThing:Void->Void = PlayState.skipDialogue;

var portraitLeft:FlxSprite;
var portraitRight:FlxSprite;
var handSelect:FlxSprite;
var bgFade:FlxSprite;
var face:FlxSprite;

var song:String;

function create() {
    PlayState.camHUD.alpha = 0;
    PlayState.inCutscene = true;

    song = PlayState.SONG.song.toLowerCase();
    var file:String = Paths.modsRealTxt(song + '/' + song + 'Dialogue'); //Checks for vanilla/Senpai dialogue
    if (OpenFlAssets.exists(file)) {
        dialogueList = CoolUtil.coolTextFile(file);
    }
    debugPrint(file);

    var swagDialogue:FlxTypeText;
    swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
    swagDialogue.font = 'Pixel Arial 11 Bold';
    swagDialogue.color = 0xFF3F2021;
    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
    swagDialogue.scrollFactor.set();
    swagDialogue.screenCenter(FlxAxes.X);

    var dropText:FlxText;
    dropText = new FlxText(swagDialogue.x + 2, swagDialogue.y + 2, Std.int(FlxG.width * 0.6), "", 32);
    dropText.font = 'Pixel Arial 11 Bold';
    dropText.color = 0xFFD89494;
    dropText.scrollFactor.set();

    resetDialogue = function(text:String) {
        swagDialogue.resetText(text); // dialogueList[0]
		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			handSelect.visible = true;
			dialogueEnded = true;
		};
    };

    skipDialogue = function() {
        FlxG.sound.play(Paths.sound('clickText'), 0.8);
        swagDialogue.skip();
    }

    setAlpha = function(alpha:Float) {
        swagDialogue.alpha = alpha;
        dropText.alpha = alpha;
    }

    updateDrop = function() {
        dropText.text = swagDialogue.text;
    }

    setColor = function(color:Int) {
        swagDialogue.color = color;
    }

    bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
    bgFade.scrollFactor.set();
    bgFade.alpha = 0;
    PlayState.add(bgFade);
    FlxTween.tween(bgFade, {alpha: 0.7}, 4.15);

    box = new FlxSprite(-20, 45);
		
    var hasDialog = dialogueList.length < 1;
    switch (song)
    {
        case 'senpai':
            hasDialog = true;
            box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
            box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
            box.animation.addByIndices('normal', 'Text Box Appear instance 1', [4], "", 24);

            FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.8);
        case 'roses':
            hasDialog = true;
            FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

            box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
            box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
            box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 24);

        case 'thorns':
            hasDialog = true;
            box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
            box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
            box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [11], "", 24);

            face = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
            face.setGraphicSize(Std.int(face.width * 6));
            face.scrollFactor.set();
            PlayState.add(face);

            dropText.color = 0xFF000000;

            FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.8);
    }

    if (!hasDialog)
        return;

    portraitLeft = new FlxSprite(-20, 40);
    portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
    portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
    portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
    portraitLeft.updateHitbox();
    portraitLeft.scrollFactor.set();
    PlayState.add(portraitLeft);
    portraitLeft.visible = false;

    portraitRight = new FlxSprite(0, 40);
    portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
    portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
    portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
    portraitRight.updateHitbox();
    portraitRight.scrollFactor.set();
    PlayState.add(portraitRight);
    portraitRight.visible = false;
    
    box.animation.play('normalOpen');
    box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
    box.updateHitbox();
    box.scrollFactor.set();
    PlayState.add(box);

    PlayState.add(dropText);
    PlayState.add(swagDialogue);

    box.screenCenter(FlxAxes.X);
    portraitLeft.screenCenter(FlxAxes.X);
    portraitRight.screenCenter(FlxAxes.X);

    handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
    handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
    handSelect.updateHitbox();
    handSelect.visible = false;
    handSelect.scrollFactor.set();
    PlayState.add(handSelect);

    //startDialogue();
}

var dialogueOpened:Bool = false;
var dialogueStarted:Bool = false;
var dialogueEnded:Bool = false;

function onUpdate(elapsed:Float) {
    // HARD CODING CUZ IM STUPDI
    if (song == 'roses')
        portraitLeft.visible = false;
    if (song == 'thorns') {
        portraitLeft.visible = false;
        setColor(0xFFFFFFFF);
    }

    if (box.animation.curAnim != null) {
        if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished) {
            box.animation.play('normal');
            dialogueOpened = true;
        }
    }

    if (dialogueOpened && !dialogueStarted) {
        startDialogue();
        dialogueStarted = true;
    }

    if (FlxG.keys.justPressed.ENTER) {
        if (dialogueEnded) {
            if (dialogueList[1] == null && dialogueList[0] != null) {

                if (!isEnding) {
                    isEnding = true;

                    FlxG.sound.play(Paths.sound('clickText'), 0.8);	

                    if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
                        FlxG.sound.music.fadeOut(1.5, 0);

                    FlxTween.tween(box, {alpha: 0}, 1, {
                        onUpdate: function(_) {
                            bgFade.alpha = box.alpha * 0.7;
                            portraitLeft.alpha = box.alpha;
                            portraitRight.alpha = box.alpha;
                            
                            if (face != null)
                                face.alpha = box.alpha;

                            setAlpha(box.alpha);
                            handSelect.alpha = box.alpha;
                        }
                    });

                    new FlxTimer().start(1.5, function(tmr:FlxTimer) {
                        if (finishThing != null) 
                            finishThing();
                        else
                            debugPrint('finished but call back null');

                        FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
                    });
                }

            } else {
                FlxG.sound.play(Paths.sound('clickText'), 0.8);
                dialogueList.remove(dialogueList[0]);
                startDialogue();

            }
        } else if (dialogueStarted) {

            skipDialogue();
            
            if(skipDialogueThing != null) {
                skipDialogueThing();
            }

        }
    }

    updateDrop();
}

var isEnding:Bool = false;

function startDialogue():Void
{
    cleanDialog();
    resetDialogue(dialogueList[0]);

    handSelect.visible = false;
    dialogueEnded = false;

    switch (curCharacter)
    {

        case 'dad':
            portraitRight.visible = false;
            if (!portraitLeft.visible) {
                if (song == 'senpai') portraitLeft.visible = true;
                portraitLeft.animation.play('enter');
            }
        case 'bf':
            portraitLeft.visible = false;
            if (!portraitRight.visible) {
                portraitRight.visible = true;
                portraitRight.animation.play('enter');
            }
    }

    if(nextDialogueThing != null) {
        nextDialogueThing();
    }
}

function cleanDialog():Void
{
    var splitName:Array<String> = stringSplit(dialogueList[0], ':');
    curCharacter = splitName[1];
    dialogueList[0] = splitName[2];
}