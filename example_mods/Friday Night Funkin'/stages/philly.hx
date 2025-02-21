var phillyLightsColors:Array<Int> = [
    0xFF31A2FD, 
    0xFF31FD8C, 
    0xFFFB33F5, 
    0xFFFD4531, 
    0xFFFBA633];
var bg:BGSprite;
var city:BGSpriite;
var phillyWindow:BGSprite;
var phillyStreet:BGSprite;
var blammedLightsBlack:FlxSprite;
var phillyWindowEvent:BGSprite;
var streetBehind:BGSprite;

var phillyTrain:BGSprite;
var phillyFrontTrain:BGSprite;

var phillyGlowGradient:FlxSprite;
var phillyGlowParticles:Array<FlxSprite> = [];

// LIGHTS

var curLight:Int = -1;
var curLightEvent:Int = -1;

var updateGlowGradient:Bool = false;

// BACK TRAIN

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var trainSound:FlxSound;

var startedMoving:Bool = false;

// FRONT TRAIN

var frontTrainMoving:Bool = false;
var frontTrainFrameTiming:Float = 0;
var frontTrainCars:Int = 8;
var frontTrainFinishing:Bool = false;
var frontTrainCooldown:Int = 0;
var frontTrainSound:FlxSound;

var frontTrainStartedMoving:Bool = false;

// "philly"

function create() {
    if(!ClientPrefs.lowQuality) {
        bg = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
        PlayState.addBehindGF(bg);
    }

    city = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    PlayState.addBehindGF(city);

    phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
    phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
    phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
    phillyWindow.updateHitbox();
    PlayState.addBehindGF(phillyWindow);
    phillyWindow.alpha = 0;

    if(!ClientPrefs.lowQuality) {
        streetBehind = new BGSprite('philly/behindTrain', -40, 50);
        PlayState.addBehindGF(streetBehind);
    }

    phillyTrain = new BGSprite('philly/train', 2000, 360);
    PlayState.addBehindGF(phillyTrain);

    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
    FlxG.sound.list.add(trainSound);
    frontTrainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
    FlxG.sound.list.add(frontTrainSound);

    phillyStreet = new BGSprite('philly/street', -40, 50);
    PlayState.addBehindGF(phillyStreet);

    phillyFrontTrain = new BGSprite('philly/train', 2000, 160);
    phillyFrontTrain.scale.set(2.2, 2.2);
    phillyFrontTrain.updateHitbox();
    //PlayState.defaultCamZoom = 0.3;
    //PlayState.cpuControlled = true;
    PlayState.add(phillyFrontTrain);
}

function onUpdate(elapsed:Float) {
    if (trainMoving) {
        trainFrameTiming += elapsed;

        if (trainFrameTiming >= 1 / 24)
        {
            updateTrainPos();
            trainFrameTiming = 0;
        }
    }

    if (frontTrainMoving) {
        frontTrainFrameTiming += elapsed;

        if (frontTrainFrameTiming >= 1 / 24)
        {
            updateFrontTrainPos();
            frontTrainFrameTiming = 0;
        }
    }

    phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

    var ratio = 0.25 * elapsed * 60;
    var theLerp = Math.abs(FlxMath.bound(FlxMath.remapToRange(phillyTrain.x, 0, -2000, 0, 1), 0, 100));
    var ogAlpha = phillyTrain.x > -2000 && phillyTrain.x < 0 ? 0 : 1;

    if (theLerp > 1) theLerp = 1 - (theLerp - 1);

    if (!updateGlowGradient) {
        var objectsToColor = [PlayState.boyfriend, PlayState.gf, PlayState.dad, phillyStreet, city, bg, streetBehind];
        for(c in objectsToColor) {
            c.colorTransform.redMultiplier = FlxMath.lerp(c.colorTransform.redMultiplier, FlxMath.lerp(ogAlpha, (118 / 255), theLerp), ratio);
            c.colorTransform.greenMultiplier = FlxMath.lerp(c.colorTransform.greenMultiplier, FlxMath.lerp(ogAlpha, (255 / 255), theLerp), ratio);
            c.colorTransform.blueMultiplier = FlxMath.lerp(c.colorTransform.blueMultiplier, FlxMath.lerp(ogAlpha, (111 / 255), theLerp), ratio);
        }
    
        city.alpha = FlxMath.lerp(city.alpha, (1 - theLerp) * (1 - theLerp), ratio);
        bg.alpha = Math.min(FlxMath.lerp(bg.alpha, ogAlpha, ratio), city.alpha);
        phillyWindow.alpha *= city.alpha;
    }
    else
        phillyGradientUpdate(elapsed);
}

