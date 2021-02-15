import 'package:arcane_chat/arcane_selector.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_manager.dart';
import 'package:flutter/material.dart';

class ArcaneAccountSettings extends StatefulWidget {
  final Satchel satchel;
  ArcaneAccountSettings({this.satchel});

  @override
  _ArcaneAccountSettingsState createState() => _ArcaneAccountSettingsState();
}

class _ArcaneAccountSettingsState extends State<ArcaneAccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.satchel.name} Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Rename Satchel"),
            subtitle: Text("Rename this satchel for organization purposes."),
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete Satchel"),
            subtitle: Text("THIS CANNOT BE UNDONE!"),
            onTap: () {
              WalletManager.deleteSatchel(widget.satchel);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ArcaneAccountSelector()));
            },
          ),
        ],
      ),
    );
  }
}
