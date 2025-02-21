package background;

import flixel.FlxSprite;
import flixel.FlxG;

class SnowParticle extends FlxSprite {
    public var decay:Float = 0.0;
    public var originalScale:Float = 1;
    public var aliveTime:Float = 0;
    public var startX:Float = 2000;
    public var startY:Float = -100;
    public var particleFallAngle:Float = 200;

	public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic(Paths.image('christmas/snowParticle'));
        antialiasing = ClientPrefs.globalAntialiasing;
		decay = FlxG.random.float(0.8, 1);

        originalScale = FlxG.random.float(0.75, 1);
		scale.set(originalScale, originalScale);
        velocity.y = FlxG.random.float(50, 200);

        startPositions();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (x < -600) resetAxis('x');
        if (y > 1000) resetAxis('y');

        startX -= (elapsed * 200) * decay;
        x = startX + ((20 + Math.sin(aliveTime * 0.5)) * decay);

        aliveTime += elapsed;
    }

    public function resetAxis(axis:String = 'x') {
        switch(axis) {
            case 'x':
                startX = FlxG.random.float(1800, 2000);
                x = startX;
            case 'y':
                velocity.y = FlxG.random.float(50, 200);
                y = FlxG.random.float(-400, -300);
        }
    }

    public function startPositions() {
        startX = FlxG.random.float(-100, 2200);
        x = startX;

        y = FlxG.random.float(-200, 800);
    }
}