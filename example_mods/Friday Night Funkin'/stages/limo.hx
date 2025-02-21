// "limo"

var limoKillingState:Int = 0;
var limo:BGSprite;
var limoMetalPole:BGSprite;
var limoLight:BGSprite;
var limoCorpse:BGSprite;
var limoCorpseTwo:BGSprite;
var bgLimo:BGSprite;
var limoOverlay:BGSprite;
var grpLimoParticles:Array<BGSprite> = [];
var grpLimoDancers:Array<FlxSprite> = [];
var fastCar:BGSprite;
var windBeams:Array<FlxSprite> = [];

function create() {
    PlayState.gfVersion = 'gf-car';

    var skyBG:BGSprite = new BGSprite('limo/limoSunset', -300, -180, 0.1, 0.1);
    PlayState.addBehindGF(skyBG);

    if(!ClientPrefs.lowQuality) {
        limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
        PlayState.addBehindGF(limoMetalPole);

        bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
        PlayState.addBehindGF(bgLimo);

        limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
        PlayState.addBehindGF(limoCorpse);

        limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
        PlayState.addBehindGF(limoCorpseTwo);

        for (i in 0...5)
        {
            var dancer:FxSprite = new FlxSprite((370 * i) + 170, bgLimo.y - 400);
            dancer.frames = Paths.getSparrowAtlas("limo/limoDancer");
            dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
            dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
            dancer.animation.play('danceLeft');
            dancer.antialiasing = ClientPrefs.globalAntialiasing;
            dancer.scrollFactor.set(0.4, 0.4);
            PlayState.addBehindGF(dancer);
            grpLimoDancers.push(dancer);
        }

        limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
        PlayState.addBehindGF(limoLight);

        //PRECACHE BLOOD
        var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
        particle.alpha = 0.01;
        grpLimoParticles.push(particle);
        PlayState.addBehindGF(particle);
        resetLimoKill();

        //PRECACHE SOUND
        Paths.sound('dancerdeath');
    }

    limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
    PlayState.addBehindDad(limo);

    fastCar = new BGSprite('limo/fastCarLol', -300, 160);
    fastCar.active = true;
    PlayState.addBehindGF(fastCar);
    resetFastCar();
    limoKillingState = 0;

    limoOverlay = new BGSprite('limo/limoOverlay', -500, -600);
    limoOverlay.alpha = 0.2;
    limoOverlay.blend = BlendMode.ADD;
    PlayState.add(limoOverlay);
}

