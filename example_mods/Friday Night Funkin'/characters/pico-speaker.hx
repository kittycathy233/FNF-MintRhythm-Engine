function onCreatePost() {
    PlayState.gf.playAnim('shoot1', true);
}

function onUpdate(elapsed:Float) {
    if (PlayState.gf.animation.curAnim != null) {
        if(PlayState.gf.animation.curAnim.finished) {
            PlayState.gf.playAnim(PlayState.gf.animation.curAnim.name, false, false, PlayState.gf.animation.curAnim.frames.length - 3);
        }
    }
}