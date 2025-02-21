// "schoolEvil"

import flixel.addons.effects.FlxTrail;

var bgGhouls:BGSprite;

function create() {
    PlayState.gfVersion = 'gf-pixel';
    GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
    GameOverSubstate.loopSoundName = 'gameOver-pixel';
    GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
    GameOverSubstate.characterName = 'bf-pixel-dead';

    /*if(!ClientPrefs.lowQuality) { //Does this even do something?
        var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
        var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
    }*/
    var posX = 400;
    var posY = 200;
    if(!ClientPrefs.lowQuality) {
        var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
        bg.scale.set(6, 6);
        bg.antialiasing = false;
        PlayState.addBehindGF(bg);

        bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
        bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState_.daPixelZoom));
        bgGhouls.updateHitbox();
        bgGhouls.visible = false;
        bgGhouls.antialiasing = false;
        PlayState.addBehindGF(bgGhouls);
    } else {
        var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
        bg.scale.set(6, 6);
        bg.antialiasing = false;
        PlayState.addBehindGF(bg);
    }
}

function onCreatePost() {
    var evilTrail = new FlxTrail(PlayState.dad, null, 4, 24, 0.3, 0.069); //nice
    PlayState.addBehindDad(evilTrail);
}

function cutscene() {
    var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
    black.scrollFactor.set();
    PlayState.add(black);

    var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
    red.scrollFactor.set();
    PlayState.add(red);

    var senpaiEvil:FlxSprite = new FlxSprite();
    senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
    senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
    senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
    senpaiEvil.scrollFactor.set();
    senpaiEvil.updateHitbox();
    senpaiEvil.screenCenter();
    senpaiEvil.x += 300;

    PlayState.camHUD.alpha = 0;

    // make the  thing more understandable holy shti
    FlxTween.tween(black, {alpha: 0}, 1.3, {
        onComplete: function(_) {

            PlayState.add(senpaiEvil);
            senpaiEvil.alpha = 0;

            FlxTween.tween(senpaiEvil, {alpha: 1}, 1.3, {
                onComplete: function(_) {

                    senpaiEvil.animation.play('idle');
                    FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {

                        PlayState.remove(senpaiEvil);
                        PlayState.remove(red);

                        FlxG.camera.fade(0xFFFFFFFF, 0.01, true, function() {
                            dialogue();

                        }, true);
                    });

                    new FlxTimer().start(3.2, function(_) {
                        FlxG.camera.fade(0xFFFFFFFF, 1.6, false);
                    });
                }
            });
        }
    });

}

// Dialog shits
var stopped:Bool = false;
function onStartCountdown() {
    if (!stopped && isStoryMode) {
        cutscene();
        stopped = true;

        return Function_Stop;
    }
}

function dialogue() {
    addStageScript('dialogueBox');
}

function onEvent(name:String) {
    if (name =='Trigger BG Ghouls') {
        if(!ClientPrefs.lowQuality) {
            bgGhouls.dance(true);
            bgGhouls.visible = true;
        }
    }
}

function onUpdate() {
    if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
        bgGhouls.visible = false;
    }
}