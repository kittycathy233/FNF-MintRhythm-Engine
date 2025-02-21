// "stage"

var dadbattleSmokes:FlxSpriteGroup;
var dadbattleBlack:BGSprite;
var dadbattleLight:BGSprite;
function create() {
    dadbattleSmokes = new FlxSpriteGroup();
    dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
    dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
    dadbattleBlack.alpha = 0.25;
    dadbattleBlack.visible = false;
    PlayState.add(dadbattleBlack);

    dadbattleLight = new BGSprite('spotlight', 400, -400);
    dadbattleLight.alpha = 0.375;
    dadbattleLight.blend = BlendMode.ADD;
    dadbattleLight.visible = false;

    dadbattleSmokes.alpha = 0.7;
    dadbattleSmokes.blend = BlendMode.ADD;
    dadbattleSmokes.visible = false;
    PlayState.add(dadbattleLight);
    PlayState.add(dadbattleSmokes);

    var offsetX = 200;
    var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
    smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
    smoke.updateHitbox();
    smoke.velocity.x = FlxG.random.float(15, 22);
    smoke.active = true;
    dadbattleSmokes.add(smoke);
    var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
    smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
    smoke.updateHitbox();
    smoke.velocity.x = FlxG.random.float(-15, -22);
    smoke.active = true;
    smoke.flipX = true;
    dadbattleSmokes.add(smoke);
}

function onEvent(name:String, value1:String, value2:String) {
    if (name == "Dadbattle Spotlight") {

        var val:Null<Int> = Std.parseInt(value1);
        if(val == null) val = 0;

        switch(Std.parseInt(value1))
        {
            case 1, 2, 3: //enable and target dad
                if(val == 1) //enable
                {
                    dadbattleBlack.visible = true;
                    dadbattleLight.visible = true;
                    dadbattleSmokes.visible = true;
                    PlayState.defaultCamZoom += 0.12;
                    PlayState.triggerEventNote('Change Horizontal Scroll', 'swap current', '');
                }

                var who:Character = PlayState.dad;
                if(val > 2) who = PlayState.boyfriend;
                //2 only targets dad

                PlayState.triggerEventNote('Change Vertical Scroll', 'swap current', '');

                dadbattleLight.alpha = 0;
                new FlxTimer().start(0.12, function(tmr:FlxTimer) {
                    dadbattleLight.alpha = 0.375;
                });
                dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

            default:
                PlayState.triggerEventNote('Change Horizontal Scroll', 'swap current', '');

                dadbattleBlack.visible = false;
                dadbattleLight.visible = false;
                PlayState.defaultCamZoom -= 0.12;
                FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
                {
                    dadbattleSmokes.visible = false;
                }});
        }
    }
}