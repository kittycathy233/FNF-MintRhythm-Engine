// "mallEvil"
var opponentHasSang:Bool = false;
var triggerEvent:Bool = isStoryMode;
var stoppedOnce:Bool = false;

var blackScreen:FlxSprite;

function create() {
    var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    PlayState.addBehindGF(bg);

    var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
    PlayState.addBehindGF(evilTree);

    var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
    PlayState.addBehindGF(evilSnow);

    if (triggerEvent) {
        blackScreen = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
        blackScreen.scrollFactor.set();
        PlayState.add(blackScreen);
        FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
            onComplete: function(twn:FlxTween) {
                PlayState.remove(blackScreen);
            }
        });
        FlxG.sound.play(Paths.sound('Lights_Turn_On'));
    }
}

function onCreatePost() {
    if (triggerEvent)
        PlayState.camHUD.alpha = 0;
    PlayState.gf.visible = false;

    if (triggerEvent) {
        PlayState.snapCamFollowToPos(400, -2050);
        FlxG.camera.focusOn(PlayState.camFollow);
        FlxG.camera.zoom = 1.5;
        PlayState.curGameZoom = 1.5;
        PlayState.camZoomingDecay = 0.5;
    }
}

function onStartCountdown() {
    if (!stoppedOnce && triggerEvent) {
        stoppedOnce = true;
        new FlxTimer().start(2, function(tmr:FlxTimer) {
            PlayState.startCountdown();
            PlayState.returnZoom = true;
        });
        PlayState.skipCountdown = true;
        return Function_Stop;
    }
}

function opponentNoteHit() {
    if (!opponentHasSang && triggerEvent)
        FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);

    opponentHasSang = true;
}