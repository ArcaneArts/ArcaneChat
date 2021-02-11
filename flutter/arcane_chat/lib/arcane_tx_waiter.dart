import 'package:arcane_chat/arcane_connect.dart';
import 'package:flutter/material.dart';

class ArcaneTxWaiter<T> extends StatefulWidget {
  final Future<T> waiter;

  ArcaneTxWaiter({this.waiter});

  @override
  _ArcaneTxWaiterState createState() => _ArcaneTxWaiterState();
}

class _ArcaneTxWaiterState<T> extends State<ArcaneTxWaiter<T>> {
  @override
  Widget build(BuildContext context) {
    widget.waiter.then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Used ${ArcaneConnect.lastSpent} Mana")));
      Navigator.pop(context, value);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(350))),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Container(
                width: 250,
                height: 250,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Center(
                      child: Icon(
                        Icons.auto_fix_high,
                        color: Theme.of(context).primaryColor,
                        size: 86,
                      ),
                    ),
                    FutureBuilder<bool>(
                      future: Future.delayed(Duration(seconds: 1), () => true),
                      builder: (context, s) => s.hasData
                          ? Center(
                              child: Container(
                                child: CircularProgressIndicator(),
                                width: 300,
                                height: 300,
                              ),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                    ),
                    FutureBuilder<bool>(
                      future: Future.delayed(Duration(seconds: 3), () => true),
                      builder: (context, s) => s.hasData
                          ? Center(
                              child: Container(
                                child: CircularProgressIndicator(),
                                width: 150,
                                height: 150,
                              ),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                    ),
                    FutureBuilder<bool>(
                      future: Future.delayed(Duration(seconds: 5), () => true),
                      builder: (context, s) => s.hasData
                          ? Center(
                              child: Container(
                                child: CircularProgressIndicator(),
                                width: 200,
                                height: 200,
                              ),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
