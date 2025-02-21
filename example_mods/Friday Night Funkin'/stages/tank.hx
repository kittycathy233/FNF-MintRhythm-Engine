// "tank"

var tankWatchtower:BGSprite;
var tankGround:BGSprite;
var song:String = Paths.formatToSongPath(PlayState.SONG.song);
var fgTankboppers:Array<BGSprite> = [];

var tankmen:Array<FlxSprite> = [];
var animationNotes:Array<Dynamic> = [];

function create() {
    //debugPrint('script load');

    PlayState.gfVersion = 'gf-tankmen';
    if (song == 'stress') {
        PlayState.gfVersion = 'pico-speaker';
        GameOverSubstate.characterName = 'bf-holding-gf-dead';
    }

    var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
    PlayState.addBehindGF(sky);

    if(!ClientPrefs.lowQuality)
    {
        var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
        clouds.active = true;
        clouds.velocity.x = FlxG.random.float(5, 15);
        PlayState.addBehindGF(clouds);

        var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
        mountains.setGraphicSize(Std.int(1.2 * mountains.width));
        mountains.updateHitbox();
        PlayState.addBehindGF(mountains);

        var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
        buildings.setGraphicSize(Std.int(1.1 * buildings.width));
        buildings.updateHitbox();
        PlayState.addBehindGF(buildings);
    }

    var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
    ruins.setGraphicSize(Std.int(1.1 * ruins.width));
    ruins.updateHitbox();
    PlayState.addBehindGF(ruins);

    if(!ClientPrefs.lowQuality)
    {
        var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
        PlayState.addBehindGF(smokeLeft);
        var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
        PlayState.addBehindGF(smokeRight);

        tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
        PlayState.addBehindGF(tankWatchtower);
    }

    tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
    PlayState.addBehindGF(tankGround);

    if (song == 'stress') {
        var sectionData = Song.getAllSectionNotes('picospeaker', song);
        for (section in sectionData) {
            for (note in section) {
                animationNotes.push(note);
            }
        }

        animationNotes.sort(sortAnims);
    
        for (i in 0...animationNotes.length) {
            if(FlxG.random.bool(18)) {
                var tankSoldier:PropertySprite = new PropertySprite(0, 0);
                tankSoldier.frames = Paths.getSparrowAtlas('tankmanKilled1');
                tankSoldier.animation.addByPrefix('run', 'tankman running', 24, true);
                tankSoldier.animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);
                tankSoldier.animation.play('run');
                tankSoldier.animation.curAnim.curFrame = FlxG.random.int(0, tankSoldier.animation.curAnim.frames.length - 1);
                tankSoldier.updateHitbox();
                tankSoldier.setGraphicSize(Std.int(0.8 * tankSoldier.width));
                tankSoldier.updateHitbox();

                tankSoldier.x = 500; 
                tankSoldier.y = 200 + FlxG.random.int(50, 100);
                tankSoldier.properties.set("strumTime", animationNotes[i][0]);
                tankSoldier.properties.set("speed", FlxG.random.float(0.6, 1));
                tankSoldier.properties.set("endOffset", FlxG.random.float(50, 200));
                tankSoldier.properties.set("goingRight", animationNotes[i][1] < 2);
                tankmen.push(tankSoldier);
                PlayState.addBehindGF(tankSoldier);

                tankSoldier.flipX = tankSoldier.properties.get('goingRight');
                //debugPrint('add tankmen at ' + i);
            }
        }
    }

    var ground:BGSprite = new BGSprite('tankGround', -420, -150);
    ground.setGraphicSize(Std.int(1.15 * ground.width));
    ground.updateHitbox();
    PlayState.addBehindGF(ground);
    //moveTank();

    tank0 = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
    PlayState.add(tank0);
    fgTankboppers.push(tank0);

    if(!ClientPrefs.lowQuality) {
        tank1 = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
        PlayState.add(tank1);
        fgTankboppers.push(tank1);
    }

    tank2 = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
    PlayState.add(tank2);
    fgTankboppers.push(tank2);

    if(!ClientPrefs.lowQuality) {
        tank4 = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
        PlayState.add(tank4);
        fgTankboppers.push(tank4);
    }

    tank5 = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
    PlayState.add(tank5);
    fgTankboppers.push(tank5);

    if(!ClientPrefs.lowQuality) {
        tank3 = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
        PlayState.add(tank3);
        fgTankboppers.push(tank3);
    }

    switch (song) {
        case 'ugh', 'guns', 'stress':
            addStageScript(song + 'Cutscene');
    }
}

function onUpdate(elapsed:Float) {
    for (tankSoldier in tankmen) {
        if (tankSoldier != null) {
            tankSoldier.visible = (tankSoldier.x > -0.5 * FlxG.width && tankSoldier.x < 1.2 * FlxG.width);

            var strumTime = tankSoldier.properties.get('strumTime');
            var tankSpeed = tankSoldier.properties.get('speed');
            var goingRight = tankSoldier.properties.get('goingRight');
            var endingOffset = tankSoldier.properties.get('endOffset');
    
            if(tankSoldier.animation.curAnim.name == "run") {
                var speed:Float = (Conductor.songPosition - strumTime) * tankSpeed;
                if(goingRight)
                    tankSoldier.x = (0.02 * FlxG.width - endingOffset) + speed;
                else
                    tankSoldier.x = (0.74 * FlxG.width + endingOffset) - speed;
            } else if(tankSoldier.animation.curAnim.finished) {
                tankSoldier.kill();
            }
            if(Conductor.songPosition > strumTime)
            {
                tankSoldier.animation.play('shot');
                if(goingRight)
                {
                    tankSoldier.offset.x = 300;
                    tankSoldier.offset.y = 200;
                }
            }
        }
    }

    // animationNotes has already been used to generate tankmen so we can use them here.
    if (PlayState.gf != null && PlayState.gf.curCharacter == 'pico-speaker') {
        PlayState.gf.skipDance = true;
        if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
        {
            var noteData:Int = 1;
            if(animationNotes[0][1] > 2) noteData = 3;

            noteData += FlxG.random.int(0, 1);
            PlayState.gf.playAnim('shoot' + noteData, true);
            animationNotes.shift();
        }
    }

    moveTank(elapsed);
}

var tankX:Float = 400;
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankAngle:Float = FlxG.random.int(-90, 45);

function moveTank(?elapsed:Float = 0):Void
{
    if(!PlayState.inCutscene)
    {
        tankAngle += elapsed * tankSpeed;
        tankGround.angle = tankAngle - 90 + 15;
        tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
        tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
    }
}

function onBeatHit() {
    if (curBeat % 2 == 0) {
        if(!ClientPrefs.lowQuality) tankWatchtower.dance();
        for (spr in fgTankboppers)
            spr.dance();
    }
}

function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
{
    return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
}