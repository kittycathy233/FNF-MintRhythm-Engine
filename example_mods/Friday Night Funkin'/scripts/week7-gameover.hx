var targetVol:Float = 1;
function onGameOverStart() {
    new FlxTimer().start(3.5, function (_) {
        targetVol = 0.2;
    });

    new FlxTimer().start(4, function (_) {
        if (PlayState.SONG.stage == 'tank')
        {
            var exclude:Array<Int> = [];
            //if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];
            var play:Int = FlxG.random.int(1, 25, exclude);
            var audio:String = 'jeffGameover/jeffGameover-' + play;
            trace(audio);
    
            FlxG.sound.play(Paths.sound(audio), 1, false, null, true, function() {
                new FlxTimer().start(0.5, function (_) {
                    targetVol = 1;
                });
            });
        }
    });
}

function onUpdate(elapsed:Float) {
    FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, targetVol, elapsed * 3);
}