function onBeatHit() {
    if (!trainMoving)
        trainCooldown += 1;
    
    if (!frontTrainStartedMoving)
        frontTrainCooldown += 1;

    if (curBeat % 4 == 0) {
        curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
        phillyWindow.color = phillyLightsColors[curLight];
        phillyWindow.alpha = 1;
    }

    if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
        trainCooldown = FlxG.random.int(-4, 0);
        trainStart();
    }

    if (curBeat % 8 == 0 && FlxG.random.bool(25) && !frontTrainMoving && frontTrainCooldown > 12) {
        trainCooldown = FlxG.random.int(-6, -2);
        frontTrainStart();
    }
}

function trainStart():Void {
    trainMoving = true;
    if (!trainSound.playing)
        trainSound.play(true);

    //debugPrint('back train started');
}

function frontTrainStart():Void {
    frontTrainMoving = true;
    if (!frontTrainSound.playing) {
        frontTrainSound.play(true);
        frontTrainSound.volume = 1.5;
    }

    //debugPrint('front train started');
}

function updateTrainPos():Void
{
    if (trainSound.time >= 4700)
    {
        startedMoving = true;
        if (startedMoving) {
            if (PlayState.gf != null)
            {
                PlayState.gf.playAnim('hairBlow');
                PlayState.gf.specialAnim = true;
            }
        }
    }

    if (startedMoving) {
        phillyTrain.x -= 400;

        if (phillyTrain.x < -2000 && !trainFinishing) {
            phillyTrain.x = -1150;
            trainCars -= 1;

            if (trainCars <= 0)
                trainFinishing = true;
        }

        if (phillyTrain.x < -4000 && trainFinishing)
            trainReset();
    }
}

function updateFrontTrainPos():Void {
    if (frontTrainSound.time >= 4700)
    {
        frontTrainStartedMoving = true;
    }

    if (frontTrainStartedMoving) {
        phillyFrontTrain.x -= 400;

        if (phillyFrontTrain.x < -2000 && !frontTrainFinishing) {
            phillyFrontTrain.x = -1150;
            frontTrainCars -= 1;

            if (frontTrainCars <= 0)
                frontTrainFinishing = true;
        }

        if (phillyFrontTrain.x < -8500 && frontTrainFinishing)
            frontTrainReset();
    }
}

function trainReset():Void
{
    if(PlayState.gf != null) {
        PlayState.gf.danced = false; //Sets head to the correct position once the animation ends
        PlayState.gf.playAnim('hairFall');
        PlayState.gf.specialAnim = true;
    }

    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
}

function frontTrainReset():Void
{
    phillyFrontTrain.x = 2000;
    frontTrainMoving = false;
    frontTrainCars = 8;
    frontTrainFinishing = false;
    frontTrainStartedMoving = false;
}

