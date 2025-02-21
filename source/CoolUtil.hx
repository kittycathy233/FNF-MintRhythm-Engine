package;

import flixel.util.FlxTimer;
import song.Song.SwagSong;
import song.Section.SwagSection;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef CheckForUpdateStatus = {
	var mustUpdate:Bool;
	var onlineVersion:String;
}

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	public static function quantizeNote(curDecBeat:Float, quantization:Int):Float {
		var beat:Float = curDecBeat;
		var snap:Float = quantization / 4;
		var increase:Float = 1 / snap;
		var fuck:Float = 0;

		if (zeroToOneValue(beat) < 0.5) // math rules imply values are rounded to 0 if less than 0.5
			fuck = quantize(beat, snap) - increase;
		else // if not, rounded to 1
			fuck = quantize(beat, snap) + increase;

		var quantTime:Float = Conductor.beatToSeconds(fuck);
		return quantTime;
	}

	public static function zeroToOneValue(value:Float):Float {
		return value - Math.floor(value);
	}

	// ok kade....
	public static function getRealTimeNps(notesHit:Array<Date>, seconds:Float = 1) {
		var balls = notesHit.length - 1;
		var secs = seconds * 1000;
		while (balls >= 0)
		{
			var cock:Date = notesHit[balls];
			if (cock != null && cock.getTime() + secs < Date.now().getTime())
				notesHit.remove(cock);
			else
				balls = 0;
			balls--;
		}
		return notesHit;
	}

	public static function highestValue(cur:Float, curMax:Float):Float {
		var balls:Float = cur;
		var testicles:Float = curMax;

		if (balls > testicles)
			testicles = balls;

		return testicles;
	}

	public static function getAverageHitsPerTime(hits:Float, time:Float) {
		return hits / time;
	}

	public static function deleteRandomlyInArray(array:Array<Dynamic>, probability:Float = 50) {
		var nArray:Array<Dynamic> = array;
		for (element in nArray) {
			if (FlxG.random.bool(probability)) nArray.remove(element);
		}

		return nArray;
	}

	public static function delRepeatedDatasRandomly(song:song.SwagSong, probability:Float = 50) {
		var nArray:Array<SwagSection> = song.notes;
		var lastElement:Array<Dynamic> = null;
		for (sec in nArray) {
			for (note in sec.sectionNotes) {
				var delete:Bool = false;

				if (lastElement != null) {
					if (lastElement[1] == note[1]) {
						if (FlxG.random.bool(probability)) delete = true;
					}
				}

				lastElement = note;
				
				if (delete) {
					sec.sectionNotes.remove(note);
				}
			}
		}

		return nArray;
	}

	public static function generateRandomNumberArray(length:Int = 4, int:Bool = true, min:Int = 1, max:Int = 255):Array<Float> {
		var gen:Array<Float> = [];
		for (i in 0...length) {
			if (int)
				gen.push(FlxG.random.int(min, max));
			else
				gen.push(FlxG.random.float(min, max));
		}

		return gen;
	}

	public static function generateRandomBooleanArray(length:Int = 4, probability:Float = 50):Array<Bool> {
		var gen:Array<Bool> = [];
		for (i in 0...length) gen.push(FlxG.random.bool(probability));
		return gen;
	}

	public static function generateRandomStringIP():String {
		return generateRandomNumberArray().join('.');
	}

	public static function tRange(value:Float, min:Float, max:Float) {
		return FlxMath.remapToRange(value, min, min, max, max);
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function buildTarget():String {
		#if windows
		return 'windows';
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif html5
		return 'html5';
		#elseif android
		return 'android';
		#elseif neko
		return 'neko';
		#elseif flash
		return 'flash';
		#elseif sys
		return 'sys';
		#else
		return 'wtf';
		#end
	}

	public static function getHostUsername():String
	{
		#if (macos || linux)
		return Sys.getEnv("USER");
		#elseif windows
		return Sys.getEnv("USERNAME");
		#end
		return buildTarget(); // build target lemefao
	}

	public static function loadUIStuff(sprite:flixel.FlxSprite, ?anim:String = 'delete') {
		sprite.loadGraphic(Paths.image("yce/uiIcons", "preload"), true, 16, 16);
		var anims = [
			"up", 
			"refresh", 
			"delete", 
			"copy", 
			"paste", 
			"x", 
			"swap", 
			"folder", 
			"play", 
			"edit", 
			"settings", 
			"song", 
			"add", 
			"trophy", 
			"up",
			"down", 
			"lock", 
			"pack"];
		
		for(i in 0...anims.length)
			sprite.animation.add(anims[i], [i], 0, false);
		if (anim != null) sprite.animation.play(anim);
	}

	public static function openFolder(p:String) {
		p = p.replace("/", "\\").replace("\\\\", "\\");
		#if windows
			Sys.command('explorer "$p"');	
		#elseif linux
			Sys.command('nautilus', [p]);
		#end
	}

	public static function difficultyString(diff:Int = null):String
	{
		var difficulty = diff;
		if (difficulty == null) difficulty = PlayState.storyDifficulty;
		return difficulties[difficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function wrapTo(value:Float, min:Float, max:Float) {
		value -= min;
		value %= (max - min);
		if (value < 0) value = (max - min) - value;
		return value + min;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
			  	var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  	if(colorOfThisPixel != 0){
				  	if (countByColor.exists(colorOfThisPixel)) {
				    	countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  	} else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687)) {
					 	countByColor[colorOfThisPixel] = 1;
				  	}
			  	}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function numberStringArray(max:Int, ?min = 0):Array<String>
	{
		var dumbArray:Array<String> = [];
		for (i in min...max)
		{
			dumbArray.push(Std.string(i));
		}
		return dumbArray;
	}

	public static function coolSongText(string:String):String {
		var formatted:String = string;
		string = string.replace('-', ' ');
		var words:Array<String> = string.split(' ');
		var newWords:Array<String> = [];
		for (word in words) {
			word = word.toLowerCase();
			word = word.charAt(0).toUpperCase() + word.substr(1, word.length);
			newWords.push(word);
		}
		formatted = newWords.join(' ');

		return formatted;
	}

	public static function getSubtitleFile(songName:String):String {
		var file:String = Paths.json(songName + '/subtitles-' + ClientPrefs.language);

		#if MODS_ALLOWED
		if (!FileSystem.exists(Paths.modsJson(songName + '/subtitles')) || !FileSystem.exists(file)) {
		#else
		if (!Assets.exists(file)) {
		#end
			#if MODS_ALLOWED
			file = Paths.modsJson(songName + '/subtitles');
			if (!FileSystem.exists(file)) {
				file = Paths.json(songName + '/subtitles');
			}
			#else
			file = Paths.json(songName + '/subtitles');
			#end
		}

		return file;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function getLastOfArray<T>(a:Array<T>):T {
		return a[a.length - 1];
	}

	public static function checkForUpdates(callback:CheckForUpdateStatus->Void) {
		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			var onlineVersion:String = "";
			var mustUpdate:Bool = false;

			http.onData = function (data:String)
			{
				onlineVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + onlineVersion + ', your version: ' + curVersion);
				if(onlineVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}

				timer(1, function (?_) {
					callback({
						mustUpdate: mustUpdate,
						onlineVersion: onlineVersion
					});
				});
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		} else
			cancelDaCheck(callback);
		#else
		cancelDaCheck(callback);
		#end
	}

	public static function cancelDaCheck(callback:CheckForUpdateStatus->Void) {
		trace('nuh uh we aint checking for it');
		callback({
			mustUpdate: false,
			onlineVersion: MainMenuState.psychEngineVersion.trim()
		});
	}

	public static function timer(time:Float = 1, callback:FlxTimer->Void) {
		new FlxTimer().start(time, callback);
	}

	public static function mashIntoOneLine(a:Array<String>):String {
		return a.join('');
	}

	// All notifs are 7s by default in w11, so idk how its on w10

	/**
	 * Does a windows notification
	 * Args:
	 * @param title Title of notification
	 * @param text Text of notification
	 * @param smallIcon Small Icon of notification (see https://learn.microsoft.com/en-us/dotnet/api/system.drawing.systemicons?view=dotnet-plat-ext-6.0)
	 * @param bigIcon Big Icon of notification (see https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.notifyicon?view=windowsdesktop-7.0)
	**/
	public static function windowsToast(title:String = null, text:String = null, smallIcon:String = "Exclamation", bigIcon:String = "Warning") {
		//DO NOT MODIFY THIS STUFF
		#if windows
		if (title == null)
			title = "Friday Night Funkin: Psych Engine";
		if (text == null)
			text = "Notification";

		var prohibitSymbols:Array<String> = ["'"];

		var commands:Array<String> = [
			"powershell -Command \"[reflection.assembly]::loadwithpartialname('System.Windows.Forms'); [reflection.assembly]::loadwithpartialname('System.Drawing'); $notify = new-object system.windows.forms.notifyicon; $notify.icon = [System.Drawing.SystemIcons]::",
			smallIcon,
			"; $notify.visible = $true; $notify.showballoontip(10, '",
			deleteSpecialSymbols(title, prohibitSymbols),
			"', '",
			deleteSpecialSymbols(text, prohibitSymbols),
			"', [system.windows.forms.tooltipicon]::",
			bigIcon,
			")\""
		];

		var toRun:String = mashIntoOneLine(commands);
		Sys.command(toRun);
		#end
	}

	public static function otherWindowsToast(title:String = null, text:String = null) {
		#if windows
		if (title == null)
			title = "Friday Night Funkin: Psych Engine";
		if (text == null)
			text = "Notification";

		var prohibitSymbols:Array<String> = ["'"];

		var commands:Array<String> = [
			"powershell -Command \"",
			"$ErrorActionPreference = 'Stop';",
			"$notificationTitle = '",
			deleteSpecialSymbols(text, prohibitSymbols),
			"';",
			"[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;",
			"$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01);",
			"$toastXml = [xml]",
			"$template.GetXml();",
			"$toastXml.GetElementsByTagName('text').AppendChild($toastXml.CreateTextNode($notificationTitle)) > $null;",
			"$xml = New-Object Windows.Data.Xml.Dom.XmlDocument;",
			"$xml.LoadXml($toastXml.OuterXml);",
			"$toast = [Windows.UI.Notifications.ToastNotification]::new($xml);",
			"$toast.Tag = 'Test1';",
			"$toast.Group = 'Test2';",
			"$toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(5);",
			"$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('",
			deleteSpecialSymbols(title, prohibitSymbols),
			"');",
			"$notifier.Show($toast);\""
		];

		var toRun:String = mashIntoOneLine(commands);
		Sys.command(toRun);
		#end
	}

	public static function deleteSpecialSymbols(string:String, ?symbols:Array<String> = null) {
		var newString:String = "";
		for (i in 0...string.length) {
			var char:String = string.charAt(i);

			var dontCheck:Bool = false;
			if (char == ' ')
				dontCheck = true;

			if (symbols != null && !dontCheck)
				if (symbols.contains(char))
					continue;
			
			if (!isTypeAlphabet(char) && !dontCheck)
				continue;

			newString += char;
		}

		return newString;
	}

	public static function isTypeAlphabet(c:String) // thanks kade
	{
		var ascii = StringTools.fastCodeAt(c, 0);
		return (ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122) || //A-Z, a-z
		specialCharCheck(c);
	}

	public static function specialCharCheck(c:String):Bool {
		switch(c.toLowerCase()) {
			case 'á' | 'é' | 'í' | 'ó' | 'ú' |
				'ñ' | 'ï' | 'õ' | 'ü' | 'ê' | 'ç' |
				'ã' | 'â' | 'ô':
				return true;
		}

		return false;
	}
}
