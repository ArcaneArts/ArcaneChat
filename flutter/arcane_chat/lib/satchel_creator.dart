import 'dart:math';

import 'package:arcane_chat/arcane_selector.dart';
import 'package:arcane_chat/constant.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_manager.dart';
import 'package:flutter/material.dart';

class SatchelCreator extends StatefulWidget {
  @override
  _SatchelCreatorState createState() => _SatchelCreatorState();
}

class _SatchelCreatorState extends State<SatchelCreator> {
  List<int> data = List<int>();
  int last = DateTime.now().millisecondsSinceEpoch;
  double speed = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          child: Hero(
            child: Card(
              child: GestureDetector(
                  child: Container(
                      child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.transparent,
                      ),
                      Align(
                        child: Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor),
                            value: data.length >= Constant.SEED_BITS
                                ? null
                                : (data.length.toDouble() /
                                    Constant.SEED_BITS.toDouble()),
                            strokeWidth: 7,
                          ),
                          width: 200,
                          height: 200,
                        ),
                        alignment: Alignment.center,
                      ),
                      Align(
                        child: data.length >= Constant.SEED_BITS
                            ? Icon(
                                Icons.check_circle,
                                size: 200,
                                color: Theme.of(context).primaryColor,
                              )
                            : Text(
                                "Draw & Scribble",
                                style: TextStyle(fontSize: 18),
                              ),
                        alignment: Alignment.center,
                      )
                    ],
                  )),
                  onPanUpdate: (d) {
                    speed = (d.delta.dx.abs() + d.delta.dy.abs()).toDouble();
                    if (data.length > Constant.SEED_BITS) {
                      return;
                    }

                    if (DateTime.now().millisecondsSinceEpoch - last <
                        100 - min(speed * 2, 100)) {
                      return;
                    }
                    last = DateTime.now().millisecondsSinceEpoch;
                    data.add(d.globalPosition.dx.round());
                    data.add(d.globalPosition.dy.round());

                    for (int i = 0; i < d.delta.dx.abs() / 4; i++) {
                      data.add((d.globalPosition.dx ~/ 2) +
                          i -
                          (d.delta.dx.abs() * i).toInt());
                    }

                    for (int i = 0; i < d.delta.dy.abs() / 4; i++) {
                      data.add((d.globalPosition.dy ~/ 2) +
                          i -
                          (d.delta.dy.abs() * i).toInt());
                    }

                    setState(() {});
                    if (data.length > Constant.SEED_BITS) {
                      Future.delayed(
                          Duration(seconds: 1),
                          () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SatchelFinisher(
                                        bits: data,
                                      ))));
                    }
                  }),
            ),
            tag: "card",
          ),
          padding: EdgeInsets.only(top: 48, bottom: 14, left: 7, right: 7),
        ),
      ),
    );
  }
}

class SatchelFinisher extends StatefulWidget {
  final List<int> bits;

  SatchelFinisher({this.bits});

  @override
  _SatchelFinisherState createState() => _SatchelFinisherState();
}

class _SatchelFinisherState extends State<SatchelFinisher> {
  TextEditingController n = TextEditingController(text: "Arcane Satchel");
  TextEditingController a = TextEditingController();
  TextEditingController b = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          child: Hero(
            child: Card(
                child: Padding(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  Text(
                    "Secure your Satchel",
                    style: TextStyle(fontSize: 21),
                  ),
                  TextField(
                    controller: n,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(hintText: "Satchel Name"),
                  ),
                  TextField(
                    obscureText: true,
                    controller: a,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  TextField(
                      obscureText: true,
                      controller: b,
                      onChanged: (v) => setState(() {}),
                      onSubmitted: (v) => setState(() {}),
                      decoration:
                          InputDecoration(hintText: "Confirm Password")),
                  TextButton(
                      onPressed: a.value.text.length >= 8 &&
                              a.value.text == b.value.text
                          ? () => Satchel.createRandom(
                                      WalletManager.nextSatchelId(),
                                      widget.bits,
                                      a.value.text)
                                  .then((value) {
                                value.name = n.value.text;
                                WalletManager.setSatchel(value);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ArcaneAccountSelector()));
                              })
                          : null,
                      child: Text("Create Satchel"))
                ],
              ),
              padding: EdgeInsets.all(7),
            )),
            tag: "card",
          ),
          padding: EdgeInsets.only(top: 48, bottom: 14, left: 7, right: 7),
        ),
      ),
    );
  }
}
