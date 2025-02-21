package misc;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

typedef SubProperties = {
	var deletePrevious:Bool;
	var fadeOut:Bool;
	var fadeIn:Bool;
	var subText:String;
	var typeIn:Bool;
	var typeOut:Bool;
	var italic:Bool;
	var bold:Bool;

	var font:String;
	var size:Int;
	var border:Bool;
	var alignment:String;
	var length:String;
	var colorArray:Array<Int>;

	var time:Float;

	var yInEditor:Float;
}

/**
Heavily modified class of https://github.com/EyeDaleHim/FNF-Mechanics/blob/main/source/SubtitleHandler.hx
all credit goes to EyeDaleHim#8508
**/
class SubtitleHandler
{
	public static var camera = null;
	public static var list:Array<Subtitle> = [];

	public static function makeline(properties:SubProperties)
	{
		if (camera == null)
		{
			camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}

		var subSprite:Subtitle = new Subtitle(properties);
		subSprite.subBG.screenCenter();
		subSprite.subText.screenCenter();
		switch(properties.alignment) {
			case "LEFT": 
				subSprite.subBG.x = 96;
				subSprite.subText.x = 100;
			case "RIGHT": 
				subSprite.subBG.x = FlxG.width - 96;
				subSprite.subText.x = FlxG.width - 100;
			case "CENTER":
				subSprite.subBG.screenCenter();
				subSprite.subText.screenCenter();
		}

		subSprite.subBG.y = subSprite.subText.y = FlxG.height * 0.85;
		list.unshift(subSprite);

		for (sub in list)
		{
			sub.ID = list.indexOf(sub);

			if (sub != null)
			{
				if (sub.ID != 0)
				{
					sub.subBG.y = list[sub.ID - 1].subBG.y - sub.subBG.height;
					sub.subText.y = list[sub.ID - 1].subText.y - (sub.subBG.height - 4);
					if (subSprite.deletePrev) {
						sub.onKill();
					}
				}
			}
		}

		FlxG.state.add(subSprite);
	}

	public static function basic(text:String, length:String) {
		makeline({
			typeOut: false,
			typeIn: false,
			subText: text,
			size: 16,
			length: Std.string(length),
			time: 0,
			italic: false,
			bold: false,
			deletePrevious: false,
			colorArray: [0,0,0],
			border: true,
			alignment: "CENTER",
			font: "vcr.ttf",
			fadeOut: false,
			fadeIn: false,

			yInEditor: 0
		});
	}

	// Called if the state is destroyed
	public static function destroy(cameraMakeNull:Bool = true)
	{
		if (cameraMakeNull) camera = null;
		FlxDestroyUtil.destroyArray(list);
		list = [];
	}

	public static function boolFromString(string:String):Bool {
		return string == "true" ? true : false;
	}
}

class Subtitle extends FlxTypedGroup<FlxSprite>
{
	public var aliveTime:Float = 0;
	public var killTime:Float = 5.0;

	public var subBG:FlxSprite;
	public var subText:FlxText;

	public var lerpFrom:Float = FlxG.height * 0.85;

	public var typedIn:Bool = false;
	public var typedOut:Bool = false;
	public var fadeIn:Bool = false;
	public var fadeOut:Bool = false;
	public var deletePrev:Bool = false;
	public var textToType:String = "";

	private var typeCharIndex:Int = 0;
	private var charArray:Array<String> = [];
	private var typeTmr:Float = 0;

	private var typeOutTmr:Float = 0;

	override public function new(value1:SubProperties)
	{
		super();

		var time:Float = Std.parseFloat(value1.length) / 1000;
		var text:String = value1.subText;
		var size:Int = value1.size;
		var border:Bool = value1.border;
		var alignment:String = value1.alignment;
		var font:String = value1.font;

		textToType = text;
		deletePrev = value1.deletePrevious;
		fadeOut = value1.fadeOut;
		fadeIn = value1.fadeIn;
		typedOut = value1.typeOut;
		typedIn = value1.typeIn;

		killTime = time;

		if (typedIn) {
			typeCharIndex = 0;
			charArray = textToType.split('');
			text = '';
		}

		subText = new FlxText(0, lerpFrom + 4, 0, text, size);
		subText.setFormat(Paths.font(font), size);
		if (border) subText.setFormat(Paths.font(font), size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subText.cameras = [SubtitleHandler.camera];
		switch(alignment) {
			case "LEFT": subText.alignment = LEFT;
			case "RIGHT": subText.alignment = RIGHT;
			case "CENTER": subText.alignment = CENTER;
		}

		if (!typedIn) {
			var colorFormat:FlxTextFormat = new FlxTextFormat(FlxColor.fromRGB(
				value1.colorArray[0],
				value1.colorArray[1], 
				value1.colorArray[2]),
				value1.bold, 
				value1.italic, 
				FlxColor.BLACK);

			var red:FlxTextFormat = new FlxTextFormat(
				FlxColor.RED,
				value1.bold,
				value1.italic,
				FlxColor.BLACK);

			var green:FlxTextFormat = new FlxTextFormat(
				FlxColor.GREEN,
				value1.bold,
				value1.italic,
				FlxColor.BLACK);
		
			var blue:FlxTextFormat = new FlxTextFormat(
				FlxColor.BLUE,
				value1.bold,
				value1.italic,
				FlxColor.BLACK);

			subText.applyMarkup(text, [
				new FlxTextFormatMarkerPair(colorFormat, '<c>'),
				new FlxTextFormatMarkerPair(red, '<r>'),
				new FlxTextFormatMarkerPair(green, '<g>'),
				new FlxTextFormatMarkerPair(blue, '<b>')
			]);
		}

		subBG = new FlxSprite(0, lerpFrom).makeGraphic(Math.floor(subText.width + 8), Math.floor(subText.height + 8), FlxColor.BLACK);
		subBG.alpha = 0.6;
		subBG.cameras = [SubtitleHandler.camera];

		if (fadeIn) {
			subText.alpha = 0.0001;
			subBG.alpha = 0.0001;
		}

		add(subBG);
		add(subText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		aliveTime += elapsed;

		if (typedIn && subText.text != textToType && typeTmr > 0.1) {
			typeTmr = 0;
			subText.text += charArray[typeCharIndex];
			typeCharIndex++;
		}
		typeTmr += elapsed;

		if (aliveTime >= killTime)
		{
			if (fadeOut) {
				subText.alpha -= elapsed;
				subBG.alpha = subText.alpha * 0.6;
			} else if (!typedOut) {
				onKill();
			}
			if (typedOut) {
				if (subText.text.length > 0 && typeOutTmr > 0.1) {
					typeOutTmr = 0;
					subText.text = subText.text.substring(0, subText.text.length - 1);
				}
				typeOutTmr += elapsed;
			}
		} else
		{
			if (subText.alpha <= 1 && fadeIn) {
				subText.alpha += elapsed;
				subBG.alpha = subText.alpha * 0.6;
			}
		}

		if ((subText.alpha <= 0) || (subText.text.length < 1 && typedOut))
		{
			onKill();
		}
	}

	public function onKill() {
		FlxTween.cancelTweensOf(subText);
		FlxTween.cancelTweensOf(subBG);
		
		destroy();

		FlxDestroyUtil.destroy(subText);
		FlxDestroyUtil.destroy(subBG);

		SubtitleHandler.list.remove(this);
	}
}
