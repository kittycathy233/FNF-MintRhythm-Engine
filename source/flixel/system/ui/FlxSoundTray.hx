package flixel.system.ui;

import flixel.math.FlxMath;
#if FLX_SOUND_SYSTEM
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 220;
    
    /**
     * How tall the sound tray background is.
    **/
    var _height:Int = 30;

    var _barWidth:Float = 0;
    var curveSize:Int = 10;
    var _xPos:Int = 100;

	var _defaultScale:Float = 2.0;

    var volumeTxt:TextField;
    var moveToY:Float = 0;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

        _barWidth = _width - 20;

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
        var lineW:Float = _width;
        var lineX:Float = 0;
        var tmp:Bitmap = new Bitmap(new BitmapData(_width, 1, true, 0x7F000000));
        for (i in 0..._height) {
            if (i > _height - curveSize) {
                lineW -= 2;
                lineX += 1;
            }
            tmp = new Bitmap(new BitmapData(Math.floor(lineW), 1, true, 0x7F000000));
            tmp.y += i;
            tmp.x = lineX;
            //tmp.x += _width - lineW;
            addChild(tmp);
        }

        screenCenter();

		var text:TextField = new TextField();
		text.height = _height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#end

        volumeTxt = new TextField();
		volumeTxt.height = _height;
		volumeTxt.selectable = false;
        volumeTxt.width = _width;
        #if flash
		volumeTxt.embedFonts = true;
		volumeTxt.antiAliasType = AntiAliasType.NORMAL;
		volumeTxt.gridFitType = GridFitType.PIXEL;
		#end

		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 8, 0xffffff);
		dtf.align = TextFormatAlign.LEFT;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "Volume";
        text.x = 10;
		text.y = 0;

        dtf.align = TextFormatAlign.RIGHT;
        volumeTxt.defaultTextFormat = dtf;
		addChild(volumeTxt);
		volumeTxt.text = ""+FlxG.sound.volume;
        volumeTxt.x = -10;
		volumeTxt.y = 0;

		var bx:Float = 10;
		var by:Int = 12;
        var bh:Int = 10;
        var bw:Float = _barWidth / 100;
		_bars = new Array();

		for (i in 0...100)
		{
            tmp = new Bitmap(new BitmapData(Math.floor(bw), bh, false, FlxColor.BLACK));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);

			tmp = new Bitmap(new BitmapData(Math.floor(bw), bh, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += bw;
		}

		y = -height;
        moveToY = -height;
		visible = false;
	}

    var showing = false;
    var lastHeldVol:Float = -1;

	/**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate stupid sound tray thing
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else
		{
			moveToY = -height;
            showing = false;

			if (y <= -height)
			{
				visible = false;
				active = false;
			}
		}

        if (showing)
            y = FlxMath.lerp(y, moveToY, (MS / 1000) * 5);
        else
            y = FlxMath.lerp(y, moveToY, (MS / 1000) * 2);
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	Silent	Whether or not it should beep.
	 */
	public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			var sound = FlxAssets.getSound("flixel/sounds/beep");
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 3;
		moveToY = 0;
		visible = true;
		active = true;
        showing = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 100);

		if (FlxG.sound.muted)
			globalVolume = 0;

        var text = ""+globalVolume;
        if (globalVolume == 100) text = "MAX";
        else if (globalVolume == 0) text = "X";
        if (volumeTxt != null) volumeTxt.text = text;

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
				_bars[i].alpha = 1;
			else
			    _bars[i].alpha = 0;
		}

		// Save sound preferences
		FlxG.save.data.mute = FlxG.sound.muted;
		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.flush();
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
