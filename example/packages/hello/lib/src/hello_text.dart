import 'package:flutter/cupertino.dart';
import 'package:hello/hello.dart';

class HelloText extends StatelessWidget {
  const HelloText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(HelloStrings.of(context).hello);
  }
}