package backend;

class EK {
	public static var scales:Array<Float> = [
		0.9, // 1k
		0.85, //2k
		0.8, //3k
		0.7, //4k
		0.66, //5k
		0.6, //6k
		0.55, //7k
		0.50, //8k
		0.46, //9k
		0.39, //10k
		0.36, //11k
		0.32, //12k
		0.31, //13k
		0.31, //14k
		0.3, //15k
        0.26, //16k
        0.26, //17k
        0.22 //18k
    ];

	public static var restPosition:Array<Float> = [
        0, //1k
        -5, //2k
        0, //3k
        0, //4k
        16, //5k
        23,//6k
        25, //7k
        25, //8k
        24, //9k
        17, //10k
        16, //11k
        12, //12k
        15, //13k
        18,// 14k
        19, //15k
        13, // 16k
        14, //17k
        10 //18k
    ];

	public static var offsetX:Array<Float> = [
        150, //1k
        89,//2k
        45, //3k
        0, //4k
        0, //5k
        0, //6k
        0, //7k
        0, //8k
        0, //9k
        0, //10k
        0, //11k
        0, //12k
        0, //13k
        0, //14k
        0, //15k
        0, //16k
        0, //17k
        0 //18k
    ];

	public static var defaultMania:Int = 3;
	public static var minMania:Int = 0;
	public static var maxMania:Int = 17;
	public static function keys(maniaVal:Int) {
		return maniaVal + 1;
	}
	public static function strums(maniaVal:Int) {
		return (maniaVal * 2) + 1;
	}

	public static function fillKeybinds() {
		var arrayToFill = [];
		for (i in 0...maxMania + 2) {
			var keybindArray = [];
			for (k in 0...i) {
				var keyID = '${i}_key_${k}';
				//var keyArray = ClientPrefs.keyBinds.get(keyID);
				keybindArray.push(keyID);
			}
			//trace(keybindArray);
			arrayToFill.push(keybindArray);
		}

		return arrayToFill;
	}

