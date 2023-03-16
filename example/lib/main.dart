import 'package:example/src/strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:hello/hello.dart';
import 'package:world/world.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Builder(builder: (context) => Text(MainStrings.of(context).title)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              HelloText(),
              WorldText(),
            ],
          ),
        ),
      ),
      localizationsDelegates: const [
        ...MainStrings.localizationsDelegates,
        ...HelloStrings.localizationsDelegates,
        ...WorldStrings.localizationsDelegates,
      ],
    );
  }
}
