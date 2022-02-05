import 'package:i18n_extension/i18n_extension.dart';

/// https://pub.dev/packages/i18n_extension
/// https://flutter.dev/docs/development/accessibility-and-localization/internationalization
/// https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.htm
/// https://pub.dev/packages/sprintf
extension Localization on String {

  static final _t = Translations("en") +
      {"en": "Start here", "ru":"Начните здесь", "uk":"Почніть тут"};

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
