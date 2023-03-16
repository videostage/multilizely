import 'package:multilizely/command_parser.dart';
import 'package:multilizely/command_runner.dart';

void main(List<String> args) async {
  final commandParser = CommandParser(args: args);
  final command = commandParser.parse();
  final runner = CommandRunner(command);
  await runner.run();
  print("done");
}
