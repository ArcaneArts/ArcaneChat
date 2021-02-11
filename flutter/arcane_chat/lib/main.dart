import 'package:arcane_chat/arcane_selector.dart';
import 'package:arcane_chat/arcane_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ArcaneStorage.init().then((value) => runApp(Arcane()));
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
      debugShowCheckedModeBanner: false,
      title: "Arcane",
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light)),
          primaryColor: Color(0xFF422fbd),
          splashColor: Color(0x86422fbd),
          textSelectionColor: Color(0x11422fbd),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all(Color(0xFF422fbd)))),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF422fbd)))),
          textSelectionTheme: TextSelectionThemeData(
              selectionColor: Color(0x88422fbd),
              cursorColor: Color(0xFF422fbd)),
          cursorColor: Color(0xFF422fbd),
          buttonTheme: ButtonThemeData(buttonColor: Color(0xFF422fbd)),
          highlightColor: Color(0x86422fbd),
          accentColor: Color(0xFF422fbd)),
      home: ArcaneAccountSelector(),
    );
  }
}
