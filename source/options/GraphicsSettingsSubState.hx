package options;

import flixel.system.FlxAssets.FlxShader;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

import openfl.filters.BitmapFilter;
//import openfl.filters.BlurFilter; blur ??? why anyway
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);

		option.minValue = ClientPrefs.minFramerate;
		option.maxValue = ClientPrefs.maxFramerate + 1;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		option.isFps = true;
		#end

		var option:Option = new Option('Stretch Game',
			"Stretches the game to the window's size.",
			'stretchScreen',
			'bool',
			false);
		addOption(option);
		option.onChange = MusicBeatState.changeScaleMode;

		var option:Option = new Option('Filter',
			"Changes the filter on the game. Press ACCEPT to apply.",
			'gameFilter',
			'string',
			'None',
			['None', 'Scanline', 'Grayscale', 'Invert', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		);
		addOption(option);
		option.onEnter = onChangeFilter;	
		super();

		onChangeFramerate();
	}

	public static function onChangeFilter()
	{
		var filterMap:Map<String, {filter: BitmapFilter}> = [
			"Scanline" => {
				filter: new ShaderFilter(new Scanline())
			},
			"Grayscale" => {
				var matrix:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					  0,   0,   0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Invert" => {
				var matrix:Array<Float> = [
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Deuteranopia" => {
				var matrix:Array<Float> = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Protanopia" => {
				var matrix:Array<Float> = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Tritanopia" => {
				var matrix:Array<Float> = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			}
		];

		if (ClientPrefs.gameFilter != 'None')
			FlxG.game.setFilters([filterMap.get(ClientPrefs.gameFilter).filter]);
		else
			FlxG.game.setFilters([]);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		var changeTo:String = 'Unlimited';
		var doChange:Bool = false;
		if (ClientPrefs.framerate == ClientPrefs.minFramerate) {
			changeTo = 'Minimum: ' + ClientPrefs.minFramerate;
			doChange = true;
		}

		if (ClientPrefs.framerate == ClientPrefs.maxFramerate + 1) {
			FlxG.updateFramerate = 999;
			FlxG.drawFramerate = 999;
			doChange = true;
		} else {
			if(ClientPrefs.framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = ClientPrefs.framerate;
				FlxG.drawFramerate = ClientPrefs.framerate;
			} else {
				FlxG.drawFramerate = ClientPrefs.framerate;
				FlxG.updateFramerate = ClientPrefs.framerate;
			}
		}

		if (doChange) {
			for (option in optionsArray){
				if (option.isFps) {
					if (option.child != null) {
						option.child.text = changeTo;
					}
				}
			}
		}
	}
}

class Scanline extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		const float scale = 1.0;

		void main()
		{
			if (mod(floor(openfl_TextureCoordv.y * openfl_TextureSize.y / scale), 2.0) == 0.0)
				gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
			else
				gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
		}')
	public function new()
	{
		super();
	}
}