import 'strings.dart';

/// The translations for English (`en`).
class HelloStringsEn extends HelloStrings {
  HelloStringsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';
}
