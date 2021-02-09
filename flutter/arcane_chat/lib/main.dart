import 'package:arcane_chat/arcane_selector.dart';
import 'package:arcane_chat/arcane_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ArcaneStorage.init().then((value) => runApp(Arcane()));
}

class Constant {
  static final String endpoint =
      "https://kovan.infura.io/v3/a7c468d6a0914a10a94705cd83eddcf3";
}

class Arcane extends StatefulWidget {
  Arcane({Key key}) : super(key: key);

  @override
  _ArcaneState createState() => _ArcaneState();
}

class _ArcaneState extends State<Arcane> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arcane",
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light)),
          primaryColor: Color(0xFF422fbd)),
      home: ArcaneAccountSelector(),
    );
  }
}
