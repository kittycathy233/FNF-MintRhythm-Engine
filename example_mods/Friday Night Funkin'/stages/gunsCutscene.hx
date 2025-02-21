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

    cutsceneHandler.endTime = 11.5;
    cutsceneHandler.music = 'DISTORTO';
    tankman.x += 40;
    tankman.y += 10;
    Paths.sound('tankSong2');

    var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
    FlxG.sound.list.add(tightBars);

    tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
    tankman.animation.play('tightBars', true);
    PlayState.boyfriend.animation.curAnim.finish();

    cutsceneHandler.onStart = function()
    {
        tightBars.play(true);
        FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
        FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
        FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
    };

    cutsceneHandler.timer(4, function()
    {
        PlayState.gf.playAnim('sad', true);
        PlayState.gf.animation.finishCallback = function(name:String)
        {
            PlayState.gf.playAnim('sad', true);
        };
    });
}