var limoSpeed:Float = 0;
function onUpdate(elapsed:Float) {
    for (particle in grpLimoParticles) {
        if(particle.animation.curAnim.finished) {
            particle.kill();
            grpLimoParticles.remove(particle);
            particle.destroy();
        }
    }

    PlayState.gf.x = bgLimo.x + 460;
    PlayState.gf.y = bgLimo.y - 270;
    PlayState.gf.scale.set(0.75, 0.75);
    PlayState.gf.scrollFactor.set(0.4, 0.4);

    switch(limoKillingState) {
        case 1:
            limoMetalPole.x += 5000 * elapsed;
            limoLight.x = limoMetalPole.x - 180;
            limoCorpse.x = limoLight.x - 50;
            limoCorpseTwo.x = limoLight.x + 35;

            var dancers:Array<FlxSprite> = grpLimoDancers;
            for (i in 0...dancers.length) {
                if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
                    switch(i) {
                        case 0, 1, 2, 3:
                            if (i == 0)
                                FlxG.sound.play(Paths.sound('dancerdeath'), 0.6);

                            var diffStr:String = i == 3 ? ' 2 ' : ' ';
                            var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
                            grpLimoParticles.push(particle);
                            PlayState.addBehindGF(particle);
                            var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
                            grpLimoParticles.push(particle);
                            PlayState.addBehindGF(particle);
                            var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
                            grpLimoParticles.push(particle);
                            PlayState.addBehindGF(particle);

                            var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
                            particle.flipX = true;
                            particle.angle = -57.5;
                            grpLimoParticles.push(particle);
                            PlayState.addBehindGF(particle);
                        case 1:
                            limoCorpse.visible = true;
                        case 2:
                            limoCorpseTwo.visible = true;
                    } //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
                    dancers[i].x += FlxG.width * 2;
                }
            }

            if(limoMetalPole.x > FlxG.width * 2) {
                resetLimoKill();
                limoSpeed = 800;
                limoKillingState = 2;
            }

        case 2:
            limoSpeed -= 4000 * elapsed;
            bgLimo.x -= limoSpeed * elapsed;
            if(bgLimo.x > FlxG.width * 1.5) {
                limoSpeed = 3000;
                limoKillingState = 3;
            }

        case 3:
            limoSpeed -= 2000 * elapsed;
            if(limoSpeed < 1000) limoSpeed = 1000;

            bgLimo.x -= limoSpeed * elapsed;
            if(bgLimo.x < -275) {
                limoKillingState = 4;
                limoSpeed = 800;
            }

        case 4:
            bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
            if(Math.round(bgLimo.x) == -150) {
                bgLimo.x = -150;
                limoKillingState = 0;
            }
    }

    if(limoKillingState > 2) {
        var dancers:Array<BackgroundDancer> = grpLimoDancers;
        for (i in 0...dancers.length) {
            dancers[i].x = (370 * i) + bgLimo.x + 280;
        }
    }
}

function onUpdatePost() {
    PlayState.cameraSpeed = 0.5;

    var i = (Conductor.songPosition + 5000) / 1000 * 30;
    PlayState.defaultCamZoom = (Math.sin(i/40)*0.05) + 0.8;

    PlayState.moveCameraSection();
    PlayState.camFollow.y += (Math.sin(i/14)*30) - 50;
    PlayState.camFollow.x += (Math.sin(i/7)*15);

    // wanky hud controls
    PlayState.defaultHudZoom = (Math.sin(i/40)*0.05) + 1;
    PlayState.camHUD.y = Math.sin(i/28) * 10;
    PlayState.camHUD.x = Math.sin(i/14) * 5;
}

function eventEarlyTrigger(event:String) {
    if (event == "Kill Henchmen") {
        return 280;
    }
}

function onEvent(name:String, value1:String, value2:String) {
    if (name == 'Kill Henchmen')
        killHenchmen();
}

function killHenchmen():Void
{
    if(!ClientPrefs.lowQuality && ClientPrefs.violence) {
        if(limoKillingState < 1) {
            limoMetalPole.x = -400;
            limoMetalPole.visible = true;
            limoLight.visible = true;
            limoCorpse.visible = false;
            limoCorpseTwo.visible = false;
            limoKillingState = 1;
        }
    }
}

function resetLimoKill():Void
{
    limoMetalPole.x = -500;
    limoMetalPole.visible = false;
    limoLight.x = -500;
    limoLight.visible = false;
    limoCorpse.x = -500;
    limoCorpse.visible = false;
    limoCorpseTwo.x = -500;
    limoCorpseTwo.visible = false;
}

function resetFastCar():Void
{
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
}

var carTimer:FlxTimer;
var fastCarCanDrive:Bool = true;
function fastCarDrive() {
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
    PlayState.camFollow.x -= 30;

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
    {
        resetFastCar();
        carTimer = null;
    });
}

// left = false, right = true
var dancerDir:Bool = false;
function onBeatHit() {
    if(!ClientPrefs.lowQuality) {
        dancerDir = !dancerDir;

        for (dancer in grpLimoDancers) {
            if (dancerDir)
                dancer.animation.play('danceRight');
            else
                dancer.animation.play('danceLeft');
        }
    }

    if (FlxG.random.bool(10) && fastCarCanDrive)
        fastCarDrive();
}