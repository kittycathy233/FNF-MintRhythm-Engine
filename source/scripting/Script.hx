package scripting;

import mods.ModManager;
import cpp.vm.Gc;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.rtti.Meta;
import haxe.Unserializer;
import flixel.FlxG;
import flixel.FlxSprite;
import linc.Linc;
import cpp.Reference;
import cpp.Lib;
import cpp.Pointer;
import cpp.RawPointer;
import cpp.Callable;

import haxe.Constraints.Function;
import haxe.DynamicAccess;
import lime.app.Application;
using StringTools;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Exception;

// HSCRIPT
import hscript.Interp;

/**
    BASE CLASSES
**/
class Script implements IFlxDestroyable {
    public var fileName:String = "";
    public var mod:String = null;
    public var filePath:String = null;
    public var metadata:Dynamic = {};

    public function new() {

    }

    public static function fromPath(path:String):HScript {
        var script = create(path);
        if (script != null) {
            ModManager.setScriptDefaultVars(script);
            script.loadFile();
            script._executeFunc('create', []);
            return script;
        } else {
            return null;
        }
    }

    /**
     * DO NOT USE!!, 
     * use fromPath(path) instead
    **/
    public static function create(path:String):HScript {
        var scriptPath = path.toLowerCase();
        var ext = Path.extension(scriptPath);

        var scriptExts = ModManager.hscriptExts;
        if (ext.trim() == "") {
            for (extension in scriptExts) {
                if (FileSystem.exists('$path.$extension')) {
                    scriptPath = '$path.$extension';
                    ext = extension;
                    break;
                }
            }
        }
        var script:HScript = switch(ext.toLowerCase()) {
            case 'hx' | 'hscript' | 'hsc':  new HScript();
            default: null;
        }

        if (script == null) return null;
        script.filePath = path;
        script.fileName = CoolUtil.getLastOfArray(path.replace("\\", "/").split("/"));
        return script;
    }


    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        var ret = _executeFunc(funcName, args);
        executeFuncPost();
        return ret;
    }

    public function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        return null;
    }

    public function executeFuncPost() {

    }

    public function setVariable(name:String, val:Dynamic) {}

    public function getVariable(name:String):Dynamic {return null;}

    public function trace(text:String, error:Bool = false) {
        trace(text);
    }

    public function loadFile() {

    }

    public function destroy() {

    }

    public function setScriptObject(obj:Dynamic) {}
}

/**
    SCRIPT PACK
**/

class HScript extends Script {
    public var hscript:Interp;
    public function new() {
        hscript = new Interp();
        hscript.errorHandler = errorHandler;
        super();
    }

    public function errorHandler(e:Dynamic) {
        this.trace('$e', true);
        if (!FlxG.keys.pressed.SHIFT) {
            var posInfo = hscript.posInfos();

            var lineNumber = Std.string(posInfo.lineNumber);
            var methodName = posInfo.methodName;
            var className = posInfo.className;

            Application.current.window.alert('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nIf the message boxes blocks the engine, hold down SHIFT to bypass.', 'HScript error! - ${fileName}');
        }
    }

    public override function setScriptObject(obj:Dynamic) {
        hscript.scriptObject = obj;
    }

    public override function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        super._executeFunc(funcName, args);
        if (hscript == null)
            return null;
		if (hscript.variables.exists(funcName)) {
            var f = hscript.variables.get(funcName);
            if (Reflect.isFunction(f)) {
                if (args == null || args.length < 1)
                    return f();
                else
                    return Reflect.callMethod(null, f, args);
            }
		}
        executeFuncPost();
        return FunkinLua.Function_Continue;
    }

    public override function loadFile() {
        super.loadFile();
        if (filePath == null || filePath.trim() == "") return;
        try {
            hscript.execute(ModManager.getExpressionFromPath(filePath, true));
            trace('hscript file loaded succesfully:' + filePath);
        } catch(e) {
            this.trace('${e.message}', true);
        }
    }

    public override function trace(text:String, error:Bool = false) {
        var posInfo = hscript.posInfos();

        var lineNumber = Std.string(posInfo.lineNumber);
        var methodName = posInfo.methodName;
        var className = posInfo.className;
        
        trace(('$fileName:${methodName == null ? "" : '$methodName:'}$lineNumber: $text').trim());
    }

    public override function setVariable(name:String, val:Dynamic) {
        hscript.variables.set(name, val);
        @:privateAccess
        hscript.locals.set(name, {r: val, depth: 0});
    }

    public override function getVariable(name:String):Dynamic {
        if (@:privateAccess hscript.locals.exists(name) && @:privateAccess hscript.locals[name] != null) {
            @:privateAccess
            return hscript.locals.get(name).r;
        } else if (hscript.variables.exists(name))
            return hscript.variables.get(name);

        return null;
    }
}