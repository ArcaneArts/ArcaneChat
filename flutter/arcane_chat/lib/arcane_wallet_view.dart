import 'package:arcane_chat/arcane_receive.dart';
import 'package:arcane_chat/arcane_send.dart';
import 'package:arcane_chat/arcaneamount.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_xt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneWalletView extends StatefulWidget {
  final Satchel satchel;
  final Wallet wallet;
  ArcaneWalletView({this.satchel, this.wallet});
  @override
  _ArcaneWalletViewState createState() => _ArcaneWalletViewState();
}

class _ArcaneWalletViewState extends State<ArcaneWalletView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          child: Material(
            child: Hero(
              child: Material(
                child: Card(
                  child: Container(
                    width: 350,
                    height: 215,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Stack(
                        children: [
                          IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context)),
                          FutureBuilder<ArcaneAmount>(
                            future: widget.wallet.getArcaneBalance(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              NumberFormat nf = NumberFormat();

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                      flex: 0,
                                      child: Icon(
                                        Icons.account_balance_wallet,
                                        size: 82,
                                      )),
                                  Flexible(
                                      flex: 0,
                                      child: Text(
                                        "${nf.format(snap.data.getMana().toInt())} Mana",
                                        style: TextStyle(fontSize: 36),
                                      )),
                                  Flexible(
                                      child: Padding(
                                    child: Container(
                                      height: 0.3,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .color,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 14,
                                        right: 14,
                                        top: 14,
                                        bottom: 4),
                                  )),
                                  Flexible(
                                      child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.save_alt),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ArcaneReceive(
                                                        satchel: widget.satchel,
                                                        wallet: widget.wallet,
                                                      ))).then(
                                              (value) => setState(() {}))),
                                      IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ArcaneSend(
                                                        wallet: widget.wallet,
                                                        satchel: widget.satchel,
                                                      ))).then(
                                              (value) => setState(() {}))),
                                    ],
                                  ))
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                color: Colors.transparent,
              ),
              tag: "card",
            ),
            color: Colors.transparent,
          ),
          padding: EdgeInsets.all(14),
        ),
      ),
    );
  }
}
