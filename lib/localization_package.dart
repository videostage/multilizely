import 'dart:io';

import 'config/build_config.dart';
import 'localization_file.dart';

class LocalizationPackage {
  final String path;

  final String arbDirRelativePath;

  final String templateFile;

  final String name;

  final Iterable<String> _allowedLocales;

  final String? projectKey;

  late final Iterable<LocalizationFile> localizationFiles;

  String get arbDirPath => "$path/$arbDirRelativePath";

  String get prefix => "$projectKey:$name";

  LocalizationPackage({
    required this.path,
    required this.arbDirRelativePath,
    required this.templateFile,
    required this.name,
    this.projectKey,
    required Iterable<String> allowedLocales,
  }) : _allowedLocales = allowedLocales {
    _loadFiles();
  }

  void _loadFiles() => localizationFiles = Directory("$arbDirPath")
      .listSync()
      .whereType<File>()
      .where((element) => element.path.endsWith(".arb"))
      .map((file) => LocalizationFile(file: file))
      .where((localizationFile) => _allowedLocales.contains(localizationFile.locale));

  LocalizationPackage copyWith({
    String? arbDirRelativePath,
    String? path,
  }) =>
      LocalizationPackage(
        path: path ?? this.path,
        arbDirRelativePath: arbDirRelativePath ?? this.arbDirRelativePath,
        templateFile: templateFile,
        name: name,
        allowedLocales: _allowedLocales,
        projectKey: projectKey,
      );
}

class DownloadedPackage extends LocalizationPackage {
  DownloadedPackage({required super.allowedLocales})
      : super(
          path: BuildConfig.downloadedPath,
          arbDirRelativePath: "",
          templateFile: "strings_en.arb",
          name: "downloaded",
        );
}
