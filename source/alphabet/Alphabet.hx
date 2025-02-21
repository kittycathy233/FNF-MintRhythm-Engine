package alphabet;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

using StringTools;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

enum Scroll
{
	D_SHARP;
	D;
	C_SHARP;
	C;
	DEFAULT_LEFT;
	DEFAULT_RIGHT;
	ONLY_ONE;
}

class Alphabet extends FlxSpriteGroup
{
	public var text(default, set):String;

	public var bold:Bool = false;
	public var letters:Array<AlphaCharacter> = [];

	public var scroll:Scroll = DEFAULT_LEFT;

	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var autoAlpha:Bool = false;

	public var whiteText:Bool = false;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;

	public var startedAs:String = "";

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;
		this.text = text;
	}

	public function setAlignmentFromString(align:String)
	{
		switch(align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(align:Alignment)
	{
		alignment = align;
		updateAlignment();
		return align;
	}

	private function updateAlignment()
	{
		for (letter in letters)
		{
			var newOffset:Float = 0;
			switch(alignment)
			{
				case CENTERED:
						newOffset = letter.rowWidth / 2;
				case RIGHT:
						newOffset = letter.rowWidth;
				default:
					newOffset = 0;
			}

			letter.offset.x -= letter.alignOffset;
			letter.offset.x += newOffset;
			letter.alignOffset = newOffset;
		}
	}

	private function set_text(newText:String)
	{
		newText = newText.replace('\\n', '\n');
		clearLetters();
		createLetters(newText);
		updateAlignment();
		this.text = newText;
		return newText;
	}

	public function clearLetters()
	{
		var i:Int = letters.length;
		while (i > 0)
		{
			--i;
			var letter:AlphaCharacter = letters[i];
			if(letter != null)
			{
				letter.kill();
				letters.remove(letter);
				letter.destroy();
			}
		}
		letters = [];
		rows = 0;
	}

	private function set_scaleX(value:Float)
	{
		if (value == scaleX) return value;

		scale.x = value;
		for (letter in letters)
		{
			if(letter != null)
			{
				letter.updateHitbox();
				//letter.updateLetterOffset();
				var ratio:Float = (value / letter.spawnScale.x);
				letter.x = letter.spawnPos.x * ratio;
			}
		}
		scaleX = value;
		return value;
	}

	private function set_scaleY(value:Float)
	{
		if (value == scaleY) return value;

		scale.y = value;
		for (letter in letters)
		{
			if(letter != null)
			{
				letter.updateHitbox();
				letter.updateLetterOffset();
				var ratio:Float = (value / letter.spawnScale.y);
				letter.y = letter.spawnPos.y * ratio;
			}
		}
		scaleY = value;
		return value;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			if(changeX) {
				var wuh:Int = (targetY > 0 ? -70 : 70);
				switch (scroll) {
					case D_SHARP:
						x = FlxMath.lerp(x, (wuh * targetY) + distancePerItem.x + startPosition.x, lerpVal);
					case D:
						x = FlxMath.lerp(x, (wuh * FlxMath.lerp(targetY, 0, elapsed) * 1.2) + distancePerItem.x + startPosition.x, lerpVal);
					case ONLY_ONE:
						var goTo:Float = distancePerItem.x + startPosition.x;
						goTo = targetY > 0 ? FlxG.width * 2 : targetY < 0 ? -FlxG.width * 2 : goTo;
						x = FlxMath.lerp(x, goTo, lerpVal);
					case C_SHARP:
						x = FlxMath.lerp(x, (FlxG.width - (wuh * targetY) - distancePerItem.x - startPosition.x - width), lerpVal);
					case C:
						x = FlxMath.lerp(x, (FlxG.width - (wuh * FlxMath.lerp(targetY, 0, elapsed) * 1.2) - distancePerItem.x - startPosition.x - width), lerpVal);
					case DEFAULT_LEFT:
						x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
					case DEFAULT_RIGHT:
						x = FlxMath.lerp(x, (FlxG.width - (targetY * distancePerItem.x) - startPosition.x - width), lerpVal);
					default:
				}
			}
			if(changeY && (scroll != ONLY_ONE))
				y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
			else if (changeY) y =  distancePerItem.y + startPosition.y;

			if (autoAlpha)
				alpha = FlxMath.lerp(alpha, (targetY == 0 ? 1 : 0.6), lerpVal * 0.65);
		}

		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if(changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if(changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	private static var Y_PER_ROW:Float = 85;
	public var maxNormalWidthPerLine(default,set):Float = 832;
	function set_maxNormalWidthPerLine(v:Float):Float {
		text = text;
		return v;
	}

	private function createLetters(newText:String)
	{
		var consecutiveSpaces:Int = 0;

		var xPos:Float = 0;
		var rowData:Array<Float> = [];
		rows = 0;

		for (character in newText.split(''))
		{
			
			if(character != '\n')
			{
				var spaceChar:Bool = (character == " " || (bold && character == "_"));
				if (spaceChar) consecutiveSpaces++;

				var isAlphabet:Bool = CoolUtil.isTypeAlphabet(character.toLowerCase());
				if (AlphaCharacter.allLetters.exists(character.toLowerCase()) && (!bold || !spaceChar))
				{
					if (consecutiveSpaces > 0)
					{
						xPos += 28 * consecutiveSpaces * scaleX;
						if(!bold && xPos >= maxNormalWidthPerLine)
						{
							xPos = 0;
							rows++;
						}
					}
					consecutiveSpaces = 0;

					var letter:AlphaCharacter = new AlphaCharacter(xPos, rows * Y_PER_ROW * scaleY, character, bold, this);
					letter.x += letter.letterOffset[0] * scaleX;
					letter.y -= letter.letterOffset[1] * scaleY;
					letter.row = rows;

					var off:Float = 0;
					if(!bold) off = 2;
					xPos += letter.width + (letter.letterOffset[0] + off) * scaleX;
					rowData[rows] = xPos;

					var letterColor:FlxColor = FlxColor.WHITE;

					if (whiteText && !bold) {
						letter.updateLetterColor(FlxColor.WHITE);
					}

					add(letter);
					letters.push(letter);
				}
			}
			else
			{
				xPos = 0;
				rows++;
			}
		}

		for (letter in letters)
		{
			letter.spawnPos.set(letter.x, letter.y);
			letter.spawnScale.set(scaleX, scaleY);
			letter.rowWidth = rowData[letter.row];
		}

		if(letters.length > 0) rows++;
	}
}


///////////////////////////////////////////
// ALPHABET LETTERS, SYMBOLS AND NUMBERS //
///////////////////////////////////////////

/*enum LetterType
{
	ALPHABET;
	NUMBER_OR_SYMBOL;
}*/

typedef Letter = {
	?anim:Null<String>,
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
	//public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	//public static var numbers:String = "1234567890";
	//public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var image(default, set):String;

	public static var allLetters:Map<String, Null<Letter>> = [
		//alphabet
		'a'  => null, 'b'  => null, 'c'  => null, 'd'  => null, 'e'  => null, 'f'  => null,
		'g'  => null, 'h'  => null, 'i'  => null, 'j'  => null, 'k'  => null, 'l'  => null,
		'm'  => null, 'n'  => null, 'o'  => null, 'p'  => null, 'q'  => null, 'r'  => null,
		's'  => null, 't'  => null, 'u'  => null, 'v'  => null, 'w'  => null, 'x'  => null,
		'y'  => null, 'z'  => null,
		
		//special
		'á'  => {offsetsBold: [0, 36]},
		'é'  => {offsetsBold: [0, 34]},
		'í'  => {offsetsBold: [0, 35]},
		'ó'  => {offsetsBold: [0, 36]},
		'ú'  => {offsetsBold: [0, 32]},
		'ñ'  => {offsetsBold: [0, 27]},
		'ï'  => {offsetsBold: [0, 23]},
		'õ'  => {offsetsBold: [0, 30]},
		'ü'  => {offsetsBold: [0, 20]},
		'ê'  => {offsetsBold: [0, 35]},
		'ç'  => {offsetsBold: [0, 5], offsets: [0, 20]},
		'ã'  => {offsetsBold: [0, 28]},
		'â'  => {offsetsBold: [0, 28]},
		'ô'  => {offsetsBold: [0, 35]},
		
		//numbers
		'0'  => null, '1'  => null, '2'  => null, '3'  => null, '4'  => null,
		'5'  => null, '6'  => null, '7'  => null, '8'  => null, '9'  => null,

		//symbols
		'&'  => {offsetsBold: [0, 2]},
		'('  => {offsetsBold: [0, 5]},
		')'  => {offsetsBold: [0, 5]},
		'*'  => {offsets: [0, 28]},
		'+'  => {offsets: [0, 7], offsetsBold: [0, -12]},
		'-'  => {offsets: [0, 16], offsetsBold: [0, -30]},
		'<'  => {offsetsBold: [0, 4]},
		'>'  => {offsetsBold: [0, 4]},
		'\'' => {anim: 'apostrophe', offsets: [0, 32]},
		'"'  => {anim: 'quote', offsets: [0, 32], offsetsBold: [0, 0]},
		'!'  => {anim: 'exclamation', offsetsBold: [0, 10]},
		'?'  => {anim: 'question', offsetsBold: [0, 4]},			//also used for "unknown"
		'¡'  => {anim: 'reverse exclamation', offsetsBold: [0, 16]},
		'¿'  => {anim: 'reverse question', offsetsBold: [0, 13]},			//also used for "unknown"
		'.'  => {anim: 'period', offsetsBold: [0, -44]},
		'❝'  => {anim: 'start quote', offsets: [0, 24], offsetsBold: [0, -5]},
		'❞'  => {anim: 'end quote', offsets: [0, 24], offsetsBold: [0, -5]},

		//symbols with no bold
		'_'  => null,
		'#'  => null,
		'$'  => null,
		'%'  => null,
		':'  => {offsets: [0, 2]},
		';'  => {offsets: [0, -2]},
		'@'  => null,
		'['  => null,
		']'  => {offsets: [0, -1]},
		'^'  => {offsets: [0, 28]},
		','  => {anim: 'comma', offsets: [0, -6]},
		'\\' => {anim: 'back slash', offsets: [0, 0]},
		'/'  => {anim: 'forward slash', offsets: [0, 0]},
		'|'  => null,
		'~'  => {offsets: [0, 16]},
		'ª'  => {offsets: [0, 30]},
		'º'  => {offsets: [0, 30]}
	];

	var parent:Alphabet;
	public var alignOffset:Float = 0; //Don't change this
	public var letterOffset:Array<Float> = [0, 0];
	public var spawnPos:FlxPoint = new FlxPoint();
	public var spawnScale:FlxPoint = new FlxPoint();

	public var row:Int = 0;
	public var rowWidth:Float = 0;
	public var letterColor:FlxColor;
	public function new(x:Float, y:Float, character:String, bold:Bool, parent:Alphabet)
	{
		super(x, y);
		this.parent = parent;
		image = 'alphabet';
		antialiasing = ClientPrefs.globalAntialiasing;

		var curLetter:Letter = allLetters.get('?');
		var lowercase = character.toLowerCase();
		if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);

		var suffix:String = '';
		if(!bold)
		{
			if(CoolUtil.isTypeAlphabet(lowercase))
			{
				if(lowercase != character)
					suffix = ' uppercase';
				else
					suffix = ' lowercase';
			}
			else
			{
				suffix = ' normal';
				if(curLetter != null && curLetter.offsets != null)
				{
					letterOffset[0] = curLetter.offsets[0];
					letterOffset[1] = curLetter.offsets[1];
				}
			}
		}
		else
		{
			suffix = ' bold';
			if(curLetter != null && curLetter.offsetsBold != null)
			{
				letterOffset[0] = curLetter.offsetsBold[0];
				letterOffset[1] = curLetter.offsetsBold[1];
			}
		}

		var alphaAnim:String = lowercase;
		if(curLetter != null && curLetter.anim != null) alphaAnim = curLetter.anim;

		var anim:String = alphaAnim + suffix;
		animation.addByPrefix(anim, anim, 24);
		animation.play(anim, true);
		if(animation.curAnim == null)
		{
			if(suffix != ' bold') suffix = ' normal';
			anim = 'question' + suffix;
			animation.addByPrefix(anim, anim, 24);
			animation.play(anim, true);
		}

		updateHitbox();
		updateLetterOffset();
	}

	private function set_image(name:String)
	{
		var lastAnim:String = null;
		if (animation != null)
		{
			lastAnim = animation.name;
		}
		image = name;
		frames = Paths.getSparrowAtlas(name);
		this.scale.x = parent.scaleX;
		this.scale.y = parent.scaleY;
		alignOffset = 0;
		
		if (lastAnim != null)
		{
			animation.addByPrefix(lastAnim, lastAnim, 24);
			animation.play(lastAnim, true);
			
			updateHitbox();
			updateLetterOffset();
		}
		return name;
	}

	public function updateLetterOffset()
	{
		if (animation.curAnim == null) return;

		if(!animation.curAnim.name.endsWith('bold'))
		{
			offset.y += -(110 - height);
		}
	}

	public function updateLetterColor(color:FlxColor) {
		letterColor = color;
			
		colorTransform.redMultiplier = 0;
		colorTransform.greenMultiplier = 0;
		colorTransform.blueMultiplier = 0;

		colorTransform.redOffset = letterColor.red;
		colorTransform.greenOffset = letterColor.green;
		colorTransform.blueOffset = letterColor.blue;

		color = letterColor;
	}
}

class OutlineShaders extends FlxShader {
	@:glFragmentSource('#pragma header
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	float diff = 7;
    int step = 3;

	float motherfuckingAbs(float v) {
        if (v < 0)
            return -v;
        return v;
    }

	void main()
	{
		vec2 position = vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y)
		position -= 10;

		vec4 color = flixel_texture2D(bitmap, position);
        float a = 0;
        for(int x = -int(diff); x < int(diff); x += step) {
            for(int y = -int(diff); y < int(diff); y += step) {
                vec2 offset = vec2(x / openfl_TextureSize.x, y / openfl_TextureSize.y);
                float angle = atan(offset.y, offset.x);
                offset = vec2(cos(angle) * (motherfuckingAbs(x) / openfl_TextureSize.x), sin(angle) * (motherfuckingAbs(y) / openfl_TextureSize.y));

                vec4 c1 = flixel_texture2D(bitmap, position + offset);
                if (a < c1.a) a = c1.a;
            }
        }

		gl_FragColor = vec4(1, 0, 0, flixel_texture2D(bitmap, uv).a);
	}')
}