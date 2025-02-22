package options;

class ExtraGameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Extra Options\nWTF, silly Chinese Option\n\nNot Done';
		rpcTitle = 'Extra Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('show Game Version', //Name
		"在FPS Counter的位置附加显示当前版本", //Description
		'exgameversion',
		'bool');
		addOption(option);

		var option:Option = new Option('Focus Game', //Name
		"当游戏未处于焦点时会暂停", //Description
		'autoPause',
		'bool');
		addOption(option);

		var option:Option = new Option('Show Extra-Rating',
		"显示额外的rating\n文件名（例子）: sick-extra.png\n别在pixel场景启用它，因为大喵没有做，除非你有类似贴图",
		'exratingDisplay',
		'bool');
		addOption(option);

		var option:Option = new Option('Rating Bounce',
		"加强评分图标的跳动效果\n注：此选项存在较多bug，建议禁用",
		'ratbounce',
		'bool');
		addOption(option);

		var option:Option = new Option('Extra-Rating Bounce',
		"加强扩展评分图标的跳动效果\n当然同上，这个选项也存在一些bug",
		'exratbounce',
		'bool');
		addOption(option);

		var option:Option = new Option('Remove Perfect! Note Judgement',
		"如名，移除“Perfect！”评级\n同时扩展评级贴图也会改变",
		'rmperfect',
		'bool');
		addOption(option);

		var option:Option = new Option('Ratings Opacity',
			'修改评级贴图的不透明度，100%为不修改.',
			'ratingsAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('HealthBar Style',
		"（施工中）\n设置健康条的样式",
		'healthbarstyle',
		'string',
		['Psych', 'OS', 'Kade']);
		addOption(option);


		var option:Option = new Option('IconBop Style',
		"（施工中）\n设置小图标的跳动样式",
		'iconbopstyle',
		'string',
		['Psych', 'OS', 'MintRhythm', 'Kade', 'NONE']);
		addOption(option);

		var option:Option = new Option('ScoreTxt Style',
		'（施工中）\n修改scoreTxt的显示样式',
		'scoretxtstyle',
		'string',
		['Psych', 'OS', 'MintRhythm', 'Kade']);
		addOption(option);

		var option:Option = new Option('Remove the "ms" offset',
		'（施工中）\n移除Note命中时“xx ms”的显示\n可能会用到的功能',
		'rmmsTimeTxt',
		'bool');
		addOption(option);

		var option:Option = new Option('ScoreTxt bounce',
		"（施工中）\n命中Note时，scoreTxt会额外加上角度的跳动效果",
		'scoretxtbounce',
		'bool');
		addOption(option);

		var option:Option = new Option('Loading Style',
		"设置场景切换时的风格",
		'customFadeStyle',
		'string',
		['Vanilla', 'NovaFlare Move', 'NovaFlare Alpha', 'MintRhythm']);
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}