	public static var controlMenu:Dynamic = [
		[
			[true, 'Key 1', '1_key_0', 'Center (1 KEY)']
		],
		[
			[true, 'Key 1', '2_key_0', 'Left (2 KEY)'],
			[true, 'Key 2', '2_key_1', 'Right (2 KEY)']
		],
		[
			[true, 'Key 1', '3_key_0', 'Left (3 KEY)'],
			[true, 'Key 2', '3_key_1', 'Center (3 KEY)'],
			[true, 'Key 3', '3_key_2', 'Right (3 KEY)']
		],
		[
			[true, 'Key 1', '4_key_0', 'Left (4 KEY)'],
			[true, 'Key 2', '4_key_1', 'Down (4 KEY)'],
			[true, 'Key 3', '4_key_2', 'Up (4 KEY)'],
			[true, 'Key 4', '4_key_3', 'Right (4 KEY)']
		],
		[
			[true, 'Key 1', '5_key_0', 'Left (5 KEY)'],
			[true, 'Key 2', '5_key_1', 'Down (5 KEY)'],
			[true, 'Key 3', '5_key_2', 'Center (5 KEY)'],
			[true, 'Key 4', '5_key_3', 'Up (5 KEY)'],
			[true, 'Key 5', '5_key_4', 'Right (5 KEY)']
		],
		[
			[true, 'Key 1', '6_key_0', 'Left 1 (6 KEY)'],
			[true, 'Key 2', '6_key_1', 'Up (6 KEY)'],
			[true, 'Key 3', '6_key_2', 'Right 1 (6 KEY)'],
			[true, 'Key 4', '6_key_3', 'Left 2 (6 KEY)'],
			[true, 'Key 5', '6_key_4', 'Down (6 KEY)'],
			[true, 'Key 6', '6_key_5', 'Right 2 (6 KEY)']
		],
		[
			[true, 'Key 1', '7_key_0', 'Left 1 (7 KEY)'],
			[true, 'Key 2', '7_key_1', 'Up (7 KEY)'],
			[true, 'Key 3', '7_key_2', 'Right 1 (7 KEY)'],
			[true, 'Key 4', '7_key_3', 'Center (7 KEY)'],
			[true, 'Key 5', '7_key_4', 'Left 2 (7 KEY)'],
			[true, 'Key 6', '7_key_5', 'Down (7 KEY)'],
			[true, 'Key 7', '7_key_6', 'Right 2 (7 KEY)']
		],
		[
			[true, 'Key 1', '8_key_0', 'Left (8 KEY)'],
			[true, 'Key 2', '8_key_1', 'Down 1 (8 KEY)'],
			[true, 'Key 3', '8_key_2', 'Up 1 (8 KEY)'],
			[true, 'Key 4', '8_key_3', 'Right 1 (8 KEY)'],
			[true, 'Key 5', '8_key_4', 'Left 2 (8 KEY)'],
			[true, 'Key 6', '8_key_5', 'Down 2 (8 KEY)'],
			[true, 'Key 7', '8_key_6', 'Up 2 (8 KEY)'],
			[true, 'Key 8', '8_key_7', 'Right 2 (8 KEY)'],
		],
		[
			[true, 'Key 1', '9_key_0', 'Left 1 (9 KEY)'],
			[true, 'Key 2', '9_key_1', 'Down 1 (9 KEY)'],
			[true, 'Key 3', '9_key_2', 'Up 1 (9 KEY)'],
			[true, 'Key 4', '9_key_3', 'Right 1 (9 KEY)'],
			[true, 'Key 5', '9_key_4', 'Center (9 KEY)'],
			[true, 'Key 6', '9_key_5', 'Left 2 (9 KEY)'],
			[true, 'Key 7', '9_key_6', 'Down 2 (9 KEY)'],
			[true, 'Key 8', '9_key_7', 'Up 2 (9 KEY)'],
			[true, 'Key 9', '9_key_8', 'Right 2 (9 KEY)'],
		],
		[
			[true, 'Key 1', '10_key_0', 'Left 1 (10 KEY)'],
			[true, 'Key 2', '10_key_1', 'Down 1 (10 KEY)'],
			[true, 'Key 3', '10_key_2', 'Up 1 (10 KEY)'],
			[true, 'Key 4', '10_key_3', 'Right 1 (10 KEY)'],
			[true, 'Key 5', '10_key_4', 'Center 1 (10 KEY)'],
			[true, 'Key 6', '10_key_5', 'Center 2 (10 KEY)'],
			[true, 'Key 7', '10_key_6', 'Left 2 (10 KEY)'],
			[true, 'Key 8', '10_key_7', 'Down 2 (10 KEY)'],
			[true, 'Key 9', '10_key_8', 'Up 2 (10 KEY)'],
			[true, 'Key 10', '10_key_9', 'Right 2 (10 KEY)'],
		],
		[
			[true, 'Key 1', '11_key_0', 'Left 1 (11 KEY)'],
			[true, 'Key 2', '11_key_1', 'Down 1 (11 KEY)'],
			[true, 'Key 3', '11_key_2', 'Up 1 (11 KEY)'],
			[true, 'Key 4', '11_key_3', 'Right 1 (11 KEY)'],
			[true, 'Key 5', '11_key_4', 'Left 2 (11 KEY)'],
			[true, 'Key 6', '11_key_5', 'Center 2 (11 KEY)'],
			[true, 'Key 7', '11_key_6', 'Right 2 (11 KEY)'],
			[true, 'Key 8', '11_key_7', 'Left 3 (11 KEY)'],
			[true, 'Key 9', '11_key_8', 'Down 2 (11 KEY)'],
			[true, 'Key 10', '11_key_9', 'Up 2 (11 KEY)'],
			[true, 'Key 11', '11_key_10', 'Right 3 (11 KEY)'],
		],
		[
			[true, 'Key 1', '12_key_0', 'Left 1 (12 KEY)'],
			[true, 'Key 2', '12_key_1', 'Down 1 (12 KEY)'],
			[true, 'Key 3', '12_key_2', 'Up 1 (12 KEY)'],
			[true, 'Key 4', '12_key_3', 'Right 1 (12 KEY)'],
			[true, 'Key 5', '12_key_4', 'Left 2 (12 KEY)'],
			[true, 'Key 6', '12_key_5', 'Down 2 (12 KEY)'],
			[true, 'Key 7', '12_key_6', 'Up 2 (12 KEY)'],
			[true, 'Key 8', '12_key_7', 'Right 2 (12 KEY)'],
			[true, 'Key 9', '12_key_8', 'Left 3 (12 KEY)'],
			[true, 'Key 10', '12_key_9', 'Down 3 (12 KEY)'],
			[true, 'Key 11', '12_key_10', 'Up 3 (12 KEY)'],
			[true, 'Key 12', '12_key_11', 'Right 3 (12 KEY)'],
		],
		[
			[true, 'Key 1', '13_key_0', 'Left 1 (13 KEY)'],
			[true, 'Key 2', '13_key_1', 'Down 1 (13 KEY)'],
			[true, 'Key 3', '13_key_2', 'Up 1 (13 KEY)'],
			[true, 'Key 4', '13_key_3', 'Right 1 (13 KEY)'],
			[true, 'Key 5', '13_key_4', 'Left 2 (13 KEY)'],
			[true, 'Key 6', '13_key_5', 'Down 2 (13 KEY)'],
			[true, 'Key 7', '13_key_6', 'Center (13 KEY)'],
			[true, 'Key 8', '13_key_7', 'Up 2 (13 KEY)'],
			[true, 'Key 9', '13_key_8', 'Right 2 (13 KEY)'],
			[true, 'Key 10', '13_key_9', 'Left 3 (13 KEY)'],
			[true, 'Key 11', '13_key_10', 'Down 3 (13 KEY)'],
			[true, 'Key 12', '13_key_11', 'Up 3 (13 KEY)'],
			[true, 'Key 13', '13_key_12', 'Right 3 (13 KEY)'],
		],
		[
			[true, 'Key 1', '14_key_0', 'Left 1 (14 KEY)'],
			[true, 'Key 2', '14_key_1', 'Down 1 (14 KEY)'],
			[true, 'Key 3', '14_key_2', 'Up 1 (14 KEY)'],
			[true, 'Key 4', '14_key_3', 'Right 1 (14 KEY)'],
			[true, 'Key 5', '14_key_4', 'Left 2 (14 KEY)'],
			[true, 'Key 6', '14_key_5', 'Down 2 (14 KEY)'],
			[true, 'Key 7', '14_key_6', 'Center 1 (14 KEY)'],
			[true, 'Key 8', '14_key_7', 'Center 2 (14 KEY)'],
			[true, 'Key 9', '14_key_8', 'Up 2 (14 KEY)'],
			[true, 'Key 10', '14_key_9', 'Right 2 (14 KEY)'],
			[true, 'Key 11', '14_key_10', 'Left 3 (14 KEY)'],
			[true, 'Key 12', '14_key_11', 'Down 3 (14 KEY)'],
			[true, 'Key 13', '14_key_12', 'Up 3 (14 KEY)'],
			[true, 'Key 14', '14_key_13', 'Right 3 (14 KEY)'],
		],
		[
			[true, 'Key 1', '15_key_0', 'Left 1 (15 KEY)'],
			[true, 'Key 2', '15_key_1', 'Down 1 (15 KEY)'],
			[true, 'Key 3', '15_key_2', 'Up 1 (15 KEY)'],
			[true, 'Key 4', '15_key_3', 'Right 1 (15 KEY)'],
			[true, 'Key 5', '15_key_4', 'Left 2 (15 KEY)'],
			[true, 'Key 6', '15_key_5', 'Down 2 (15 KEY)'],
			[true, 'Key 7', '15_key_6', 'Center 1 (15 KEY)'],
			[true, 'Key 8', '15_key_7', 'Center 2 (15 KEY)'],
			[true, 'Key 9', '15_key_8', 'Center 3 (15 KEY)'],
			[true, 'Key 10', '15_key_9', 'Up 2 (15 KEY)'],
			[true, 'Key 11', '15_key_10', 'Right 2 (15 KEY)'],
			[true, 'Key 12', '15_key_11', 'Left 3 (15 KEY)'],
			[true, 'Key 13', '15_key_12', 'Down 3 (15 KEY)'],
			[true, 'Key 14', '15_key_13', 'Up 3 (15 KEY)'],
			[true, 'Key 15', '15_key_14', 'Right 3 (15 KEY)'],
		],
		[
			[true, 'Key 1', '16_key_0', 'Left 1 (16 KEY)'],
			[true, 'Key 2', '16_key_1', 'Down 1 (16 KEY)'],
			[true, 'Key 3', '16_key_2', 'Up 1 (16 KEY)'],
			[true, 'Key 4', '16_key_3', 'Right 1 (16 KEY)'],
			[true, 'Key 5', '16_key_4', 'Left 2 (16 KEY)'],
			[true, 'Key 6', '16_key_5', 'Down 2 (16 KEY)'],
			[true, 'Key 7', '16_key_6', 'Up 2 (16 KEY)'],
			[true, 'Key 8', '16_key_7', 'Right 2 (16 KEY)'],
			[true, 'Key 9', '16_key_8', 'Left 3 (16 KEY)'],
			[true, 'Key 10', '16_key_9', 'Down 3 (16 KEY)'],
			[true, 'Key 11', '16_key_10', 'Up 3 (16 KEY)'],
			[true, 'Key 12', '16_key_11', 'Right 3 (16 KEY)'],
			[true, 'Key 13', '16_key_12', 'Left 4 (16 KEY)'],
			[true, 'Key 14', '16_key_13', 'Down 4 (16 KEY)'],
			[true, 'Key 15', '16_key_14', 'Up 4 (16 KEY)'],
			[true, 'Key 16', '16_key_15', 'Right 4 (16 KEY)'],
		],
		[
			[true, 'Key 1', '17_key_0', 'Left 1 (17 KEY)'],
			[true, 'Key 2', '17_key_1', 'Down 1 (17 KEY)'],
			[true, 'Key 3', '17_key_2', 'Up 1 (17 KEY)'],
			[true, 'Key 4', '17_key_3', 'Right 1 (17 KEY)'],
			[true, 'Key 5', '17_key_4', 'Left 2 (17 KEY)'],
			[true, 'Key 6', '17_key_5', 'Down 2 (17 KEY)'],
			[true, 'Key 7', '17_key_6', 'Up 2 (17 KEY)'],
			[true, 'Key 8', '17_key_7', 'Right 2 (17 KEY)'],
			[true, 'Key 9', '17_key_8', 'Center (17 KEY)'],
			[true, 'Key 10', '17_key_9', 'Left 3 (17 KEY)'],
			[true, 'Key 11', '17_key_10', 'Down 3 (17 KEY)'],
			[true, 'Key 12', '17_key_11', 'Up 3 (17 KEY)'],
			[true, 'Key 13', '17_key_12', 'Right 3 (17 KEY)'],
			[true, 'Key 14', '17_key_13', 'Left 4 (17 KEY)'],
			[true, 'Key 15', '17_key_14', 'Down 4 (17 KEY)'],
			[true, 'Key 16', '17_key_15', 'Up 4 (17 KEY)'],
			[true, 'Key 17', '17_key_16', 'Right 4 (17 KEY)'],
		],
		[
			[true, 'Key 1', '18_key_0', 'Left 1 (18 KEY)'],
			[true, 'Key 2', '18_key_1', 'Down 1 (18 KEY)'],
			[true, 'Key 3', '18_key_2', 'Up 1 (18 KEY)'],
			[true, 'Key 4', '18_key_3', 'Right 1 (18 KEY)'],
			[true, 'Key 5', '18_key_4', 'Center 1 (18 KEY)'],
			[true, 'Key 6', '18_key_5', 'Left 2 (18 KEY)'],
			[true, 'Key 7', '18_key_6', 'Down 2 (18 KEY)'],
			[true, 'Key 8', '18_key_7', 'Up 2 (18 KEY)'],
			[true, 'Key 9', '18_key_8', 'Right 2 (18 KEY)'],
			[true, 'Key 10', '18_key_9', 'Left 3 (18 KEY)'],
			[true, 'Key 11', '18_key_10', 'Down 3 (18 KEY)'],
			[true, 'Key 12', '18_key_11', 'Up 3 (18 KEY)'],
			[true, 'Key 13', '18_key_12', 'Right 3 (18 KEY)'],
			[true, 'Key 14', '18_key_13', 'Center 2 (18 KEY)'],
			[true, 'Key 15', '18_key_14', 'Left 4 (18 KEY)'],
			[true, 'Key 16', '18_key_15', 'Down 4 (18 KEY)'],
			[true, 'Key 17', '18_key_16', 'Up 4 (18 KEY)'],
			[true, 'Key 18', '18_key_17', 'Right 4 (18 KEY)'],
		]		
	];

