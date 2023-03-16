import 'dart:io';

class LocalizationFile {
  final File file;

  late final String locale;

  LocalizationFile({
    required this.file,
  }) : assert(file.path.endsWith(".arb")) {
    _parseLocale();
  }

  void _parseLocale() {
    final locale = RegExp(r'strings_(.*)\.arb$').firstMatch(file.path)?.group(1);
    if (locale == null) {
      throw Exception("Can not parse locale of the file: ${file.path}");
    }
    this.locale = locale;
  }
}
