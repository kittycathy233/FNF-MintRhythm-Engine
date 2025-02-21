package editors.charter;

import haxe.Json;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.display.BitmapData;
import mods.ModManager;
import haxe.io.Path;
import flixel.math.FlxMath;
import openfl.utils.Assets;
import flixel.*;
import flixel.addons.ui.*;
import flixel.group.FlxSpriteGroup;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

/**
 * yce change char with psych support
**/
class ChangeCharacter extends MusicBeatSubstate {
    // dpmt modify !!!
    public var modsScroll:FlxSpriteGroup;
    public var charsScroll:FlxSpriteGroup;
    public var modsScrollY:Float = 0;
    public var charsScrollY:Float = 0;

    public var callback:String->String->Void;

    var fnf:String = 'Friday Night Funkin\'';
    var modFolder:String = 'mods';

    public function new(callback:String->String->Void) {
        super();
        this.callback = callback;
    }

    public override function create() {
        super.create();
        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        bg.scrollFactor.set(0, 0);
        add(bg);
        modsScroll = new FlxSpriteGroup(0, 0);
        
        var i:Int = 0;
        var daMods:Array<String> = #if MODS_ALLOWED ModManager.getMods(); #else []; #end
        daMods.push(fnf);
        #if MODS_ALLOWED
        daMods.push(modFolder);
        #end

        for(mod in daMods) {
            i++;
            var modLabel:String = "";
            #if MODS_ALLOWED if (mod != fnf) modLabel = ModManager.getPackOf(mod).name;
            else #end modLabel = fnf;

            var modFolder:String = "";
            if (mod != fnf) modFolder = ' ($mod)';

            var button = new FlxUIButton((FlxG.width / 2) - 300, 0 + (i * 50), modLabel + modFolder, function() {
                changeSecondMenu(mod);
            });
            button.label.alignment = LEFT;
            button.label.offset.x = -50;
            button.resize(300, 50);

            var loadedIcon:BitmapData = null;

            var buttonIcon = new FlxSprite(button.x + 5, button.y + 5).loadGraphic(Paths.image('unknownMod', 'preload'));
            #if MODS_ALLOWED if (mod != fnf) {
                var iconToUse:String = ModManager.getModIconPath(mod);
                if(FileSystem.exists(iconToUse))
                {
                    loadedIcon = BitmapData.fromFile(iconToUse);
                }
    
                if (loadedIcon != null) {
                    buttonIcon.loadGraphic(loadedIcon, true, 150, 150);//animated icon support
                    var totalFrames = Math.floor(loadedIcon.width / 150) * Math.floor(loadedIcon.height / 150);
                    buttonIcon.animation.add("icon", [for (i in 0...totalFrames) i],10);
                    buttonIcon.animation.play("icon");
                }
            } else #end
                buttonIcon.loadGraphic(Paths.image('fnf', 'preload'));
            
            buttonIcon.setGraphicSize(40, 40);
            buttonIcon.updateHitbox();
            buttonIcon.scale.set(Math.min(buttonIcon.scale.x, buttonIcon.scale.y), Math.min(buttonIcon.scale.x, buttonIcon.scale.y));
            var markThing = new FlxSprite(button.x + 273, button.y + 18).loadGraphic(FlxUIAssets.IMG_DROPDOWN);
            markThing.angle -= 90;
            modsScroll.add(button);
            modsScroll.add(markThing);
            modsScroll.add(buttonIcon);
        }
        modsScroll.scrollFactor.set();
        add(modsScroll);
        charsScroll = new FlxSpriteGroup(0, 0);
        charsScroll.scrollFactor.set();
        add(charsScroll);
        changeSecondMenu(fnf);

        var closeButton = new FlxUIButton(FlxG.width - 30, 5, "X", function() {
            close();
        });
        closeButton.label.size = Std.int(closeButton.label.size * 1.5);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.color = 0xFFFF4444;
        closeButton.resize(25, 25);
        closeButton.scrollFactor.set();
        add(closeButton);
    }

    public function changeSecondMenu(mod:String) {
        for(m in charsScroll.members) {
            if (m == null) continue;
            m.destroy();
            charsScroll.remove(m);
            remove(m);
        }

        #if MODS_ALLOWED
        if (mod != fnf && mod != modFolder) Paths.currentModDirectory = mod;
        else if (mod == modFolder) Paths.currentModDirectory = "";
        
        var pathToModChars:String = "characters/";
        var path:String = "";
        if (mod != modFolder)
            path = Paths.mods(mod + '/' + pathToModChars);
        else
            path = Paths.mods(pathToModChars);

		if (!FileSystem.exists(path)) {
			path = Paths.getPreloadPath(pathToModChars);
		}
        var characters:Array<String> = FileSystem.readDirectory(path);
        #else
        var path:String = Paths.getPreloadPath('characters/');
        var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
        #end

        var i:Int = 0;
        for(char in characters) {
            if (char.endsWith('.json')) {
                i++;

                var charName:String = char.replace('.json', '');

                var button = new FlxUIButton(Std.int(FlxG.width / 2), 0 + ((i + 1) * 50), charName, function() {
                    close();
                    if (callback != null) callback(mod, charName);
                });
                button.label.alignment = LEFT;
                button.label.offset.x = -50;
                button.resize(300, 50);

                var pathToCharFile:String = path + char;
                #if MODS_ALLOWED var rawJson = File.getContent(pathToCharFile);
                #else var rawJson = OpenFlAssets.getText(pathToCharFile); #end
                var json:Character.CharacterFile = cast Json.parse(rawJson);
                var healthIconPath:String = json.healthicon;

                var healthIcon:HealthIcon = new HealthIcon(healthIconPath);
                healthIcon.setGraphicSize(40, 40);
                healthIcon.updateHitbox();
                healthIcon.x = button.x - 50;
                healthIcon.y = button.y - 50;

                charsScroll.add(button);
                charsScroll.add(healthIcon);
            }
        }
        trace(mod);
        charsScroll.y = 0;
        charsScrollY = 0;
    }

    public override function update(elapsed:Float) {
        if (FlxG.mouse.overlaps(modsScroll)) {
            var maxY = -Math.max(modsScroll.height + 100 - FlxG.height, 0);
            modsScrollY += 50 * FlxG.mouse.wheel * 1.5;
            if (modsScrollY < maxY) modsScrollY = maxY;
            else if (modsScrollY > 0) modsScrollY = 0;
        }
        if (FlxG.mouse.overlaps(charsScroll)) {
            var maxY = -Math.max(charsScroll.height + 100 - FlxG.height, 0);
            charsScrollY += 50 * FlxG.mouse.wheel * 1.5;
            if (charsScrollY < maxY) charsScrollY = maxY;
            else if (charsScrollY > 0) charsScrollY = 0;
        }
        modsScroll.y = FlxMath.lerp(modsScroll.y, modsScrollY, FlxMath.bound(elapsed * 0.25 * 60, 0, 1));
        charsScroll.y = FlxMath.lerp(charsScroll.y, charsScrollY, FlxMath.bound(elapsed * 0.25 * 60, 0, 1));
        super.update(elapsed);
    }
}