package backend;

#if VIDEOS_ALLOWED 
#if hxCodec
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as Video;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as Video;
#elseif (hxCodec == "2.6.0") import VideoHandler as Video;
#else import vlc.MP4Handler as Video; #end
#elseif hxvlc
import hxvlc.flixel.FlxVideo as Video;
#end
#end
import haxe.extern.EitherType;
import flixel.util.FlxSignal;
import haxe.io.Path;

#if VIDEOS_ALLOWED
class VideoManager extends Video {
    public var playbackRate(get, set):EitherType<Single, Float>;
    public var paused(default, set):Bool = false;
    public var onVideoEnd:FlxSignal;
    public var onVideoStart:FlxSignal;

    public function new(#if (hxCodec >= "3.0.0" && hxCodec) ?autoDispose:Bool = true #elseif hxvlc ?autoDispose:Bool = true, smoothing:Bool = true #end) {

        super();
        onVideoEnd = new FlxSignal();
        onVideoStart = new FlxSignal();    
        
        #if (hxCodec >= "3.0.0" || hxvlc)
        if(autoDispose)
            onEndReached.add(function(){
                dispose();
            }, true);

        onOpening.add(onVideoStart.dispatch);
        onEndReached.add(onVideoEnd.dispatch);
        #elseif (hxCodec < "3.0.0" && hxCodec)
        openingCallback = onVideoStart.dispatch;
        finishCallback = onVideoEnd.dispatch;
        #end    
    }

    public function startVideo(path:String, #if hxCodec loop:Bool = false #elseif hxvlc loops:Int = 0, ?options:Array<String> #end) {
        #if (hxCodec >= "3.0.0"  && hxCodec)
        play(path, loop);
        #elseif (hxCodec < "3.0.0"  && hxCodec)
        playVideo(path, loop, false);
        #elseif hxvlc
        load(path, loops, options);
        new FlxTimer().start(0.001, function(tmr:FlxTimer) {
            play();
        });
        #end
    }

    @:noCompletion
    private function set_paused(shouldPause:Bool){
        if(shouldPause){
            pause();
            if(FlxG.autoPause) {
                if(FlxG.signals.focusGained.has(pause))
                    FlxG.signals.focusGained.remove(pause);
    
                if(FlxG.signals.focusLost.has(resume))
                    FlxG.signals.focusLost.remove(resume);
            }
        } else {
            resume();
            if(FlxG.autoPause) {
                FlxG.signals.focusGained.add(pause);
                FlxG.signals.focusLost.add(resume);
            }
        }
        return shouldPause;
    }

    @:noCompletion
    private function set_playbackRate(multi:EitherType<Single, Float>){
        rate = multi;
        return multi;
    }

    @:noCompletion
    private function get_playbackRate():Float {
        return rate;
    }
    #end
}
