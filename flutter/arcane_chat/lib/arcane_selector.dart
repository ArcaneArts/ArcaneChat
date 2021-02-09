import 'package:arcane_chat/satchel_creator.dart';
import 'package:flutter/material.dart';

class ArcaneAccountSelector extends StatefulWidget {
  @override
  _ArcaneAccountSelectorState createState() => _ArcaneAccountSelectorState();
}

class _ArcaneAccountSelectorState extends State<ArcaneAccountSelector> {
  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 48, bottom: 14),
          child: Container(
            child: Hero(
              child: Card(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 14, right: 14),
                      child: Container(
                        height: 0.3,
                        color: Theme.of(context).textTheme.subtitle1.color,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Create Account"),
                      subtitle: Text("Create a new Arcane Wallet & Account"),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SatchelCreator())),
                    ),
                    ListTile(
                      leading: Icon(Icons.save_alt),
                      title: Text("Import Account"),
                      subtitle: Text("Import an existing Account"),
                      onTap: () {},
                    )
                  ],
                ),
              ),
              tag: "card",
            ),
            width: s.width / 1.1,
          ),
        ),
      ),
    );
  }
}
