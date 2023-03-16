import 'dart:convert';
import 'dart:io';

import 'config/build_config.dart';
import 'localization_package.dart';

class LocalizationBuilder {
  final Iterable<LocalizationPackage> packages;

  final Iterable<String> allowedLocales;

  LocalizationBuilder({
    required this.packages,
    required this.allowedLocales,
  });

  Iterable<LocalizationPackage> buildInit() {
    _clean(BuildConfig.initPath);
    packages.forEach((package) {
      package.localizationFiles.forEach((localizationFile) {
        final locale = localizationFile.locale;
        final json = jsonDecode(localizationFile.file.readAsStringSync());
        final withPrefixJson = _addPackagePrefix(json, package.prefix);
        _arbFile(path: BuildConfig.initPath, package: package, locale: locale)
            .writeAsStringSync(_jsonEncodeAndFormat(withPrefixJson));
      });
    });
    return packages
        .map((package) => package.copyWith(path: "${BuildConfig.initPath}/${package.path}"));
  }

  UpdateResult buildUpdate() {
    _clean(BuildConfig.updatedPath);
    final downloadedPackage = DownloadedPackage(allowedLocales: allowedLocales);
    final downloadedFilesMap = {
      for (final file in downloadedPackage.localizationFiles) file.locale: file
    };
    packages.forEach((package) {
      final templateFile = package.localizationFiles
          .firstWhere((element) => element.file.path.contains(package.templateFile));
      final templateFileJson = jsonDecode(templateFile.file.readAsStringSync());
      final templateKeys = _addPackagePrefix(templateFileJson, package.prefix).keys;
      package.localizationFiles.forEach((localizationFile) {
        final locale = localizationFile.locale;
        final json = jsonDecode(localizationFile.file.readAsStringSync());
        final withPrefixJson = _addPackagePrefix(json, package.prefix);
        final downloadedFile = downloadedFilesMap[localizationFile.locale]?.file;
        final Map<String, dynamic> downloadedJson =
            jsonDecode(downloadedFile?.readAsStringSync() ?? "");
        for (var key in templateKeys) {
          final value = downloadedJson[key];
          if (value == null) continue;
          if (value is String && value.isEmpty) continue;
          if (value is Map && value.isEmpty) continue;
          withPrefixJson[key] = value;
        }
        final updatedJson = _removePackagePrefix(withPrefixJson, package.prefix);
        _arbFile(path: BuildConfig.updatedPath, package: package, locale: locale)
            .writeAsStringSync(_jsonEncodeAndFormat(updatedJson));
        _arbFile(path: BuildConfig.uploadedPath, package: package, locale: locale)
            .writeAsStringSync(_jsonEncodeAndFormat(withPrefixJson));
      });
    });
    return UpdateResult(
      updatedPackages: packages
          .map((package) => package.copyWith(path: "${BuildConfig.updatedPath}/${package.path}")),
      updatedToUploadPackages: packages
          .map((package) => package.copyWith(path: "${BuildConfig.uploadedPath}/${package.path}")),
    );
  }

  Map<String, dynamic> _addPackagePrefix(Map<String, dynamic> json, String prefix) =>
      json.map((key, value) => MapEntry(
            key.startsWith("@") ? "@$prefix\_${key.replaceFirst("@", "")}" : "$prefix\_${key}",
            value,
          ));

  Map<String, dynamic> _removePackagePrefix(Map<String, dynamic> json, String prefix) =>
      json.map((key, value) => MapEntry(
            key.replaceFirst("$prefix\_", ""),
            value,
          ));

  File _arbFile({
    String? path = ".",
    required LocalizationPackage package,
    required String locale,
  }) =>
      File(
        "${path}/"
        "${package.arbDirPath}/"
        "strings_$locale.arb",
      )..createSync(recursive: true);

  String _jsonEncodeAndFormat(Map? json) {
    final spaces = ' ' * 2;
    final encoder = JsonEncoder.withIndent(spaces);
    final sorted = json == null ? {} : _sort(json);
    return encoder.convert(sorted);
  }

  Map _sort(Map json) {
    final regExp = RegExp(r"[^@]*$");
    return Map.fromEntries(json.entries.toList()
      ..sort((a, b) => regExp.stringMatch(a.key)!.compareTo(regExp.stringMatch(b.key)!)));
  }

  void _clean(String dir) {
    final buildDir = Directory(dir);
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }
  }
}

class UpdateResult {
  Iterable<LocalizationPackage> updatedPackages;
  Iterable<LocalizationPackage> updatedToUploadPackages;

  UpdateResult({required this.updatedPackages, required this.updatedToUploadPackages});
}
