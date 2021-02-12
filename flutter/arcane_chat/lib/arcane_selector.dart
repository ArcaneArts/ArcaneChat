import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcane_unlocker.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/satchel_creator.dart';
import 'package:arcane_chat/wallet_manager.dart';
import 'package:flutter/material.dart';

class ArcaneAccountSelector extends StatefulWidget {
  @override
  _ArcaneAccountSelectorState createState() => _ArcaneAccountSelectorState();
}

class _ArcaneAccountSelectorState extends State<ArcaneAccountSelector> {
  @override
  Widget build(BuildContext context) {
    List<Satchel> satchels = WalletManager.getSatchels();
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
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: satchels.length,
                      itemBuilder: (context, pos) => ListTile(
                        leading: Icon(Icons.account_balance_wallet_rounded),
                        title: Text(satchels[pos].name),
                        onTap: () {
                          ArcaneConnect.reset();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArcaneSatchelUnlocker(
                                        satchel: satchels[pos],
                                      )));
                        },
                        subtitle: Text(satchels[pos].id),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 14, right: 14),
                      child: Container(
                        height: 0.3,
                        color: Theme.of(context).textTheme.subtitle1.color,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Create Satchel"),
                      subtitle: Text(
                          "Satchels contain a wallet & conversations. This is using the Etherium Kovan Test Net!"),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SatchelCreator())),
                    ),
                    ListTile(
                      leading: Icon(Icons.save_alt),
                      title: Text("Import Satchel"),
                      subtitle: Text("Import an existing Satchel"),
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
