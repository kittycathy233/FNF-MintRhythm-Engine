package editors;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIButton;
import openfl.net.FileReference;
import Discord;
import discord_rpc.DiscordRpc;

using StringTools;

typedef Presence = {
    var appID:String;
    var smallImageKey:String;
    var smallImageTxt:String;
    var largeImageKey:String;
    var largeImageTxt:String;
}

class DiscordRichPresence extends MusicBeatState {
    var _file:FileReference;
    var presence:Presence;
	var UI_box:FlxUITabMenu;

    var discord_ID:String = "863222024192262205";
    var smallImage:String = null;
    var smallImageTxt:String = null;
    var largeImage:String = "icon";
    var largeImageTxt:String = "Psych Engine";

    override function create() {
        super.create();

        var stupidBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        stupidBG.alpha = 0.5;
        add(stupidBG);

        #if sys
        presence = {
            appID: discord_ID,
            smallImageKey: smallImage,
            smallImageTxt: smallImageTxt,
            largeImageKey: largeImage,
            largeImageTxt: largeImageTxt
        };

        //Try loading json
		var path = Paths.mods(Paths.currentModDirectory + '/presence.json');
		if(FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if(rawJson != null && rawJson.length > 0) {
				var stuff:Dynamic = Json.parse(rawJson);
                //using reflects cuz for some odd reason my haxe hates the stuff.var shit
                var applicationID:String = Reflect.getProperty(stuff, "appID");
                var largeImageKey:String = Reflect.getProperty(stuff, "largeImageKey");
                var largeImageText:String = Reflect.getProperty(stuff, "largeImageText");
                var smallImageKey:String = Reflect.getProperty(stuff, "smallImageKey");
                var smallImageText:String = Reflect.getProperty(stuff, "smallmageText");

                if (applicationID != null && applicationID.length > 0) {
                    presence.appID = applicationID;
                }
                if (largeImageKey != null && largeImageKey.length > 0) {
                    presence.largeImageKey = largeImageKey;
                }
                if (largeImageText != null && largeImageText.length > 0) {
                    presence.largeImageTxt = largeImageText;
                }
                if (smallImageKey != null && smallImageKey.length > 0) {
                    presence.smallImageKey = smallImageKey;
                }
                if (smallImageText != null && smallImageText.length > 0) {
                    presence.smallImageTxt = smallImageText;
                }
            }
        }

        shutdown_reload();

        FlxG.mouse.visible = true;
        var tabs = [
			{name: "Presence", label: 'Presence'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 660;
		UI_box.y = 25;
		//UI_box.scrollFactor.set();
        add(UI_box);
        //UI_box.screenCenter();

        addUI();

        #end
    }

    var appID:FlxUIInputText;
    var largeImageText:FlxUIInputText;
    var largeImageKey:FlxUIInputText;
    var smallImageKey:FlxUIInputText;
    var smallImageText:FlxUIInputText;
    function addUI():Void {
        var tab_group_presence = new FlxUI(null, UI_box);
		tab_group_presence.name = "Presence";

        appID = new FlxUIInputText(10, 10, 200, presence.appID, 8);

        largeImageText = new FlxUIInputText(10, appID.y + 30, 200, presence.largeImageTxt, 8);

        largeImageKey = new FlxUIInputText(10, largeImageText.y + 30, 200, presence.largeImageKey, 8);

        smallImageText = new FlxUIInputText(10, largeImageKey.y + 30, 200, presence.smallImageTxt, 8);

        smallImageKey = new FlxUIInputText(10, smallImageText.y + 30, 200, presence.smallImageKey, 8);

        var applyBtn:FlxUIButton = new FlxUIButton(smallImageKey.x, smallImageKey.y + 30, "Apply", function () {
            presence.appID = appID.text;
            presence.largeImageKey = largeImageKey.text;
            presence.smallImageKey = smallImageKey.text;
            presence.largeImageTxt = largeImageText.text;
            presence.smallImageTxt = smallImageText.text;
            shutdown_reload();
        });

        var saveBtn:FlxUIButton = new FlxUIButton(applyBtn.x + 100, applyBtn.y, "Save", function () {
            save();
        });

        var closeBtn:FlxUIButton = new FlxUIButton(applyBtn.x, applyBtn.y + 30, "Close", exit);

		tab_group_presence.add(appID);
        tab_group_presence.add(largeImageText);
        tab_group_presence.add(largeImageKey);
        tab_group_presence.add(smallImageKey);
        tab_group_presence.add(smallImageText);

        tab_group_presence.add(new FlxText(appID.x, appID.y - 15, 0, 'Application ID'));
        tab_group_presence.add(new FlxText(largeImageText.x, largeImageText.y - 15, 0, 'Large Image Text'));
		tab_group_presence.add(new FlxText(largeImageKey.x, largeImageKey.y - 15, 0, 'Large Image Key'));
		tab_group_presence.add(new FlxText(smallImageText.x, smallImageText.y - 15, 0, 'Small Image Text'));
		tab_group_presence.add(new FlxText(smallImageKey.x, smallImageKey.y - 15, 0, 'Small Image Key'));

        tab_group_presence.add(applyBtn);
        tab_group_presence.add(saveBtn);
        tab_group_presence.add(closeBtn);

        UI_box.addGroup(tab_group_presence);
    }

    override function update(elapsed) {
        if (controls.BACK) {
            exit();
        }

        super.update(elapsed);
    }

    function exit() {
        MusicBeatState.switchState(new MasterEditorMenu());
    }

    function shutdown_reload() {
        DiscordRpc.shutdown();
        DiscordRpc.start({
            clientID: presence.appID,
            onReady: reload,
            onError: function(c, m) { trace('Error! $c : $m'); },
            onDisconnected: function(c, m) { trace('Disconnected! $c : $m'); }
        });
    }
    
    function save() {
        var data:String = Json.stringify(presence, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), 'presence.json');
		}
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved LEVEL DATA.");
    }

    /**
        * Called when the save file dialog is cancelled.
        */
    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    /**
        * Called if there is an error while saving the gameplay recording.
        */
    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.error("Problem saving Level data");
    }

    function reload() {
        DiscordRpc.presence({
            details: "Discord Presence Editor (PE Jank Engine)",
            state: null,
            largeImageKey: presence.largeImageKey,
            largeImageText: presence.largeImageTxt,
            smallImageKey: presence.smallImageKey,
            smallImageText: presence.smallImageTxt
        });
    }
}