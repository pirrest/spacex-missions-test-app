import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';

class MyI18n {
  static TranslationsByLocale translations = Translations.byLocale("en");

  static Future<void> loadTranslations() async {
    Translations.recordMissingKeys = false;
    Translations.recordMissingTranslations = false;
    translations += await GettextImporter().fromAssetDirectory("assets/locales");
  }
}

/// https://pub.dev/packages/i18n_extension
/// https://flutter.dev/docs/development/accessibility-and-localization/internationalization
/// https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.htm
/// https://pub.dev/packages/sprintf
extension Localization on String {
  String get i18n => localize(this, MyI18n.translations);
  String plural(value) => localizePlural(value, this, MyI18n.translations);
  String fill(List<Object> params) => localizeFill(this, params);
}
