package mods;

import background.PropertyFlxSprite.PropertySprite;
import song.Section;
import song.Section.SwagSection;
import flixel.util.FlxSort;
import song.Song;
import flixel.group.FlxSpriteGroup;
import background.BGSprite;
import hscript.Expr;
import haxe.Exception;
import scripting.Script;
import flixel.math.FlxMath;
import openfl.utils.Assets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import vlc.MP4Handler;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import lime.app.Application;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.tile.FlxTilemap;
import animateatlas.AtlasFrameMaker;
import openfl.display.BlendMode;
import scripting.Script.HScript;
import achievements.Achievements;
import haxe.Json;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef Mod = {
    var name:String;
    var description:String;
}

typedef Award = {
    var name:String;
    var description:String;
    var hidden:Bool;
}

class ModManager {
    public static var loadedMods:Map<String, Mod> = new Map<String, Mod>();

    public static function getMods():Array<String> {
        #if MODS_ALLOWED
        return Paths.getModDirectories();
        #else
        return [];
        #end
    }
    
    public static function getPackOf(mod:String):Mod {
        #if MODS_ALLOWED
        var path = Paths.mods(mod + '/pack.json');
		if(FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if(rawJson != null && rawJson.length > 0) {
				var stuff:Mod = Json.parse(rawJson);
                if (!loadedMods.exists(mod)) {
                    loadedMods.set(mod, stuff);
                }
            }
        }
        if (loadedMods.exists(mod)) {
            return loadedMods.get(mod);
        }
        #end
        return {
            name: null,
            description: null
        };
    }

    public static function getModIconPath(mod:String):String {
        #if MODS_ALLOWED
        return Paths.mods(mod + '/pack.png');
        #else
        return Paths.getPreloadPath('images/fnf.png');
        #end
    }

    public static function loadModAchievements() {
        #if MODS_ALLOWED
        for (mod in Paths.getGlobalMods()) {
            var thisModAchievements:Array<Dynamic> = [];
            for (achieve in FileSystem.readDirectory(Paths.modsAchievements(mod))) {

                if (achieve.endsWith('.json')) {

                    var path = Paths.modsAchievements(mod, achieve);
                    if(FileSystem.exists(path)) {
                        var rawJson:String = File.getContent(path);
                        if(rawJson != null && rawJson.length > 0) {
                            var achievement:Award = Json.parse(rawJson);
                            thisModAchievements.push([
                                achievement.name, 
                                achievement.description, 
                                achieve.replace('.json', ''), 
                                achievement.hidden,
                                mod
                            ]);
                        }
                    }
                }
            }

            Achievements.modAchievements.set(mod, thisModAchievements);
        }
        #end
    }

    //Hscript stuff from yce
	public static function getExpressionFromPath(path:String, critical:Bool = false):hscript.Expr {
        var ast:Expr = null;
        try {
			var cachePath = path.toLowerCase();
			var fileData = FileSystem.stat(path);
            var content = sys.io.File.getContent(path);
            ast = getExpressionFromString(content, critical, path);
        } catch(ex) {
            if (!openfl.Lib.application.window.fullscreen && critical) openfl.Lib.application.window.alert('Could not read the file at "$path".');
            trace('Could not read the file at "$path".');
        }
        return ast;
    }
    public static function getExpressionFromString(code:String, critical:Bool = false, ?path:String):hscript.Expr {
        if (code == null) return null;
        var parser = new hscript.Parser();
		parser.allowTypes = true;
        var ast:Expr = null;
		try {
			ast = parser.parseString(code);
		} catch(ex) {
			trace(ex);
            var exThingy = Std.string(ex);
            var line = parser.line;
            if (path != null) {
                if (!openfl.Lib.application.window.fullscreen && critical) openfl.Lib.application.window.alert('Failed to parse the file located at "$path".\r\n$exThingy at $line');
                trace('Failed to parse the file located at "$path".\r\n$exThingy at $line');
            } else {
                if (!openfl.Lib.application.window.fullscreen && critical) openfl.Lib.application.window.alert('Failed to parse the given code.\r\n$exThingy at $line');
                trace('Failed to parse the given code.\r\n$exThingy at $line');
                if (!critical) throw new Exception('Failed to parse the given code.\r\n$exThingy at $line');
            }
		}
        return ast;
    }

