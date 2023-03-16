import 'strings.dart';

/// The translations for Spanish Castilian (`es`).
class HelloStringsEs extends HelloStrings {
  HelloStringsEs([String locale = 'es']) : super(locale);

  @override
  String get hello => 'Hola';
}
