package;

using StringTools;

class Language {
    public static var currentLanguage:String = "english";
    public static var languageData:Dynamic;
    public static var languages:Array<String> = [];

    public static function initLanguage() {
        // haxe.Json so this class is 100% free-of-imports!
        var json = haxe.Json.parse(Paths.getTextFromFile("data/localization/list.json"));
        var loadLanguage:String = ClientPrefs.language;

        languages = [];
        var list:Array<String> = Reflect.getProperty(json, "list");
        for (lang in list) {
            languages.push(lang);
        }

        var languageJsonPath:String = Reflect.getProperty(json, loadLanguage);
        languageData = haxe.Json.parse(Paths.getTextFromFile("data/localization/" + languageJsonPath));
        updateCurrentLanguage();
    }

    public static function getLanguageDisplayStr(language:String = ""):String {
        var lang:String = "English";
        if (language == null || language.length < 1)
            language = ClientPrefs.language;

        for (langItem in languages) {
            if (langItem == language) {
                lang = g(langItem); // Get the display language from the json
            }
        }

        return lang;
    }

    public static function getAllLanguages(displayName:Bool = false):Array<String> {
        if (displayName) {
            var displayLanguages:Array<String> = [];
            for (lang in languages) {
                displayLanguages.push(getLanguageDisplayStr(lang));
            }
            return displayLanguages;
        }
        return languages;
    }

    public static function g(field:String = "no_translation", defaultVal:String = "Error on language json") {
        if (currentLanguage != ClientPrefs.language) reloadLanguages();

        var got = Reflect.getProperty(languageData, field);
        var ret = got;
        if (got == null) ret = defaultVal;
        return ret;
    }

    public static function changeLanguage(language:String = "english") {
        ClientPrefs.language = language;
        reloadLanguages();
    }

    public static function reloadLanguages() {
        ClientPrefs.saveSettings();
        updateCurrentLanguage();
        initLanguage();
    }

    public static function updateCurrentLanguage() {
        currentLanguage = ClientPrefs.language;
    }

    public static function convert(str:String):String {
        return str.replace(' ', '_').toLowerCase();
    }
}