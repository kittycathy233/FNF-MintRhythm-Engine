package flixel.system.ui;

import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import flash.display.Graphics;
import flash.display.Sprite;
import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.Assets;
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end

class FlxFocusLostScreen extends Sprite
{
    var text:TextField;

	@:keep
	public function new()
	{
		super();
		draw();

        text = new TextField();
        text.width = FlxG.stage.width;
		text.height = FlxG.stage.height;
		text.multiline = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#end
        var dtf:TextFormat = new TextFormat(getFont(Paths.font("vcr.ttf")), 20, 0xffffff);
		dtf.align = TextFormatAlign.LEFT;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "WAITING...";
        text.x = 10;
		text.y = 10;

		visible = false;
	}

    var timePerUpdate:Float = 0.03;
    var curTime:Float = 0;
    var framesDone:Int = 0;
    public function update(MS:Float) {
        var elapsed:Float = MS / 1000;

        curTime += elapsed;
        if (curTime > timePerUpdate && visible) {
            curTime = 0;
            framesDone++;

            A += 0.08;
            B += 0.03;

            updateScr(elapsed);
        }
    }

    public function getFont(Font:String):String
    {
        text.embedFonts = true;

        var newFontName:String = Font;

        if (Font != null)
        {
            if (Assets.exists(Font, AssetType.FONT))
            {
                newFontName = Assets.getFont(Font).fontName;
            }
        }
        return newFontName;
    }

	/**
	 * Redraws the big arrow on the focus lost screen.
	 */
	public function draw():Void
	{
		var gfx:Graphics = graphics;

		var screenWidth:Int = Std.int(FlxG.stage.stageWidth);
		var screenHeight:Int = Std.int(FlxG.stage.stageHeight);

		// Draw transparent black backdrop
		gfx.clear();
		gfx.moveTo(0, 0);
		gfx.beginFill(0, 0.5);
		gfx.drawRect(0, 0, screenWidth, screenHeight);
		gfx.endFill();

        if (text != null) {
            text.width = screenWidth;
            text.height = screenHeight;
        }

		this.x = -FlxG.scaleMode.offset.x;
		this.y = -FlxG.scaleMode.offset.y;
	}

    var A:Float = 1;
    var B:Float = 1;
    function updateScr(elapsed:Float) {
        // https://github.com/limiteci/donut.c/blob/main/donut.py but haxe
        var screen_height:Int = 35;
        var screen_width:Int = 35;
        var R1 = 1;
        var R2 = 2;
        var K2 = 5;
        var K1 = screen_width*K2*3/(8*(R1+R2));
        var theta_spacing = 0.07;
        var phi_spacing = 0.02;
        var cosA = Math.cos(A);
        var sinA = Math.sin(A);
        var cosB = Math.cos(B);
        var sinB = Math.sin(B);
        var char_output = [];
        var zbuffer:Array<Dynamic> = [];
        for (i in 0...screen_height) {
            var pushArray:Array<Dynamic> = [];
            var pushArray2:Array<Dynamic> = [];
            for (i in 0...screen_width) {
                pushArray.push(' ');
                pushArray2.push(0);
            }
            char_output.push(pushArray);
            zbuffer.push(pushArray2);
        }
        var theta:Float = 0;
        while (theta < 2* Math.PI) {
            theta += theta_spacing;
            var costheta = Math.cos(theta);
            var sintheta = Math.sin(theta);
            var phi:Float = 0;
            while (phi < 2*Math.PI) {
                phi += phi_spacing;
                var cosphi = Math.cos(phi);
                var sinphi = Math.sin(phi);
                var circlex = R2 + R1*costheta;
                var circley = R1*sintheta;
                var x = circlex*(cosB*cosphi + sinA*sinB*sinphi) - circley*cosA*sinB;
                var y = circlex*(sinB*cosphi - sinA*cosB*sinphi) + circley*cosA*cosB;
                var z = K2 + cosA*circlex*sinphi + circley*sinA;
                var ooz = 1/z;
                var xp = Std.int(screen_width/2 + K1*ooz*x);
                var yp = Std.int(screen_height/2 - K1*ooz*y);
                var L = cosphi*costheta*sinB - cosA*costheta*sinphi - sinA*sintheta + cosB*(cosA*sintheta - costheta*sinA*sinphi);
                if (L > 0) {
                    if (ooz > zbuffer[xp][yp]) {
                        zbuffer[xp][yp] = ooz;
                        var luminance_index:Int = Std.int(L*8);
                        char_output[xp][yp] = '.,-~:;=!*#$@'.split('')[luminance_index];
                    }
                }
            }
        }
        //trace('\x1b[H');
        var finalStr:String = "";
        for (i in 0...Std.int((screen_width / 2) - 5)) {
            finalStr += " ";
        }
        finalStr += "WAITING...\n";
        for (i in 0...screen_height) {
            for (j in 0...screen_width) {
                finalStr += char_output[i][j];
                //trace(char_output[i][j]);
            }
            finalStr += "\n";
        }

        if (text!=null) text.text = finalStr;
    }
}
