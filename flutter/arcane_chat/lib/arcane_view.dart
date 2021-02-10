import 'package:arcane_chat/arcane_account_settings.dart';
import 'package:arcane_chat/arcane_wallet_view.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneView extends StatefulWidget {
  final Satchel satchel;
  final Wallet wallet;

  ArcaneView({this.satchel, this.wallet});

  @override
  _ArcaneViewState createState() => _ArcaneViewState();
}

class _ArcaneViewState extends State<ArcaneView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Derp"),
      appBar: AppBar(
        title: Text("Arcane"),
        actions: [
          Material(
            child: Hero(
              child: Material(
                child: IconButton(
                  icon: Icon(
                    Icons.account_balance_wallet_rounded,
                  ),
                  tooltip: "Wallet",
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ArcaneWalletView(
                                satchel: widget.satchel,
                                wallet: widget.wallet,
                              ))),
                ),
                color: Colors.transparent,
              ),
              tag: "card",
            ),
            color: Colors.transparent,
          ),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ArcaneAccountSettings(
                            satchel: widget.satchel,
                          ))))
        ],
      ),
    );
  }
}
