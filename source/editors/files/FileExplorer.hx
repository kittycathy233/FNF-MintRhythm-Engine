#if MODS_ALLOWED
package editors.files;

import editors.files.FileExplorerElement;
import flixel.addons.ui.*;
import flixel.FlxG;
import openfl.utils.Assets;
import haxe.io.Path;
import sys.FileSystem;
import flixel.FlxSprite;

using StringTools;

enum FileExplorerType {
    Any;
    SparrowAtlas;
    Bitmap;
    XML;
    JSON;
    HScript;
    Lua;
    OGG;
	Script;
    Shader;
    BrowseAround;
}

@:enum
abstract FileExplorerIcon(Int) {
    var Unknown = 0;
    var Folder = 1;
    var JSON = 2;
    var Haxe = 3;
    var Audio = 4;
    var Text = 5;
    var XML = 6;
    var Bitmap = 7;
    var Sparrow = 8;
    var Executable = 9;
    var Lua = 10;
    var DLL = 11;
    var MP4 = 12;
}

/**
 * letters wont make it up for me!!
**/
class FileExplorer extends MusicBeatSubstate {
    var mod:String;
    var path:String = "";
    var type:FileExplorerType;

    var pathText:FlxUIText;
    var tab:FlxUI;
    var tabThingy:FlxUITabMenu;

    var mouseVisibleBeforeOpening:Bool = true;

    var spawnedElems:Array<FileExplorerElement> = [];

    var fileExt:String = "";
    var fileType:String = "";

    var callback:String->Void;

    public function navigateTo(path:String) {

        for (element in spawnedElems) {
            remove(element);
            element.destroy();
        }
        spawnedElems = [];
        this.path = path;
        var folderPath = Paths.mods('$mod/$path');
        
        var maxLength = 0;
        var dirs = [];
        var files = [];
        // TODO
        for (file in FileSystem.readDirectory(folderPath)) {
            if (FileSystem.isDirectory('$folderPath/$file')) {
                dirs.push(file);
            } else {
                files.push(file);
            }
            if (file.length > maxLength) maxLength = file.length;
        }
        maxLength *= 6;
        maxLength += 22;
        
        for (k => folder in dirs) {
            var nPath = '$path/$folder';
            var element = new FileExplorerElement(folder, Folder, () -> {
                navigateTo(nPath);
            }, maxLength);
            element.x = 10 + (maxLength * Math.floor(k / 27));
            element.y = 30 + (16 * (k % 27));
            tab.add(element);
            spawnedElems.push(element);
        }
        for (k => file in files) {
            var fileIcon:FileExplorerIcon = Unknown;
            fileIcon = switch(Path.extension(file).toLowerCase()) {
                case "json":                    JSON;
                case "hx" | "hscript" | "hsc":  Haxe;
                case "ogg" | "mp3":             Audio;
                case "log" | "txt":             Text;
                case "xml":                     XML;
                case "png" | "jpg" | "bmp" | "jpeg": Bitmap;
                case "exe":                     Executable;
                case "lua":                     Lua;
                case "dll":                     DLL;
                case "mp4":                     MP4;
                default:                        Unknown;
            }
            var element = new FileExplorerElement(file, fileIcon, () -> {
                if (fileExt != "") {
                    switch(type) {
                        case SparrowAtlas:
                            var ext = Path.extension(file).toLowerCase();
                            if (!fileExt.split(";").contains(ext)) {
                                openSubState(new Prompt('Error: You must select a $fileType', null, null));
                                return;
                            }
                            if (ext == "png") {
                                if (!FileSystem.exists('$path/${Path.withoutExtension(file)}.xml')) {
                                    openSubState(new Prompt('Error: This file does not have a .xml.', null, null));
                                    return;
                                }
                            } else {
                                if (!FileSystem.exists('$path/${Path.withoutExtension(file)}.png')) {
                                    openSubState(new Prompt('Error: This file does not have a .png.', null, null));
                                    return;
                                }
                            }
                            callback('$path/${Path.withoutExtension(file)}');
                            closeShit();
                        case BrowseAround:
                            return;
                        default:
                            if (!fileExt.split(";").contains(Path.extension(file).toLowerCase())) {
                                openSubState(new Prompt('Error: You must select a $fileType', null, null));
                                return;
                            }
                            callback('$path/$file');
                            closeShit();
                    }
                }
            }, maxLength);
            element.x = 10 + (maxLength * Math.floor((dirs.length + k) / 27));
            element.y = 30 + (16 * ((dirs.length + k) % 27));
            tab.add(element);
            spawnedElems.push(element);
        }
        pathText.text = '$path/';
    }

