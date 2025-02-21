package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public var isFlashing:Bool = false;
	private var flash:Bool = false;

	// holyshit ninjamuffin accept haxe is sometimes shit
	var timePerUpdate:Float = 0.096;
	var time:Float = 0.0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));

		time += elapsed;
		if (time > timePerUpdate && isFlashing) {
			time = 0.0;
			flash = !flash;
		}

		if (flash && isFlashing)
			color = 0xFF33ffff;
		else
			color = FlxColor.WHITE;
	}
}