    public static var hscriptExts:Array<String> = ["hx", "hscript", "hsc"];

	public static function setScriptDefaultVars(script:Script) {
        var superVar = {};
        if (Std.isOfType(script, HScript)) {
            var hscript:HScript = cast script;
            for(k=>v in hscript.hscript.variables) {
                Reflect.setField(superVar, k, v);
            }
        }
		script.setVariable("this", script);
		script.setVariable("super", superVar);
		script.setVariable("PlayState", PlayState.instance);
        script.setVariable("import", function(className:String) {
            var splitClassName = [for (e in className.split(".")) e.trim()];
            var realClassName = splitClassName.join(".");
            var cl = Type.resolveClass(realClassName);
            var en = Type.resolveEnum(realClassName);
            if (cl == null && en == null) {
                FlxG.log.error('Class / Enum at $realClassName does not exist.');
            } else {
                if (en != null) {
                    // ENUM!!!!
                    var enumThingy = {};
                    for(c in en.getConstructors()) {
                        Reflect.setField(enumThingy, c, en.createByName(c));
                    }
                    script.setVariable(splitClassName[splitClassName.length - 1], enumThingy);
                } else {
                    // CLASS!!!!
                    script.setVariable(splitClassName[splitClassName.length - 1], cl);
                }
            }
        });
        script.setVariable("importAlt", function(libName:String, ?libPackage:String = '') {
            var str:String = '';
            if(libPackage.length > 0)
                str = libPackage + '.';

            script.setVariable(libName, Type.resolveClass(str + libName));
        });

        script.setVariable("trace", function(text) {
            try {
                script.trace(text);
            } catch(e) {
                trace(e);
            } 
        });
        script.setVariable("FlxSpriteGroup", FlxSpriteGroup);
		script.setVariable("PlayState_", PlayState);
		script.setVariable("FlxSprite", flixel.FlxSprite);
        script.setVariable("BGSprite", BGSprite);
		script.setVariable("BitmapData", openfl.display.BitmapData);
		script.setVariable("FlxBackdrop", flixel.addons.display.FlxBackdrop);
		script.setVariable("FlxG", FlxG);
		script.setVariable("Paths", Paths);
		script.setVariable("Std", Std);
		script.setVariable("Math", Math);
		script.setVariable("FlxMath", FlxMath);
		script.setVariable("FlxAssets", flixel.system.FlxAssets);
        script.setVariable("Assets", Assets);
		script.setVariable("Character", Character);
		script.setVariable("Conductor", Conductor);
		script.setVariable("StringTools", StringTools);
		script.setVariable("FlxSound", FlxSound);
		script.setVariable("FlxEase", FlxEase);
		script.setVariable("FlxTween", FlxTween);
		script.setVariable("FlxPoint", flixel.math.FlxPoint);
        script.setVariable("Note", Note);
		script.setVariable("debugPrint", function(text) {
            PlayState.instance.addTextToDebug(text, FlxColor.WHITE);
        });
        script.setVariable("addStageScript", function(script:String) {
            for(ext in ModManager.hscriptExts) {
                var scriptFile:String = 'stages/' + script + '.$ext';
                if(FileSystem.exists(Paths.modFolders(scriptFile))) {
                    scriptFile = Paths.modFolders(scriptFile);
                    PlayState.scripts.push(Script.fromPath(scriptFile));
                } else {
                    scriptFile = Paths.getPreloadPath(scriptFile);
                    if(FileSystem.exists(scriptFile)) {
                        PlayState.scripts.push(Script.fromPath(scriptFile));
                    }
                }
            }
        });
        script.setVariable("stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
        script.setVariable("subString", function(str:String, pos:Int) {
			return str.substr(pos);
		});
        script.setVariable("OpenFlAssets", openfl.utils.Assets);
        script.setVariable("FlxSort", FlxSort);
		script.setVariable("FlxTypedGroup", FlxTypedGroup);
        script.setVariable("CutsceneHandler", CutsceneHandler);
        script.setVariable("Achievements", Achievements);
		script.setVariable("FlxTimer", FlxTimer);
		script.setVariable("Json", Json);
		#if VIDEOS_ALLOWED
        script.setVariable("MP4Handler", MP4Handler);
        #end
        script.setVariable("controls", PlayerSettings.player1.controls);
		script.setVariable("CoolUtil", CoolUtil);
		script.setVariable("FlxTypeText", FlxTypeText);
		script.setVariable("FlxText", FlxText);
		script.setVariable("Rectangle", Rectangle);
		script.setVariable("Point", Point);
		script.setVariable("Window", Application.current.window);

		script.setVariable("GameOverSubstate", GameOverSubstate);
		script.setVariable("ModManager", ModManager);
		script.setVariable("FlxAxes", FlxAxes);
		script.setVariable("save", FlxG.save.data);
        script.setVariable("flashingLights", ClientPrefs.flashing);

		script.setVariable("CustomSubstate", FunkinLua.CustomSubstate);
		script.setVariable("ModchartSprite", FunkinLua.ModchartSprite);
        
		script.setVariable("AtlasFrameMaker", AtlasFrameMaker);
		script.setVariable("FlxTilemap", FlxTilemap);
		script.setVariable("BlendMode", {
            ADD: BlendMode.ADD,
            ALPHA: BlendMode.ALPHA,
            DARKEN: BlendMode.DARKEN,
            DIFFERENCE: BlendMode.DIFFERENCE,
            ERASE: BlendMode.ERASE,
            HARDLIGHT: BlendMode.HARDLIGHT,
            INVERT: BlendMode.INVERT,
            LAYER: BlendMode.LAYER,
            LIGHTEN: BlendMode.LIGHTEN,
            MULTIPLY: BlendMode.MULTIPLY,
            NORMAL: BlendMode.NORMAL,
            OVERLAY: BlendMode.OVERLAY,
            SCREEN: BlendMode.SCREEN,
            SHADER: BlendMode.SHADER,
            SUBTRACT: BlendMode.SUBTRACT
        });

        // AHhh~! *vomits epicly*
        script.setVariable("Function_Continue", FunkinLua.Function_Continue);
		script.setVariable("Function_Stop", FunkinLua.Function_Stop);
        script.setVariable("Function_StopLua", FunkinLua.Function_StopLua);

		// Song/Week shit
		script.setVariable('curBpm', Conductor.bpm);
		script.setVariable('bpm', PlayState.SONG.bpm);
		script.setVariable('scrollSpeed', PlayState.SONG.speed);
		script.setVariable('crochet', Conductor.crochet);
		script.setVariable('stepCrochet', Conductor.stepCrochet);
		script.setVariable('songLength', FlxG.sound.music.length);
		script.setVariable('songName', PlayState.SONG.song);
		script.setVariable('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		script.setVariable('startedCountdown', false);
		script.setVariable('curStage', PlayState.SONG.stage);

		script.setVariable('isStoryMode', PlayState.isStoryMode);
		script.setVariable('difficulty', PlayState.storyDifficulty);

		var difficultyName:String = CoolUtil.difficulties[PlayState.storyDifficulty];
		script.setVariable('difficultyName', difficultyName);
		script.setVariable('difficultyPath', Paths.formatToSongPath(difficultyName));
		script.setVariable('weekRaw', PlayState.storyWeek);
		script.setVariable('week', WeekData.weeksList[PlayState.storyWeek]);
		script.setVariable('seenCutscene', PlayState.seenCutscene);

		// Camera poo
		script.setVariable('cameraX', 0);
		script.setVariable('cameraY', 0);

		// Screen stuff
		script.setVariable('screenWidth', FlxG.width);
		script.setVariable('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		script.setVariable('curBeat', 0);
		script.setVariable('curStep', 0);
		script.setVariable('curDecBeat', 0);
		script.setVariable('curDecStep', 0);

		script.setVariable('score', 0);
		script.setVariable('misses', 0);
		script.setVariable('hits', 0);

		script.setVariable('rating', 0);
		script.setVariable('ratingName', '');
		script.setVariable('ratingFC', '');
		script.setVariable('version', MainMenuState.psychEngineVersion.trim());

		script.setVariable('inGameOver', false);
		script.setVariable('mustHitSection', false);
		script.setVariable('altAnim', false);
		script.setVariable('gfSection', false);

		// Gameplay settings
		script.setVariable('healthGainMult', PlayState.instance.healthGain);
		script.setVariable('healthLossMult', PlayState.instance.healthLoss);
		script.setVariable('playbackRate', PlayState.instance.playbackRate);
		script.setVariable('instakillOnMiss', PlayState.instance.instakillOnMiss);
		script.setVariable('botPlay', PlayState.instance.cpuControlled);
		script.setVariable('practice', PlayState.instance.practiceMode);

		for (i in 0...4) {
			script.setVariable('defaultPlayerStrumX' + i, 0);
			script.setVariable('defaultPlayerStrumY' + i, 0);
			script.setVariable('defaultOpponentStrumX' + i, 0);
			script.setVariable('defaultOpponentStrumY' + i, 0);
		}

		// Default character positions woooo
		script.setVariable('defaultBoyfriendX', PlayState.instance.BF_X);
		script.setVariable('defaultBoyfriendY', PlayState.instance.BF_Y);
		script.setVariable('defaultOpponentX', PlayState.instance.DAD_X);
		script.setVariable('defaultOpponentY', PlayState.instance.DAD_Y);
		script.setVariable('defaultGirlfriendX', PlayState.instance.GF_X);
		script.setVariable('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		script.setVariable('boyfriendName', PlayState.SONG.player1);
		script.setVariable('dadName', PlayState.SONG.player2);
		script.setVariable('gfName', PlayState.SONG.gfVersion);

		// Some settings, no jokes
        script.setVariable('ClientPrefs', ClientPrefs);
		script.setVariable('downscroll', ClientPrefs.downScroll);
		script.setVariable('middlescroll', ClientPrefs.middleScroll);
		script.setVariable('framerate', ClientPrefs.framerate);
		script.setVariable('ghostTapping', ClientPrefs.ghostTapping);
		script.setVariable('hideHud', ClientPrefs.hideHud);
		script.setVariable('timeBarType', ClientPrefs.timeBarType);
		script.setVariable('scoreZoom', ClientPrefs.scoreZoom);
		script.setVariable('cameraZoomOnBeat', ClientPrefs.camZooms);
		script.setVariable('flashingLights', ClientPrefs.flashing);
		script.setVariable('noteOffset', ClientPrefs.noteOffset);
		script.setVariable('healthBarAlpha', ClientPrefs.healthBarAlpha);
		script.setVariable('noResetButton', ClientPrefs.noReset);
		script.setVariable('lowQuality', ClientPrefs.lowQuality);
		script.setVariable('shadersEnabled', ClientPrefs.shaders);
		script.setVariable('scriptName', script.fileName);
		script.setVariable('currentModDirectory', Paths.currentModDirectory);
		script.setVariable('language', ClientPrefs.language);
		script.setVariable('languageDisplay', Language.getLanguageDisplayStr(Language.currentLanguage));

        script.setVariable('Song', Song);
        script.setVariable('PropertySprite', PropertySprite);

		script.setVariable('buildTarget', CoolUtil.buildTarget());

        script.setVariable('getLaw', function(law:String) {
            var result:Bool = switch (law) {
                #if windows case 'windows': true; #end
                #if VIDEOS_ALLOWED case 'VIDEOS_ALLOWED': true; #end
                #if debug case 'debug':  true; #end
                default: false;
            };
            return result;
        });
    }
}