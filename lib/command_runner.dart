import 'dart:io';
import 'package:multilizely/config/build_config.dart';
import 'package:multilizely/localization_file.dart';
import 'package:multilizely/localization_package.dart';

import 'commands.dart';
import 'localization_builder.dart';
import 'localizely_api.dart';

class CommandRunner {
  final LocalizationCommand command;

  final LocalizationBuilder _builder;

  final LocalizelyApi _api;

  CommandRunner(this.command)
      : _builder = LocalizationBuilder(
          packages: command.packages,
          allowedLocales: command.config.locales,
        ),
        _api = LocalizelyApi(
          projectId: command.config.projectId,
          token: command.config.token,
        );

  Future run() {
    if (command is InitCommand) {
      return _init();
    } else {
      return _update();
    }
  }

  Future _init() async {
    final resultPackages = _builder.buildInit();
    if (command.isTest) {
      return;
    }
    await Future.forEach<LocalizationPackage>(
      resultPackages,
      (package) async => await Future.forEach<LocalizationFile>(
        package.localizationFiles,
        (localizationFile) async => await _api.upload(
          localizationFile.file.path,
          locale: localizationFile.locale,
          overwrite: true,
          reviewed: true,
          tagsAdded: [package.prefix],
          tagsUpdated: [package.prefix],
        ),
      ),
    );
  }

  Future _update() async {
    final command = this.command as UpdateCommand;
    await Future.forEach<String>(command.config.locales,
        (locale) async => await _api.download(BuildConfig.downloadedPath, locale: locale));
    final updateResult = _builder.buildUpdate();
    if (command.isTest) {
      return;
    }
    await Future.forEach<LocalizationPackage>(
      updateResult.updatedToUploadPackages,
      (package) async => await Future.forEach<LocalizationFile>(
        package.localizationFiles,
        (localizationFile) async {
          await _api.upload(
            localizationFile.file.path,
            locale: localizationFile.locale,
            overwrite: true,
            reviewed: true,
            tagsAdded: [package.prefix],
            tagsUpdated: [package.prefix],
          );
        },
      ),
    );
    await Future.forEach<LocalizationPackage>(
      updateResult.updatedPackages,
      (package) async => await Future.forEach<LocalizationFile>(
        package.localizationFiles,
        (localizationFile) async {
          final originalFilePath =
              localizationFile.file.path.replaceFirst("${BuildConfig.updatedPath}/", "");
          localizationFile.file.copySync(originalFilePath);
          if (command.runGen) {
            final originalPackagePath =
                package.path.replaceFirst("${BuildConfig.updatedPath}/", "");
            final result =
                await Process.run("flutter", ["gen-l10n"], workingDirectory: originalPackagePath);
            print(result.stderr);
          }
        },
      ),
    );
  }
}
