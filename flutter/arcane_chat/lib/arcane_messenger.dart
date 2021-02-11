import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcane_message.dart';
import 'package:arcane_chat/arcaneamount.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_xt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/credentials.dart';

class ArcaneBubble extends StatelessWidget {
  final String name;
  final String message;
  final bool pending;

  ArcaneBubble({this.name, this.message, this.pending});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 4;
    return Padding(
      padding: EdgeInsets.only(
          left: name == null ? w : 7, right: name != null ? w : 7, top: 3),
      child: Card(
        color: name == null
            ? (pending
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Theme.of(context).primaryColor)
            : null,
        shadowColor: name != null
            ? Theme.of(context).primaryColor.withOpacity(0.6)
            : null,
        elevation: name != null
            ? 4
            : pending
                ? 0
                : 12,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: name != null ? Radius.circular(24) : Radius.circular(7),
          topLeft: name == null ? Radius.circular(24) : Radius.circular(7),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        )),
        child: Padding(
          child: Text(
            message,
            maxLines: 1000000,
            style: TextStyle(
                fontSize: 21, color: name == null ? Colors.white : null),
          ),
          padding: EdgeInsets.all(14),
        ),
      ),
    );
  }
}

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
  bool loading = false;
  ScrollController sc = ScrollController();
  List<ArcaneMessage> messages = List<ArcaneMessage>();
  TextEditingController tc = TextEditingController();

  bool send() {
    String v = tc.value.text.trim();
    if (v.isEmpty) {
      return false;
    }

    widget.wallet.privateKey.extractAddress().then((value) {
      Future<String> pend = ArcaneConnect.getContract()
          .sendMessage(widget.wallet, widget.recipient, v);

      ArcaneMessage aa = ArcaneMessage()
        ..sender = value
        ..recipient = widget.recipient
        ..message = v
        ..pending = true;
      setState(() {
        messages.add(aa);
      });
      ArcaneConnect.waitForTx(pend).then((value) => setState(() {
            aa.pending = false;
          }));
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    try {
      Future.delayed(
          Duration(milliseconds: 100),
          () => sc.animateTo(sc.position.maxScrollExtent,
              duration: Duration(milliseconds: 1250),
              curve: Curves.easeInOutExpo));
    } catch (e) {}

    if (!loading) {
      loading = true;
      ArcaneConnect.getContract()
          .getMessages(widget.wallet, widget.recipient,
              (progress) => print("Scanning Messages: $progress"))
          .then((value) => value.listen((event) {
                setState(() {
                  messages.add(event);
                });
              }))
          .then((value) => beginListening());
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          FutureBuilder<ArcaneAmount>(
            future: widget.wallet.getArcaneBalance(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container();
              }

              NumberFormat nf = NumberFormat();
              return Padding(
                padding: EdgeInsets.only(right: 14),
                child: Center(
                  child: Text(
                    nf.format(snap.data.getMana().toInt()) + " Mana",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          )
        ],
        title: Text(widget.recipientName),
      ),
      body: FutureBuilder<int>(
        future: ArcaneConnect.getManaFee(),
        builder: (context, manafee) {
          if (!manafee.hasData) {
            return Container();
          }

          return Column(
            children: [
              Flexible(
                  child: ListView.builder(
                controller: sc,
                itemCount: messages.length,
                itemBuilder: (context, pos) => ArcaneBubble(
                  pending: messages[pos].pending,
                  message: messages[pos].message,
                  name: messages[pos].sender == widget.recipient
                      ? widget.recipientName
                      : null,
                ),
              )),
              Flexible(
                flex: 0,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  child: ClipRRect(
                      child: Padding(
                        child: Row(
                          children: [
                            Flexible(
                                child: TextField(
                              controller: tc,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  hintText: "Type your message...",
                                  helperText: "     < ${manafee.data} Mana"),
                              minLines: 1,
                              maxLines: 5,
                              keyboardType: TextInputType.name,
                              maxLength: 1024,
                              onSubmitted: (v) {
                                if (send()) {
                                  tc.text = "";
                                }
                              },
                            )),
                            Flexible(
                                child: IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: () {
                                      if (send()) {
                                        tc.text = "";
                                      }
                                    }),
                                flex: 0)
                          ],
                        ),
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void beginListening() {
    ArcaneConnect.getContract().onMessageSingle(widget.wallet, widget.recipient,
        (msg) {
      setState(() {
        messages.add(msg);
      });
      beginListening();
    });
  }
}
