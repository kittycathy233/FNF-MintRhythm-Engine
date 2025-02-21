package;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Prompt extends MusicBeatSubstate
{
	var selected = 0;
	var startedUsingKeyboard:Bool = false;

	public var okc:Void->Void;
	public var cancelc:Void->Void;

	var theText:String = '';
	var goAnyway:Bool = false;
	var option1:String = '';
	var option2:String = '';

	var buttonAccept:FlxUIButton;
	var buttonNo:FlxUIButton;
	public function new (
		promptText:String = '', 
		okCallback:Void->Void, 
		cancelCallback:Void->Void,
		acceptOnDefault:Bool = false,
		option1:String = null,
		option2:String = null)
	{
		okc = okCallback;
		cancelc = cancelCallback;
		theText = promptText;
		goAnyway = acceptOnDefault;
		
		var op1 = 'OK';
		var op2 = 'Cancel';
		
		if (option1 != null) 
			op1 = option1;
		if (option2 != null) 
			op2 = option2;

		this.option1 = op1;
		this.option2 = op2;

		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		super();
	}
	
	override public function create():Void 
	{
		super.create();
		if (goAnyway) {
			onAccept();
		} else {
			var UI_Tabs = new FlxUITabMenu(null, 
				[
					{
						name: 'name',
						label: 'Warning'
					}
				], true );
			var tab = new FlxUI(null, UI_Tabs);
			tab.name = "name";
	
			var textshit:FlxText = new FlxText(10, 10, 290, theText, 10);
			textshit.alignment = 'center';
			tab.add(textshit);
	
			buttonAccept = new FlxUIButton(0, 110, option1, onAccept);
			buttonNo = new FlxUIButton(0, 110, option2, onCancel);

			buttonNo.x = 110 - buttonNo.width;
			buttonNo.x -= 10;
			buttonNo.y = 100;

			buttonAccept.x = 110 + buttonAccept.width;
			buttonAccept.x += 10;
			buttonAccept.y = 100;

			var closeButton = new FlxUIButton(300, -15, "X", onCancel);
			closeButton.label.size = 10;
			closeButton.label.color = 0xFFFFFFFF;
			closeButton.color = 0xFFFF4444;
			closeButton.resize(20, 20);
			closeButton.scrollFactor.set();
			closeButton.x -= closeButton.width;
			closeButton.x -= 5;

			tab.add(closeButton);
			tab.add(buttonAccept);
			tab.add(buttonNo);
	
			UI_Tabs.addGroup(tab);
			UI_Tabs.resize(300, 150);
			UI_Tabs.scrollFactor.set();
			UI_Tabs.screenCenter();
			add(UI_Tabs);
		}
	}

	override function update(elapsed:Float) {
		if (controls.UI_LEFT_P)
			changeSelected(-1);
		if (controls.UI_RIGHT_P)
			changeSelected(1);
		if (controls.ACCEPT && startedUsingKeyboard) {
			switch (selected) {
				case 1: onAccept();
				default: onCancel();
			}
		}

		if (startedUsingKeyboard) {
			buttonNo.color = FlxColor.WHITE;
			buttonAccept.color = FlxColor.WHITE;
			buttonNo.label.color = FlxColor.BLACK;
			buttonAccept.label.color = FlxColor.BLACK;
			if (selected == 0) {
				buttonNo.color = 0xFF00A2FF;
				buttonNo.label.color = FlxColor.WHITE;
			} else if (selected == 1) {
				buttonAccept.color = 0xFF00A2FF;
				buttonAccept.label.color = FlxColor.WHITE;
			}
		}

		super.update(elapsed);
	}

	public function changeSelected(c:Int) {
		selected += c;
		if (selected > 1) selected = 0;
		if (selected < 0) selected = 1;

		startedUsingKeyboard = true;
	}
	
	public function onCancel() {
		if(cancelc != null)
			cancelc();
		close();
	}

	public function onAccept() {
		if(okc != null)
			okc();
		close();
	}
}