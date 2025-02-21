var upperBoppers:BGSprite;
var bottomBoppers:BGSprite;
var santa:BGSprite;

function create() {
    PlayState.gfVersion = 'gf-christmas';

    var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    PlayState.addBehindGF(bg);

    if(!ClientPrefs.lowQuality) {
        upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
        upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
        upperBoppers.updateHitbox();
        PlayState.addBehindGF(upperBoppers);

        var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
        bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
        bgEscalator.updateHitbox();
        PlayState.addBehindGF(bgEscalator);
    }

    var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
    PlayState.addBehindGF(tree);

    bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
    bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
    bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
    bottomBoppers.updateHitbox();
    PlayState.addBehindGF(bottomBoppers);

    var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
    PlayState.addBehindGF(fgSnow);

    santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
    PlayState.addBehindGF(santa);

    Paths.sound('Lights_Shut_Off');
}

function onBeatHit() {
    if(!ClientPrefs.lowQuality) {
        upperBoppers.dance(true);
    }

    if(PlayState.heyTimer <= 0) bottomBoppers.dance(true);
    santa.dance(true);
}

function onUpdate(elapsed:Float) {
    if(PlayState.heyTimer > 0) {
        PlayState.heyTimer -= elapsed;
        if(PlayState.heyTimer <= 0) {
            bottomBoppers.dance(true);
            PlayState.heyTimer = 0;
        }
    }
}

function onCountdownTick() {
    if(!ClientPrefs.lowQuality)
        upperBoppers.dance(true);

    bottomBoppers.dance(true);
    santa.dance(true);
}

function onEvent(name:String, value1:String, value2:String) {
    if (name == 'Hey!') {
        var time:Float = Std.parseFloat(value2);
        if(Math.isNaN(time) || time <= 0) time = 0.6;
        PlayState.heyTimer = time;
        bottomBoppers.animation.play('hey', true);
    }
}

var triggeredStop:Bool = false;
function onEndSong() {
    var winterHorrorlandNext = (Paths.formatToSongPath(PlayState.SONG.song) == "eggnog");
    var doStop:Bool = isStoryMode;

    if (winterHorrorlandNext && !triggeredStop && doStop) {
        var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
            -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
        blackShit.scrollFactor.set();
        PlayState.add(blackShit);

        FlxG.sound.play(Paths.sound('Lights_Shut_Off'));
        
        new FlxTimer().start(0.5, function(_) {
            FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5,
            {
                onComplete: function(_) {
                    PlayState.endSong();
                }
            });
        });
    }

    if (winterHorrorlandNext && !triggeredStop && doStop) {
        triggeredStop = true;
        return Function_Stop;
    }
}