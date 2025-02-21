package editors.charter;

import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteGroup;

class AmplitudeBar extends FlxSpriteGroup {
    public var bar:FlxBar;
    public var object:Dynamic;
    public var variable:String;

    public function new(X:Float, Y:Float, Width:Int, Height:Int, Object:Dynamic, Variable:String) {
        super(X, Y);

        this.object = Object;
        this.variable = Variable;

        bar = new FlxBar(0, 0, RIGHT_TO_LEFT, Width, Height, null, null, 0, 1);
        bar.createGradientBar([0x7B000000], 
            [
                FlxColor.RED,
                FlxColor.ORANGE,
                FlxColor.YELLOW,
                0xFF00FF1E
            ], 1, 0, true, 0xFF000000);
        add(bar);
        bar.scrollFactor.set();
    }

    override function update(e:Float) {
        super.update(e);

        if (object != null && variable != null) {
            bar.value = Reflect.getProperty(object, variable);
        }
    }
}