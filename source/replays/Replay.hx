package replays;

import song.Song;
import haxe.Json;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import openfl.net.FileFilter;
#if MODS_ALLOWED
import sys.io.File;
#end

typedef ReplayData = {
    var hits:Array<ReplayHit>;

    var totalMisses:Int;
    var totalHits:Int;

    var song:String;
    var songPath:String;
}

typedef ReplayHit = {
    var time:Float;
    var keyNum:Int;
    var event:String; // "keyDown" or "keyUp"
    var holdNoteDuration:Float;
}

class Replay {
    public static var recordedReplay:ReplayData;

    public static function register(time:Float, data:Int, event:String, holdNoteDuration:Float) {
        var duration:Float = 0;
        if (event == 'keyUp') duration = holdNoteDuration;
        if (recordedReplay != null) {
            recordedReplay.hits.push({
                time: time,
                keyNum: data,
                event: event,
                holdNoteDuration: duration
            });
        }
    }

    // stole this from ralsei engine anget killed :shadowtroll:
    public static function save() {
        #if MODS_ALLOWED
        var date = Date.now();
        var leDate = StringTools.replace(date.toString(), ':', '-');

        var difficulty = CoolUtil.difficultyString(PlayState.storyDifficulty);
        var filename:String = Paths.replays(leDate + '-' + PlayState.SONG.song.toLowerCase() + '-' + difficulty);

        File.write(filename + '.json', false);
        File.saveContent(filename + '.json', haxe.Json.stringify(recordedReplay));
        #end

        recordedReplay = null;
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////

    public static var _file:FileReference;
    public static var returnFile:ReplayData;

    
    public static function doReturn(json:ReplayData) {
        PlayState.SONG = Song.loadFromJson(json.song, json.songPath);
        PlayState._replay = json;
        PlayState._ogReplay = json;
        PlayState.replayMode = true;

        LoadingState.loadAndSwitchState(new PlayState());
    }

    public static function loadReplay() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

    /**
	* Called when the save file dialog is cancelled.
	*/
	private static function onLoadCancel(_):Void {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
        trace("Cancelled file loading.");
    }

    private static function onLoadComplete(_):Void {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

        #if sys
        var path:String = null;
        var json = cast Json.parse(Json.stringify(_file));

        if(json.__path != null) path = json.__path;

        if(path != null) {
            var raw:String = File.getContent(path);
            if (raw != null) {
                returnFile = cast Json.parse(raw);
                doReturn(returnFile);
                _file = null;
                return;
            }
        }
        #else
        trace('not sys lmao!!');
        #end

        _file = null;
    }

    /**
	* Called if there is an error while saving the gameplay recording.
	*/
	private static function onLoadError(_):Void {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
        trace("Problem loading file");
    }
}