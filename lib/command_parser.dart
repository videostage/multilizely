import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

import 'config/build_config.dart';
import 'config/config.dart';
import 'config/package_config.dart';
import 'commands.dart';
import 'localization_package.dart';

class CommandParser {
  static const _initCommand = "init";

  static const _updateCommand = "update";

  static const _allPackagesFlag = "all-packages";

  static const _helpFlag = "help";

  static const _testFlag = "test";

  static const _packageOption = "package";

  static const _genOption = "generate";

  final List<String> args;

  late final ArgParser _parser;

  late final Config _config;

  final String _commandUsage =
      "Usage:\n${BuildConfig.binName} <command> options, where command one of: "
      "$_initCommand, $_updateCommand\n";

  CommandParser({
    required this.args,
  }) {
    _parseConfig();
    _initArgParser();
  }

  LocalizationCommand parse() {
    final result = _parser.parse(args);
    final command = result.command;
    final needHelp = result.wasParsed(_helpFlag);
    if (needHelp || command == null) {
      print(_usage());
      exit(0);
    }
    final isTest = command.wasParsed(_testFlag);
    final packages = _packages(
      command.wasParsed(_allPackagesFlag),
      command.wasParsed(_packageOption) ? command[_packageOption] : null,
    );
    if (command.name == _initCommand) {
      return InitCommand(
        isTest: isTest,
        packages: packages,
        config: _config,
      );
    } else if (command.name == _updateCommand) {
      return UpdateCommand(
        runGen: command.wasParsed(_genOption),
        isTest: isTest,
        packages: packages,
        config: _config,
      );
    } else {
      _usage();
      throw Exception("No command: $command");
    }
  }

  void _initArgParser() {
    _parser = ArgParser();
    final initCommandParser = ArgParser();
    final updateCommandParser = ArgParser();
    _parser.addCommand(_initCommand, initCommandParser);
    _parser.addCommand(_updateCommand, updateCommandParser);
    _addCommonOptions(initCommandParser);
    _addCommonOptions(updateCommandParser);
    _parser.addFlag(
      _helpFlag,
      abbr: "h",
      help: "List commands",
    );
    updateCommandParser.addFlag(
      _genOption,
      abbr: "g",
      help: "Generate dart files",
    );
  }

  void _addCommonOptions(ArgParser commandParser) {
    commandParser.addFlag(
      _testFlag,
      help: "Test mode. Results will be only in the build dir: build/${BuildConfig.binName}.",
    );
    commandParser.addOption(
      _packageOption,
      abbr: "p",
      allowed: _config.packagesConfigs.map((package) => package.name),
      help: "Name of the package with l10n.yaml. One of: ",
    );
    commandParser.addFlag(
      _allPackagesFlag,
      help: "Use all packages.",
    );
  }

  void _parseConfig() {
    final file = File("${BuildConfig.binName}.yaml");
    final yaml = loadYamlNode(file.readAsStringSync()) as YamlMap;
    final projectId = yaml["localizely_project_id"];
    final projectKey = yaml["project_key"];
    final packagesYaml = yaml["packages"] as YamlMap;
    final packages = packagesYaml.keys.cast<String>().map(
          (name) => PackageConfig(
            name: name,
            path: packagesYaml[name]["path"],
          ),
        );
    final localesYaml = yaml["locales"] as YamlMap;
    final locales = localesYaml.keys.whereType<String>();
    _config = Config(
      packagesConfigs: packages,
      projectId: projectId,
      token: _token(),
      locales: locales,
      projectKey: projectKey,
    );
  }

  String _token() {
    final token = Platform.environment["LOCALIZELY_TOKEN"];
    if (token == null) {
      throw Exception("Env var LOCALIZELY_TOKEN not found.");
    }
    return token;
  }

  String _usage() => _commandUsage + _parser.usage;

  Iterable<LocalizationPackage> _packages(bool isAll, String? packageName) {
    final localizationPackages = _config.packagesConfigs.map(
      (packageConfig) {
        final l10nFile = File("${packageConfig.path}/l10n.yaml");
        if (!l10nFile.existsSync()) {
          throw Exception("${l10nFile.path} not exists");
        }
        final l10nYaml = loadYamlNode(l10nFile.readAsStringSync()) as YamlMap;
        return LocalizationPackage(
          name: packageConfig.name,
          path: packageConfig.path,
          arbDirRelativePath: l10nYaml["arb-dir"],
          templateFile: l10nYaml["template-arb-file"],
          allowedLocales: _config.locales,
          projectKey: _config.projectKey,
        );
      },
    );
    if (isAll) {
      return localizationPackages;
    } else if (packageName != null) {
      final packages = localizationPackages.where((package) => package.name == packageName);
      if (packages.isEmpty) {
        throw Exception("Package not found: $packageName");
      }
      return packages;
    } else {
      throw Exception("Only one of $_allPackagesFlag, $_packageOption allowed");
    }
  }
}