    function closeShit() {
        FlxG.mouse.visible = mouseVisibleBeforeOpening;
        close();
    }

    public override function new(mod:String, type:FileExplorerType, ?defaultFolder:String = "", callback:String->Void, ?windowName:String) {
        super();
        path = defaultFolder;
        this.mod = mod;
        this.callback = callback;

        if (!FlxG.mouse.visible) {
            mouseVisibleBeforeOpening = false;
            FlxG.mouse.visible = true;
        }

        var bg:FlxSprite;
        add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000));
        bg.scrollFactor.set();

        this.type = type;
        fileType = switch(type) {
            case Any:
                "file";
            case SparrowAtlas:
                "Sparrow atlas";
            case Bitmap:
                "Bitmap (PNG)";
            case XML:
                "XML file";
            case JSON:
                "JSON file";
            case HScript:
                ".hx or .hscript script";
            case Lua:
                ".lua script";
            case Script:
                "script";
            case Shader:
                "shader (.frag or .vert)";
            case OGG:
                "OGG sound";
            case BrowseAround:
                "File Explorer";
        }

        fileExt = switch(type) {
            case Any:
                "";
            case SparrowAtlas:
                "png;xml";
            case Bitmap:
                "png";
            case XML:
                "xml";
            case JSON:
                "json";
            case Shader:
                "frag;vert";
            case HScript:
                "hx;hscript;hsc";
            case Script:
                "hx;hscript;hsc;lua";
            case Lua:
                "lua";
            case OGG:
                "ogg";
            case BrowseAround:
                "";
        }

        var winName:String = "";
        if (windowName != null) {
            windowName == 'Select a $fileType';
        }
        if (type == BrowseAround)
            winName == "In-game File Explorer";

        tabThingy = new FlxUITabMenu(null, [
            {
                label: winName,
                name: 'explorer'
            }
        ], true);
        tabThingy.scrollFactor.set();
        tabThingy.resize(FlxG.width * 0.75, FlxG.height * 0.75);

        tab = new FlxUI(null, tabThingy);
        tab.name = "explorer";

        var upButton = new FlxUIButton(10, 10, "", function() {
            if (mod.replace("/", "").trim() == "") return;
            var split = path.split("/");
            navigateTo(
                [for (k=>p in split) 
                    if (p.trim() != "" && k < split.length - 1) p].join("/"));
        });
        upButton.resize(20, 20);

        var refreshButton = new FlxUIButton(upButton.x + upButton.width + 10, 10, "", function() {
			//ModSupport.loadMod(mod); what
            navigateTo(path);
        });
        refreshButton.resize(20, 20);
        
        pathText = new FlxUIText(refreshButton.x + refreshButton.width + 10, 10, 0, '$path/');
        
        refreshButton.y = upButton.y -= (upButton.height - pathText.height) / 2;
        

        var upIcon = new FlxSprite();
        CoolUtil.loadUIStuff(upIcon, "up");
        upIcon.x = upButton.x + (upButton.width / 2) - (upIcon.width / 2);
        upIcon.y = upButton.y + (upButton.height / 2) - (upIcon.height / 2);

        var refreshIcon = new FlxSprite();
        CoolUtil.loadUIStuff(refreshIcon, "refresh");
        refreshIcon.x = refreshButton.x + (refreshButton.width / 2) - (upIcon.width / 2);
        refreshIcon.y = refreshButton.y + (refreshButton.height / 2) - (upIcon.height / 2);

        
        var buttons:Array<FlxUIButton> = [];
        var buttonCancel:String = "Cancel";
        if (type == BrowseAround) buttonCancel = "Close";
        buttons.push(new FlxUIButton(0, 0, buttonCancel, function() {
            close();
        }));
        buttons.push(new FlxUIButton(0, 0, "Open Folder", function() {
            CoolUtil.openFolder(Paths.mods('$mod/$path'));
        }));

        for(k=>b in buttons) {
            b.y = tabThingy.height - 50;
            b.x = (FlxG.width * 0.325) + ((k - (buttons.length / 2) + 1) * 90);
            tab.add(b);
        }

        tab.add(upButton);
        tab.add(upIcon);
        tab.add(refreshButton);
        tab.add(refreshIcon);
        tab.add(pathText);

        navigateTo(defaultFolder);

        tabThingy.screenCenter();
        tabThingy.addGroup(tab);
        add(tabThingy);
        @:privateAccess
        cast(tabThingy._tabs[0], FlxUIButton).skipButtonUpdate = true;
    }
}
#end