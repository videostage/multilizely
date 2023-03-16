import 'package:equatable/equatable.dart';

import 'config/config.dart';
import 'localization_package.dart';

abstract class LocalizationCommand extends Equatable {
  final bool isTest;

  final Iterable<LocalizationPackage> packages;

  final Config config;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        isTest,
        config,
        packages,
      ];

  LocalizationCommand({
    required this.isTest,
    required this.packages,
    required this.config,
  });
}

class UpdateCommand extends LocalizationCommand {
  final bool runGen;

  @override
  List<Object?> get props => [
        runGen,
        ...super.props,
      ];

  UpdateCommand({
    required this.runGen,
    required bool isTest,
    required Config config,
    required Iterable<LocalizationPackage> packages,
  }) : super(
          isTest: isTest,
          packages: packages,
          config: config,
        );
}

class InitCommand extends LocalizationCommand {
  final bool overwrite;

  InitCommand({
    bool this.overwrite = false,
    required super.isTest,
    required super.packages,
    required super.config,
  });

  @override
  List<Object?> get props => [
        overwrite,
        ...super.props,
      ];
}
