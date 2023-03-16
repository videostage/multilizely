import 'package:equatable/equatable.dart';

class PackageConfig extends Equatable {
  final String name;
  final String path;

  PackageConfig({
    required this.name,
    required this.path,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [name, path];
}