function onEventPushed(event:String) {
    if (event == 'Philly Glow') {
        blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
        blammedLightsBlack.visible = false;
        PlayState.insert(PlayState.members.indexOf(phillyStreet), blammedLightsBlack);

        phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
        phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
        phillyWindowEvent.updateHitbox();
        phillyWindowEvent.visible = false;
        PlayState.insert(PlayState.members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

        phillyGlowGradient = new FlxSprite(-400, 265); //This shit was refusing to properly load FlxGradient so fuck it
        phillyGlowGradient.visible = false;
        phillyGlowGradient.loadGraphic(Paths.image('philly/gradient'));
        PlayState.insert(PlayState.members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);

        Paths.image('philly/particle');
    }
}

function onEvent(name:String, value1:String, value2:String) {
    if (name == 'Philly Glow') {
        var lightId:Int = Std.parseInt(value1);
        if(Math.isNaN(lightId)) lightId = 0;

        var doFlash:Void->Void = function() {
            var color:Int = 0xFFFFFFFF;
            if(!ClientPrefs.flashing) color = 0x83FFFFFF;

            FlxG.camera.flash(color, 0.15, null, true);
        };

        var chars:Array<Character> = [
            PlayState.boyfriend, 
            PlayState.gf, 
            PlayState.dad];
        switch(lightId)
        {
            ///DISABLE
            case 0:
                if(phillyGlowGradient.visible)
                {
                    doFlash();
                    if(ClientPrefs.camZooms)
                    {
                        PlayState.curGameZoom += 0.5;
                        PlayState.curHudZoom += 0.1;
                    }

                    updateGlowGradient = false;

                    blammedLightsBlack.visible = false;
                    phillyWindowEvent.visible = false;
                    phillyGlowGradient.visible = false;
                    for(particle in phillyGlowParticles) {
                        particle.visible = false;
                    }
                    curLightEvent = -1;

                    for (who in chars)
                        who.color = 0xFFFFFFFF;

                    phillyStreet.color = 0xFFFFFFFF;
                }

            case 1: //turn on
                curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
                var color = phillyLightsColors[curLightEvent];

                if(!phillyGlowGradient.visible)
                {
                    doFlash();
                    if(ClientPrefs.camZooms)
                    {
                        PlayState.curGameZoom += 0.5;
                        PlayState.curHudZoom += 0.1;
                    }

                    blammedLightsBlack.visible = true;
                    blammedLightsBlack.alpha = 1;
                    phillyWindowEvent.visible = true;
                    phillyGlowGradient.visible = true;
                    updateGlowGradient = true;
                    //phillyGlowParticles.visible = true;
                }
                else if(ClientPrefs.flashing)
                {
                    var flashThing:FlxSprite = new FlxSprite(-800, -800).makeGraphic(5000, 5000);
                    flashThing.color = color;
                    flashThing.alpha = 0.25;
                    PlayState.add(flashThing);
                    FlxTween.tween(flashThing, {alpha: 0}, 0.5, {onComplete: function(_) {
                        PlayState.remove(flashThing);
                    }});
                }

                var charColor = color;
                for (who in chars)
                    who.color = charColor;

                phillyGlowGradient.color = color;
                phillyWindowEvent.color = color;
                phillyStreet.color = color;

                for(particle in phillyGlowParticles) {
                    particle.color = color;
                }
            case 2: // spawn particles
                if(!ClientPrefs.lowQuality)
                {
                    var particlesNum:Int = FlxG.random.int(20, 24);
                    var width:Float = (2000 / particlesNum);
                    var color = phillyLightsColors[curLightEvent];
                    for (j in 0...3)
                    {
                        for (i in 0...particlesNum)
                        {  
                            var particle:FlxSprite = new FlxSprite(
                                -400 + width * i + FlxG.random.float(-width / 5, width / 5), 
                                265 + 200 + (FlxG.random.float(0, 125) + j * 40));
                            particle.loadGraphic(Paths.image('philly/particle'));
                            doParticleStuff(particle, color);
                            phillyGlowParticles.push(particle);
                        }
                    }
                }
                phillyGradientBop();
        }
    }
}

function doParticleStuff(particle:FlxSprite, color) {
    PlayState.insert(PlayState.members.indexOf(phillyGlowGradient) + 1, particle);

    particle.scrollFactor.set(FlxG.random.float(0.3, 0.75), FlxG.random.float(0.65, 0.75));
    particle.velocity.set(FlxG.random.float(-40, 40), FlxG.random.float(-175, -250));
    particle.acceleration.set(FlxG.random.float(-10, 10), 25);
    particle.color = color;

    var lifeTime = FlxG.random.float(0.6, 0.9);
    var decay = FlxG.random.float(0.8, 1);
    var originalScale = FlxG.random.float(0.75, 1);
    particle.scale.set(originalScale, originalScale);

    if(!ClientPrefs.flashing)
    {
        decay *= 0.5;
        particle.alpha = 0.5;
    }

    FlxTween.tween(particle, {alpha: 0}, decay, {
        startDelay: lifeTime, 
        onUpdate: function(_) {
            if (particle.alpha > 0) {
                var ns:Float = originalScale * particle.alpha;
                particle.scale.set(ns, ns); 
            }
        },
        onComplete: function(_) {
            particle.kill();
            phillyGlowParticles.remove(particle);
            particle.destroy();
        }
    });
}

function phillyGradientUpdate(elapsed:Float) {
    var newHeight:Int = Math.round(phillyGlowGradient.height - 1000 * elapsed);
    if(newHeight > 0) {
        phillyGlowGradient.alpha = 0.7;
        phillyGlowGradient.setGraphicSize(2000, newHeight);
        phillyGlowGradient.updateHitbox();
        phillyGlowGradient.y = 265 + (400 - phillyGlowGradient.height);
    } else {
        phillyGlowGradient.alpha = 0;
        phillyGlowGradient.y = -5000;
    }
}

function phillyGradientBop() {
    phillyGlowGradient.setGraphicSize(2000, 400);
    phillyGlowGradient.updateHitbox();
    phillyGlowGradient.y = 265;
    phillyGlowGradient.alpha = 0.7;
}