// "school"

var bgGirls:FlxSprite;

function create() {
    PlayState.gfVersion = 'gf-pixel';
    GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
    GameOverSubstate.loopSoundName = 'gameOver-pixel';
    GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
    GameOverSubstate.characterName = 'bf-pixel-dead';

    var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
    PlayState.addBehindGF(bgSky);
    bgSky.antialiasing = false;

    var repositionShit = -200;

    var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
    PlayState.addBehindGF(bgSchool);
    bgSchool.antialiasing = false;

    var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
    PlayState.addBehindGF(bgStreet);
    bgStreet.antialiasing = false;

    var widShit = Std.int(bgSky.width * 6);
    if(!ClientPrefs.lowQuality) {
        var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
        fgTrees.setGraphicSize(Std.int(widShit * 0.8));
        fgTrees.updateHitbox();
        PlayState.addBehindGF(fgTrees);
        fgTrees.antialiasing = false;
    }

    var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
    bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
    bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
    bgTrees.animation.play('treeLoop');
    bgTrees.scrollFactor.set(0.85, 0.85);
    PlayState.addBehindGF(bgTrees);
    bgTrees.antialiasing = false;

    if(!ClientPrefs.lowQuality) {
        var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
        treeLeaves.setGraphicSize(widShit);
        treeLeaves.updateHitbox();
        PlayState.addBehindGF(treeLeaves);
        treeLeaves.antialiasing = false;
    }

    bgSky.setGraphicSize(widShit);
    bgSchool.setGraphicSize(widShit);
    bgStreet.setGraphicSize(widShit);
    bgTrees.setGraphicSize(Std.int(widShit * 1.4));

    bgSky.updateHitbox();
    bgSchool.updateHitbox();
    bgStreet.updateHitbox();
    bgTrees.updateHitbox();

    if(!ClientPrefs.lowQuality) {
        bgGirls = new FlxSprite(-100, 190);
        bgGirls.frames = Paths.getSparrowAtlas('weeb/bgFreaks');
        girlsPissed();
        bgGirls.animation.play('danceLeft');

        bgGirls.scrollFactor.set(0.9, 0.9);
        bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
        bgGirls.updateHitbox();
        PlayState.addBehindGF(bgGirls);
    }

    if (Paths.formatToSongPath(Paths.formatToSongPath(PlayState.SONG.song)) == 'roses')
        FlxG.sound.play(Paths.sound('ANGRY'));
}

function onUpdate() {
    if (!isPissed) {
        if (!ClientPrefs.lowQuality) {
            if (Paths.formatToSongPath(Paths.formatToSongPath(PlayState.SONG.song)) == 'roses')
                girlsPissed();
        }
    }
}

function onBeatHit() {
    if(!ClientPrefs.lowQuality) {
        girlsDance();
    }
}

function onEvent(name:String) {
    if (name == 'BG Freaks Expression')
		if(bgGirls != null) girlsPissed();
}

var danceDir:Bool = false;
function girlsDance():Void
{
    danceDir = !danceDir;

    if (danceDir)
        bgGirls.animation.play('danceRight', true);
    else
        bgGirls.animation.play('danceLeft', true);
}

var isPissed:Bool = true;
function girlsPissed() {
    isPissed = !isPissed;
    if(!isPissed) { //Gets unpissed
        bgGirls.animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
        bgGirls.animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
    } else { //Pisses
        bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
        bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
    }
    girlsDance();
}


// Dialog shits
var stopped:Bool = false;
function onStartCountdown() {
    if (!stopped && isStoryMode) {
        dialogue();
        stopped = true;

        return Function_Stop;
    }

    FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
}

function dialogue() {
    addStageScript('dialogueBox');
}