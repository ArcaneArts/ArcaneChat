import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_xt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/credentials.dart';

class ArcaneReceive extends StatefulWidget {
  final Satchel satchel;
  final Wallet wallet;

  ArcaneReceive({this.satchel, this.wallet});

  @override
  _ArcaneReceiveState createState() => _ArcaneReceiveState();
}

class _ArcaneReceiveState extends State<ArcaneReceive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          child: Hero(
            child: Card(
              child: Container(
                width: 350,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      alignment: Alignment.topLeft,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.save_alt_rounded,
                          size: 86,
                        ),
                        Padding(
                          child: Container(
                            height: 0.3,
                            color: Theme.of(context).textTheme.subtitle1.color,
                          ),
                          padding: EdgeInsets.only(
                              left: 14, right: 14, top: 14, bottom: 4),
                        ),
                        Flexible(
                            child: FutureBuilder<EthereumAddress>(
                          future: widget.wallet.getAddress(),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return Text("");
                            }

                            return ListTile(
                              title: Text("Copy Address"),
                              subtitle: Text(
                                snap.data.hex,
                                style: TextStyle(fontSize: 11),
                              ),
                              onTap: () => Clipboard.setData(
                                      ClipboardData(text: snap.data.hex))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              "Copied Address to Clipboard")))),
                              leading:
                                  Icon(Icons.account_balance_wallet_rounded),
                            );
                          },
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
            tag: "card",
          ),
          padding: EdgeInsets.all(14),
        ),
      ),
    );
  }
}
