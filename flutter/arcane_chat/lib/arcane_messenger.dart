import 'package:arcane_chat/satchel.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class ArcaneMessenger extends StatefulWidget {
  final Wallet wallet;
  final Satchel satchel;
  final String recipientName;
  final EthereumAddress recipient;

  ArcaneMessenger(
      {this.wallet, this.satchel, this.recipient, this.recipientName});

  @override
  _ArcaneMessengerState createState() => _ArcaneMessengerState();
}

class _ArcaneMessengerState extends State<ArcaneMessenger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
      ),
    );
  }
}
