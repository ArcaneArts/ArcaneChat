import 'package:arcane_chat/arcane_view.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class ArcaneSatchelUnlocker extends StatefulWidget {
  final Satchel satchel;
  static Map<String, Wallet> walletCache = Map<String, Wallet>();

  ArcaneSatchelUnlocker({this.satchel});

  @override
  _ArcaneSatchelUnlockerState createState() => _ArcaneSatchelUnlockerState();
}

class _ArcaneSatchelUnlockerState extends State<ArcaneSatchelUnlocker> {
  TextEditingController a = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (ArcaneSatchelUnlocker.walletCache.containsKey(widget.satchel.id)) {
      Future.delayed(
          Duration(milliseconds: 50),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ArcaneView(
                        satchel: widget.satchel,
                        wallet: ArcaneSatchelUnlocker
                            .walletCache[widget.satchel.id],
                      ))));
    }

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
            child: Padding(
                padding:
                    EdgeInsets.only(top: 48, bottom: 14, left: 7, right: 7),
                child: Hero(
                    tag: "card",
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: Text("Unlock " + widget.satchel.name),
                              subtitle:
                                  Text("Enter the password for this Satchel"),
                              leading: IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            TextField(
                              obscureText: true,
                              autofocus: true,
                              controller: a,
                              decoration: InputDecoration(hintText: "Password"),
                              onSubmitted: (v) {},
                            ),
                            TextButton(
                                onPressed: () {
                                  try {
                                    Wallet w =
                                        widget.satchel.getWallet(a.value.text);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ArcaneView(
                                                  satchel: widget.satchel,
                                                  wallet: w,
                                                )));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Could not unlock wallet file. Bad Password?"),
                                    ));
                                  }
                                },
                                child: Text("Unlock"))
                          ],
                        ),
                      ),
                    )))));
  }
}
