import 'package:equatable/equatable.dart';

import 'package_config.dart';

class Config extends Equatable {
  final String projectId;

  final Iterable<PackageConfig> packagesConfigs;

  final String token;

  final Iterable<String> locales;

  final String projectKey;

  Config({
    required this.packagesConfigs,
    required this.projectId,
    required this.token,
    required this.locales,
    required this.projectKey,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        packagesConfigs,
        projectId,
        token,
        locales,
        projectKey,
      ];
}
