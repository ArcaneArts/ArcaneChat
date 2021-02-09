import 'package:flutter/material.dart';

class SatchelCreator extends StatefulWidget {
  @override
  _SatchelCreatorState createState() => _SatchelCreatorState();
}

class _SatchelCreatorState extends State<SatchelCreator> {
  List<int> data = List<int>();
  int last = DateTime.now().millisecondsSinceEpoch;

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
                            value: data.length >= 2048
                                ? null
                                : (data.length.toDouble() / 2048.0),
                            strokeWidth: 7,
                          ),
                          width: 200,
                          height: 200,
                        ),
                        alignment: Alignment.center,
                      ),
                      Align(
                        child: data.length >= 2048
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
                    if (data.length > 2048) {
                      return;
                    }

                    if (DateTime.now().millisecondsSinceEpoch - last < 12) {
                      return;
                    }
                    last = DateTime.now().millisecondsSinceEpoch;
                    data.add(d.globalPosition.dx.round());
                    data.add(d.globalPosition.dy.round());
                    data.add(d.delta.dx.round());
                    data.add(d.delta.dy.round());
                    setState(() {});
                    if (data.length > 2048) {
                      Future.delayed(
                          Duration(seconds: 1),
                          () => Navigator.push(
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
                    obscureText: true,
                    controller: a,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  TextField(
                      obscureText: true,
                      controller: b,
                      decoration:
                          InputDecoration(hintText: "Confirm Password")),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        "Create Satchel",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ))
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
