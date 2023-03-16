import 'package:flutter/cupertino.dart';
import 'package:world/world.dart';

class WorldText extends StatelessWidget {
  const WorldText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(WorldStrings.of(context).world);
  }
}