	public static var data:Map<Int, Map<String, Dynamic>> = [
		0 => [
			"strums" => ["arrowROMBUS"],
			"anims" => ["UP"],
			"notes" => ["rombus"],
			"rgbIndex" => [4]
		],
		1 => [
			"strums" => ["arrowLEFT", "arrowRIGHT"],
			"anims" => ["LEFT", "RIGHT"],
			"notes" => ["purple", "red"],
			"rgbIndex" => [0, 3]
		],
		2 => [
			"strums" => ["arrowLEFT", "arrowROMBUS", "arrowRIGHT"],
			"anims" => ["LEFT", "UP", "RIGHT"],
			"notes" => ["purple", "rombus", "red"],
			"rgbIndex" => [0, 4, 3]
		],
		3 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3]
		],
		4 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowROMBUS", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "rombus", "green", "red"],
			"rgbIndex" => [0, 1, 4, 2, 3]
		],
		5 => [
			"strums" => ["arrowLEFT", "arrowUP", "arrowRIGHT", "arrowLEFT", "arrowDOWN", "arrowRIGHT"],
			"anims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"],
			"notes" => ["purple", "green", "red", "purple", "blue", "red"],
			"rgbIndex" => [0, 2, 3, 5, 1, 8]
		],
		6 => [
			"strums" => ["arrowLEFT", "arrowUP", "arrowRIGHT", "arrowROMBUS", "arrowLEFT", "arrowDOWN", "arrowRIGHT"],
			"anims" => ["LEFT", "UP", "RIGHT", "UP", "LEFT", "DOWN", "RIGHT"],
			"notes" => ["purple", "green", "red", "rombus", "purple", "blue", "red"],
			"rgbIndex" => [0, 2, 3, 4, 5, 1, 8]
		],
		7 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 5, 6, 7, 8]
		],
		8 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowROMBUS", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "rombus", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8]
		],
		9 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowROMBUS", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "rombus", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 4, 13, 5, 6, 7, 8]
		],
		10 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowROMBUS", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "rombus", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 4, 12, 5, 6, 7, 8]
		],
		11 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 5, 6, 7, 8]
		],
		12 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "circle", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 13, 11, 12, 5, 6, 7, 8]
		],
		13 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowROMBUS", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "rombus", "circle", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 4, 13, 11, 12, 5, 6, 7, 8]
		],
		14 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowROMBUS", "arrowCIRCLE", "arrowROMBUS", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "UP", "UP", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "rombus", "circle", "rombus", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 4, 13, 4, 11, 12, 5, 6, 7, 8]
		],
		15 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "circle", "circle", "circle", "circle", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 14, 15, 16, 17, 5, 6, 7, 8]
		],
		16 => [
			"strums" => ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowCIRCLE", "arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
			"anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			"notes" => ["purple", "blue", "green", "red", "circle", "circle", "circle", "circle", "circle", "circle", "circle", "circle", "circle", "purple", "blue", "green", "red"],
			"rgbIndex" => [0, 1, 2, 3, 9, 10, 11, 12, 13, 14, 15, 16, 17, 5, 6, 7, 8]
		],
		17 => [
			"strums" => [
				'arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT',
				'arrowROMBUS', 'arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT',
				'arrowCIRCLE', 'arrowCIRCLE', 'arrowCIRCLE', 'arrowCIRCLE',
				'arrowCIRCLE', 'arrowCIRCLE', 'arrowCIRCLE', 'arrowCIRCLE', 'arrowCIRCLE'
			],
			"anims" => [
				"LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT",
				"LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"
			],
			"notes" => [
				'purple', 'blue', 'green', 'red',
				'rombus', 'purple', 'blue', 'green', 'red',
				'circle', 'circle', 'circle', 'circle',
				'circle', 'circle', 'circle', 'circle', 'circle'
			],
			"rgbIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
		]
	];
	
	
}
