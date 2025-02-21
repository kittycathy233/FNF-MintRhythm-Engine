var stoppedOnce:Bool = false;
function onStartCountdown() {
    if (!stoppedOnce && isStoryMode) {
        stoppedOnce = true;
        startCutscene();
        return Function_Stop;
    }
}

function startCutscene() {
    var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

    var songName:String = Paths.formatToSongPath(PlayState.SONG.song);
    PlayState.dadGroup.alpha = 0.00001;
    PlayState.camHUD.alpha = 0;
    //inCutscene = true; //this would stop the camera movement, oops

    var tankman:FlxSprite = new FlxSprite(-20, 320);
    tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
    tankman.antialiasing = ClientPrefs.globalAntialiasing;
    PlayState.addBehindDad(tankman);
    cutsceneHandler.push(tankman);

    var tankman2:FlxSprite = new FlxSprite(16, 312);
    tankman2.antialiasing = ClientPrefs.globalAntialiasing;
    tankman2.alpha = 0.000001;
    cutsceneHandler.push(tankman2);

    var gfDance:FlxSprite = new FlxSprite(PlayState.gf.x - 107, PlayState.gf.y + 140);
    gfDance.antialiasing = ClientPrefs.globalAntialiasing;
    cutsceneHandler.push(gfDance);

    var gfCutscene:FlxSprite = new FlxSprite(PlayState.gf.x - 104, PlayState.gf.y + 122);
    gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
    cutsceneHandler.push(gfCutscene);

    var picoCutscene:FlxSprite = new FlxSprite(PlayState.gf.x - 849, PlayState.gf.y - 264);
    picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
    cutsceneHandler.push(picoCutscene);

    var boyfriendCutscene:FlxSprite = new FlxSprite(PlayState.boyfriend.x + 5, PlayState.boyfriend.y + 20);
    boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
    cutsceneHandler.push(boyfriendCutscene);

    cutsceneHandler.finishCallback = function()
    {
        var timeForStuff:Float = Conductor.crochet / 1000 * 3.5;
        FlxG.sound.music.fadeOut(timeForStuff);
        FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
        PlayState.moveCamera('dad');
        PlayState.startCountdown();

        PlayState.dadGroup.alpha = 1;
        FlxTween.tween(PlayState.camHUD, {alpha: 1}, timeForStuff);

        PlayState.boyfriend.animation.finishCallback = null;
        PlayState.gf.animation.finishCallback = null;
        PlayState.gf.dance();
    };

    PlayState.camFollow.set(PlayState.dad.x + 280, PlayState.dad.y + 170);

    cutsceneHandler.endTime = 35.5;
    tankman.x -= 54;
    tankman.y -= 14;
    PlayState.gfGroup.alpha = 0.00001;
    PlayState.boyfriendGroup.alpha = 0.00001;
    PlayState.camFollow.set(PlayState.dad.x + 400, PlayState.dad.y + 170);
    FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
    Paths.sound('stressCutscene');

    tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
    PlayState.addBehindDad(tankman2);

    if (!ClientPrefs.lowQuality)
    {
        gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
        gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
        gfDance.animation.play('dance', true);
        PlayState.addBehindGF(gfDance);
    }

    gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
    gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
    gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
    gfCutscene.animation.play('dieBitch', true);
    gfCutscene.animation.pause();
    PlayState.addBehindGF(gfCutscene);
    if (!ClientPrefs.lowQuality)
    {
        gfCutscene.alpha = 0.00001;
    }

    picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
    picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
    PlayState.addBehindGF(picoCutscene);
    picoCutscene.alpha = 0.00001;

    boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
    boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
    boyfriendCutscene.animation.play('idle', true);
    boyfriendCutscene.animation.curAnim.finish();
    PlayState.addBehindBF(boyfriendCutscene);

    var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
    FlxG.sound.list.add(cutsceneSnd);

    tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
    tankman.animation.play('godEffingDamnIt', true);

    var calledTimes:Int = 0;
    var zoomBack:Void->Void = function()
    {
        var camPosX:Float = 630;
        var camPosY:Float = 425;
        PlayState.camFollow.set(camPosX, camPosY);
        PlayState.camFollowPos.setPosition(camPosX, camPosY);
        FlxG.camera.zoom = 0.8;
        PlayState.cameraSpeed = 1;

        calledTimes++;
    }

    cutsceneHandler.onStart = function()
    {
        cutsceneSnd.play(true);
    };

    cutsceneHandler.timer(15.2, function()
    {
        FlxTween.tween(PlayState.camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

        gfDance.visible = false;
        gfCutscene.alpha = 1;
        gfCutscene.animation.play('dieBitch', true);
        gfCutscene.animation.finishCallback = function(name:String)
        {
            if(name == 'dieBitch') //Next part
            {
                gfCutscene.animation.play('getRektLmao', true);
                gfCutscene.offset.set(224, 445);
            }
            else
            {
                gfCutscene.visible = false;
                picoCutscene.alpha = 1;
                picoCutscene.animation.play('anim', true);

                PlayState.boyfriendGroup.alpha = 1;
                boyfriendCutscene.visible = false;
                PlayState.boyfriend.playAnim('bfCatch', true);
                PlayState.boyfriend.animation.finishCallback = function(name:String)
                {
                    if(name != 'idle')
                    {
                        PlayState.boyfriend.playAnim('idle', true);
                        PlayState.boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
                    }
                };

                picoCutscene.animation.finishCallback = function(name:String)
                {
                    picoCutscene.visible = false;
                    PlayState.gfGroup.alpha = 1;
                    picoCutscene.animation.finishCallback = null;
                };
                gfCutscene.animation.finishCallback = null;
            }
        };
    });

    cutsceneHandler.timer(17.5, function()
    {
        zoomBack();
    });

    cutsceneHandler.timer(19.5, function()
    {
        tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
        tankman2.animation.play('lookWhoItIs', true);
        tankman2.alpha = 1;
        tankman.visible = false;
    });

    cutsceneHandler.timer(20, function()
    {
        PlayState.camFollow.set(PlayState.dad.x + 500, PlayState.dad.y + 170);
    });

    cutsceneHandler.timer(31.2, function()
    {
        PlayState.boyfriend.playAnim('singUPmiss', true);
        PlayState.boyfriend.animation.finishCallback = function(name:String)
        {
            if (name == 'singUPmiss')
            {
                PlayState.boyfriend.playAnim('idle', true);
                PlayState.boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
            }
        };

        PlayState.camFollow.set(PlayState.boyfriend.x + 280, PlayState.boyfriend.y + 200);
        PlayState.cameraSpeed = 12;
        FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
    });

    cutsceneHandler.timer(32.2, function()
    {
        zoomBack();
    });
}