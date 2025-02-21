package flixel.addons.ui;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUIAssets;
import flixel.util.FlxColor;

class FlxUISlider extends FlxUIGroup {

    public var object:Dynamic;
    public var variable:String;
    public var min:Float = 0;
    public var max:Float = 100;

    public var value:Float;

    public var sliderSprite:FlxSprite;
    public var bar:FlxBar;

    public var minLabel:FlxUIText;
    public var maxLabel:FlxUIText;
    public var valueLabel:FlxUIText;
    public var nameLabel:FlxUIText;

    private var __isBeingMoved:Bool = false;
    public var callback:Void->Void;

    public static inline var CHANGE_EVENT:String = "change_slider"; // change in any way

    public var step:Float = 0;
    public var decimals:Int = -1;

    public var usable:Bool = true;

    public var valueMultiplier:Float = 1;
    public var labelPrefix:String = '';
    public var labelSuffix:String = '';

    /**
        dangle
	*/
    public override function new(X:Float, Y:Float, Width:Int, Height:Int, Object:Dynamic, Variable:String, MinValue:Float, MaxValue:Float,
        LabelValueMultiplier:Float = 1, LabelPrefix:String = '', LabelSuffix:String = '', GradientBar:Bool = true, ?ColorEmpty:FlxColor, ?ColorFull:Array<FlxColor>) {
        super(X, Y);

        if (MinValue == MaxValue)
        {
            FlxG.log.error("FlxUISlider: MinValue and MaxValue can't be the same (" + MinValue + ")");
        }

        this.object = Object;
        this.variable = Variable;
        this.min = MinValue;
        this.max = MaxValue;
        this.valueMultiplier = LabelValueMultiplier;
        this.labelPrefix = LabelPrefix;
        this.labelSuffix = LabelSuffix;

        var btnSizeStr:Array<String> = FlxUIAssets.SLIDER_BUTTON.split(",");
        var btnSize:Array<Int> = [Std.parseInt(btnSizeStr[0]), Std.parseInt(btnSizeStr[1])];
        sliderSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(FlxUIAssets.IMG_SLIDER, 'shared'), true, btnSize[0], btnSize[1]);
        sliderSprite.animation.add('normal', [0]);
        sliderSprite.animation.add('hover', [1]);
        sliderSprite.animation.add('click', [2]);

        if (ColorEmpty == null)
            ColorEmpty = FlxColor.BLACK;
        if (ColorFull == null) {
            if (GradientBar)
                ColorFull = [FlxColor.RED, FlxColor.YELLOW, 0xFF00FF1E];
            else
                ColorFull = [0xFF00FF1E];
        }

        bar = new FlxBar(0, sliderSprite.y + sliderSprite.height, LEFT_TO_RIGHT, Width, Height, Object, Variable, MinValue, MaxValue);

        if (GradientBar)
            bar.createGradientBar([ColorEmpty], ColorFull, 1, 0, true, 0xFF000000);
        else
            bar.createFilledBar(ColorEmpty, ColorFull[0], true, FlxColor.BLACK);

        bar.y -= bar.height / 2;

        this.minLabel = new FlxUIText(bar.x, bar.y + bar.height + 5, 0, labelPrefix + Std.string(min * valueMultiplier) + labelSuffix);
        this.maxLabel = new FlxUIText(bar.x + bar.width, this.minLabel.y, 0, labelPrefix + Std.string(max * valueMultiplier) + labelSuffix);
        this.maxLabel.x -= this.maxLabel.width;
        this.valueLabel = new FlxUIText(bar.x, this.minLabel.y, 0, '');

        nameLabel = new FlxUIText(bar.x, 0, 0, Variable);
        nameLabel.y -= nameLabel.height;
        nameLabel.x += ((bar.width / 2) - (nameLabel.width / 2));

        add(this.minLabel);
        add(this.maxLabel);
        add(bar);
        add(sliderSprite);
        add(this.valueLabel);
        add(nameLabel);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (usable) {
            if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(sliderSprite, camera) || FlxG.mouse.overlaps(bar, camera))) {
                __isBeingMoved = true;
            } 
            
            if (__isBeingMoved) { 
                sliderSprite.animation.play('click');
            } else if (FlxG.mouse.overlaps(sliderSprite, camera)) {
                sliderSprite.animation.play('hover');
            } else {
                sliderSprite.animation.play('normal');
            }
    
            if (FlxG.mouse.justReleased) __isBeingMoved = false;
    
            if (__isBeingMoved) {
                var cursorX = FlxG.mouse.getScreenPosition(camera).x - bar.x;
    
                if (object != null && variable != null) {
                    if (step != 0)
                        Reflect.setProperty(object, variable, CoolUtil.boundTo(min + (Math.floor((max-min) / bar.width * cursorX / step) * step), min, max));
                    else
                        Reflect.setProperty(object, variable, CoolUtil.boundTo(min + ((max-min) / bar.width * cursorX), min, max));
                } else
                      trace("object is null");
            }
    
            if (object != null && variable != null) {
                value = Reflect.getProperty(object, variable);
                bar.value = Reflect.getProperty(object, variable);
            }
    
            sliderSprite.x = bar.x + ((bar.percent / 100) * bar.width) - (sliderSprite.width / 2);
    
            var valueDec:Float = bar.value;
            if (decimals > 0) valueDec = FlxMath.roundDecimal(valueDec, decimals);
            valueLabel.text = labelPrefix + Std.string(valueDec * valueMultiplier) + labelSuffix;
    
            this.valueLabel.x = bar.x + (bar.width / 2);
            this.valueLabel.x -= this.valueLabel.width / 2;
    
            nameLabel.x = bar.x;
            nameLabel.x += ((bar.width / 2) - (nameLabel.width / 2));
        } else {
            sliderSprite.animation.play('normal');
        }
    }

    public function onChanged() {
        if (callback != null)
            callback();

        FlxUI.event(CHANGE_EVENT, this, value, null);
    }
}