package alphabet;

import flixel.FlxSprite;

class AttachedOptionText extends Alphabet {
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;
	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?bold = false, ?scale:Float = 1, widthPerLine:Float = 0) {
		super(0, 0, text, bold);
		this.whiteText = true;

		this.scaleX = scale;
		this.scaleY = scale;
		this.isMenuItem = false;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.maxNormalWidthPerLine = widthPerLine;
		this.text = text;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + sprTracker.height + offsetY);
			if(copyVisible) {
				visible = sprTracker.visible;
			}
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}

		super.update(elapsed);
	}
}