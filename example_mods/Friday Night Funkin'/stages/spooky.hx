var halloweenBG:BGSprite;
var halloweenWhite:BGSprite;

// "spooky"
//Eeaeoaea a a a aa aeoaee eea

function create() {
    if(!ClientPrefs.lowQuality)
        halloweenBG = new BGSprite('halloween_bg', -200, -100, 1, 1, ['halloweem bg0', 'halloweem bg lightning strike']);
    else
        halloweenBG = new BGSprite('halloween_bg_low', -200, -100, 1, 1);
    PlayState.addBehindGF(halloweenBG);

    halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
    halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFFFFFFFF);
    halloweenWhite.alpha = 0;
    halloweenWhite.blend = BlendMode.ADD;
    PlayState.add(halloweenWhite);

    Paths.sound('thunder_1');
    Paths.sound('thunder_2');
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function onBeatHit() {
    if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
        lightningStrikeShit();
}

function lightningStrikeShit():Void
{
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

    lightningStrikeBeat = curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    if(PlayState.boyfriend.animOffsets.exists('scared')) {
        PlayState.boyfriend.playAnim('scared', true);
    }

    if(PlayState.gf != null && PlayState.gf.animOffsets.exists('scared')) {
        PlayState.gf.playAnim('scared', true);
    }

    if(ClientPrefs.camZooms) {
        PlayState.curGameZoom += 0.015;
        PlayState.curHudZoom += 0.03;
    }

    if(ClientPrefs.flashing) {
        halloweenWhite.alpha = 0.4;
        FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
        FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
    }
}