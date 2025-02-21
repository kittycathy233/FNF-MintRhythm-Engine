package;

import song.Song;
import flixel.util.FlxColor;
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import song.Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import yce.YCECharacter;
#end
import openfl.utils.Assets;
import haxe.Json;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var startedDeath:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		var characterType:String = 'psych';
		#if (MODS_ALLOWED && YOSHI_ENGINE_NATIVE)
		var characterPath:String = 'characters/' + curCharacter + '/';
		var path:String = Paths.modFolders(characterPath);
		if (FileSystem.isDirectory(path)) {
			characterType = 'yce';
		}
		#end

		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				switch (characterType) {
					#if (MODS_ALLOWED && YOSHI_ENGINE_NATIVE)
					case 'yce':
						var characterPath:String = 'characters/' + curCharacter + '/';
						var path:String = Paths.modFolders(characterPath);

						var cJsonPath:String = path + 'Character.json';
						if (FileSystem.exists(cJsonPath)) {
							var rawJson = File.getContent(cJsonPath);

							var json:CharacterJSON = cast Json.parse(rawJson);

							var jsonImg:String = 'spritesheet';
							frames = Paths.getSparrowAtlas(jsonImg);
							imageFile = jsonImg;
	
							if(json.scale != 1) {
								jsonScale = json.scale;
								setGraphicSize(Std.int(width * jsonScale));
								updateHitbox();
							}
	
							positionArray = [json.globalOffset.x, json.globalOffset.y];
							cameraPosition = [json.camOffset.x, json.camOffset.y];
	
							healthIcon = curCharacter;
							flipX = !!json.flipX;
							antialiasing = json.antialiasing;
	
							if(json.healthbarColor != null) {
								var rgb:FlxColor = Std.parseInt(json.healthbarColor.replace('#', '0xFF'));
								var hcA:Array<Int> = [rgb.red, rgb.green, rgb.blue];
								healthColorArray = hcA;
							}

							if(!ClientPrefs.globalAntialiasing) antialiasing = false;
	
							var shitSet:Array<CharacterAnim> = json.anims;
							if(shitSet != null && shitSet.length > 0) {
								for (anim in shitSet) {
									var animAnim:String = '' + anim.anim;
									var animName:String = '' + anim.name;
									var animFps:Int = anim.framerate;
									var animLoop:Bool = !!anim.loop; //Bruh
									var animIndices:Array<Int> = anim.indices;
									if(animIndices != null && animIndices.length > 0) {
										animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
									} else {
										animation.addByPrefix(animAnim, animName, animFps, animLoop);
									}
	
									addOffset(anim.anim, anim.x, anim.y);

									animationsArray.push({
										name: animName,
										anim: animAnim,
										fps: animFps,
										loop: animLoop,
										indices: animIndices,
										offsets: [Std.int(anim.x), Std.int(anim.y)]
									});
								}
							} else {
								quickAnimAdd('idle', 'BF idle dance');
							}
						}
					#end

					default:
						var characterPath:String = 'characters/' + curCharacter + '.json';

						#if MODS_ALLOWED
						var path:String = Paths.modFolders(characterPath);
						if (!FileSystem.exists(path)) {
							path = Paths.getPreloadPath(characterPath);
						}

						if (!FileSystem.exists(path))
						#else
						var path:String = Paths.getPreloadPath(characterPath);
						if (!Assets.exists(path))
						#end
						{
							path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
						}

						#if MODS_ALLOWED
						var rawJson = File.getContent(path);
						#else
						var rawJson = Assets.getText(path);
						#end

						var charData:CharacterFile = cast Json.parse(rawJson);
						var spriteType = "sparrow";
						//sparrow
						//packer
						//texture

						var json:CharacterFile = charData;
						#if MODS_ALLOWED
						var modTxtToFind:String = Paths.modsTxt(json.image);
						var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
						
						//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
						//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
						
						if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
						#else
						if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
						#end
						{
							spriteType = "packer";
						}
						
						#if MODS_ALLOWED
						var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
						var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
						
						//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
						//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
						
						if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
						#else
						if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
						#end
						{
							spriteType = "texture";
						}

						switch (spriteType){
							
							case "packer":
								frames = Paths.getPackerAtlas(json.image);
							
							case "sparrow":
								frames = Paths.getSparrowAtlas(json.image);
							
							case "texture":
								frames = AtlasFrameMaker.construct(json.image);
						}
						imageFile = json.image;

						if(json.scale != 1) {
							jsonScale = json.scale;
							setGraphicSize(Std.int(width * jsonScale));
							updateHitbox();
						}

						positionArray = json.position;
						cameraPosition = json.camera_position;

						healthIcon = json.healthicon;
						singDuration = json.sing_duration;
						flipX = !!json.flip_x;
						if(json.no_antialiasing) {
							antialiasing = false;
							noAntialiasing = true;
						}

						if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
							healthColorArray = json.healthbar_colors;

						antialiasing = !noAntialiasing;
						if(!ClientPrefs.globalAntialiasing) antialiasing = false;

						animationsArray = json.animations;
						if(animationsArray != null && animationsArray.length > 0) {
							for (anim in animationsArray) {
								var animAnim:String = '' + anim.anim;
								var animName:String = '' + anim.name;
								var animFps:Int = anim.fps;
								var animLoop:Bool = !!anim.loop; //Bruh
								var animIndices:Array<Int> = anim.indices;
								if(animIndices != null && animIndices.length > 0) {
									animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
								} else {
									animation.addByPrefix(animAnim, animName, animFps, animLoop);
								}

								if(anim.offsets != null && anim.offsets.length > 1) {
									addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
								}
							}
						} else {
							quickAnimAdd('idle', 'BF idle dance');
						}
						//trace('Loaded file to character ' + curCharacter);
				}
		}
		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed * PlayState.instance.playbackRate;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			} else if (isPlayer) {
				holdTimer = 0;
			}

			if (!isPlayer) {
				if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			} else {
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				{
					playAnim('idle', true, false, 10);
				}
	
				if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				{
					playAnim('deathLoop');
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
