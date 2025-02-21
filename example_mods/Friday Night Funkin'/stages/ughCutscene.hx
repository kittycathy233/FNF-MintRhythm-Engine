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

    cutsceneHandler.endTime = 12;
    cutsceneHandler.music = 'DISTORTO';

    Paths.sound('wellWellWell');
    Paths.sound('killYou');
    Paths.sound('bfBeep');

    var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
    FlxG.sound.list.add(wellWellWell);

    tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
    tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
    tankman.animation.play('wellWell', true);
    FlxG.camera.zoom *= 1.2;

    // Well well well, what do we got here?
    cutsceneHandler.timer(0.1, function()
    {
        wellWellWell.play(true);
    });

    // Move camera to BF
    cutsceneHandler.timer(3, function()
    {
        PlayState.camFollow.x += 750;
        PlayState.camFollow.y += 100;
    });

    // Beep!
    cutsceneHandler.timer(4.5, function()
    {
        PlayState.boyfriend.playAnim('singUP', true);
        PlayState.boyfriend.specialAnim = true;
        FlxG.sound.play(Paths.sound('bfBeep'));
    });

    // Move camera to Tankman
    cutsceneHandler.timer(6, function()
    {
        PlayState.camFollow.x -= 750;
        PlayState.camFollow.y -= 100;

        // We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
        tankman.animation.play('killYou', true);
        FlxG.sound.play(Paths.sound('killYou'));
    });
}