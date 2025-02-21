package;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;

using StringTools;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var transition:String = null;

	//2022
	public function new(duration:Float, isTransIn:Bool, transition:Null<String> = null) {
		super();

		this.transition = transition;
		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		
		var grdangle:Int = 90;
		var flipx:Bool = false;
		if (transition == null) this.transition = ClientPrefs.transition;
		var shit:Array<Int> = [width, height + 400];
		switch (this.transition) {
			case 'Horizontal Fade':
				grdangle = 180;
				flipx = true;
		}
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]), 1, grdangle);
		transGradient.scrollFactor.set();
		transGradient.flipX = flipx;

		transBlack = new FlxSprite().makeGraphic(shit[0] + 200, shit[1], FlxColor.BLACK);
		transBlack.scrollFactor.set();

		add(transGradient);
		add(transBlack);

		switch (this.transition) {
			default:
				transGradient.y -= (shit[0] - FlxG.width) / 2;
				transBlack.y = transGradient.y;
				
				if(isTransIn) {
					transGradient.y = transBlack.y - transBlack.height;
					FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {onComplete: mf2, ease: FlxEase.linear});
				} else {
					transGradient.y = -transGradient.height;
					transBlack.y = transGradient.y - transBlack.height + 50;
					leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				}
			case 'Horizontal Fade':
				transGradient.x -= (shit[0] - FlxG.width);
				transBlack.x = transGradient.x;
				
				if(isTransIn) {
					transGradient.x = transBlack.x - transBlack.width;
					FlxTween.tween(transGradient, {x: transGradient.width + 50}, duration, {onComplete: mf2, ease: FlxEase.linear});
				} else {
					transGradient.x = -transGradient.width;
					transBlack.x = transGradient.x - transBlack.width;
					leTween = FlxTween.tween(transGradient, {x: transGradient.width + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				}
		}

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transGradient.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	function mf(_) {
		if(finishCallback != null) {
			finishCallback();
		}
	}

	function mf2(_) {
		close();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		switch (transition) {
			default:
				if(isTransIn) {
					transBlack.y = transGradient.y + transGradient.height;
				} else {
					transBlack.y = transGradient.y - transBlack.height;
				}
			case 'Horizontal Fade':
				if(isTransIn) {
					transBlack.x = transGradient.x + transGradient.width;
				} else {
					transBlack.x = transGradient.x - transBlack.width;
				}
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}