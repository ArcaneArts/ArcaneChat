import 'package:arcane_chat/arcane_account_settings.dart';
import 'package:arcane_chat/arcane_add_contact.dart';
import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcane_messenger.dart';
import 'package:arcane_chat/arcane_tx_waiter.dart';
import 'package:arcane_chat/arcane_unlocker.dart';
import 'package:arcane_chat/arcane_wallet_view.dart';
import 'package:arcane_chat/arcaneamount.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:arcane_chat/wallet_xt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneView extends StatefulWidget {
  final Satchel satchel;
  final Wallet wallet;

  ArcaneView({this.satchel, this.wallet});

  @override
  _ArcaneViewState createState() => _ArcaneViewState();
}

class _ArcaneViewState extends State<ArcaneView> {
  bool waitingForTx = false;
  bool load = false;
  bool member = false;
  double prog = 0;
  double prog2 = 0;
  int fee = 0;
  List<EthereumAddress> contactRequests;
  List<EthereumAddress> contacts;

  Widget buildMember(BuildContext context) {
    member = true;
    if (!load) {
      load = true;
      ArcaneConnect.getManaFee().then((valuef) {
        fee = valuef.toInt();
        return ArcaneConnect.getContract()
            .getContactRequests(
                widget.wallet,
                (progress) => setState(() {
                      prog = progress;
                    }))
            .then((value) => contactRequests = value)
            .then((valuef) => ArcaneConnect.getContract()
                .getContacts(
                    widget.wallet,
                    (progress) => setState(() {
                          prog2 = progress;
                        }))
                .then((value) => contacts = value))
            .then((value) => setState(() {}));
      });
    }

    if (contactRequests != null && contacts != null) {
      return ListView(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, pos) => FutureBuilder<String>(
                    future: ArcaneConnect.getContract().getName(contacts[pos]),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return Container(
                          height: 0,
                        );
                      }
                      return ListTile(
                        title:
                            Text(snap.data.substring(1, snap.data.length - 1)),
                        leading: Icon(Icons.person),
                        subtitle: Text("0 Messages"),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArcaneMessenger(
                                      wallet: widget.wallet,
                                      satchel: widget.satchel,
                                      recipient: contacts[pos],
                                      recipientName: snap.data
                                          .substring(1, snap.data.length - 1),
                                    ))),
                      );
                    },
                  )),
          ListView.builder(
              shrinkWrap: true,
              itemCount: contactRequests.length,
              itemBuilder: (context, pos) => ListTile(
                    title: FutureBuilder<String>(
                      future: ArcaneConnect.getContract()
                          .getName(contactRequests[pos]),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return Text("...");
                        }
                        return Text(
                            snap.data.substring(1, snap.data.length - 1));
                      },
                    ),
                    leading: Icon(Icons.person_add_rounded),
                    subtitle: Text("Contact Request"),
                    trailing: TextButton(
                      child: Text("Accept for $fee Mana"),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArcaneTxWaiter(
                                    waiter: ArcaneConnect.waitForTx(
                                        ArcaneConnect.getContract()
                                            .acceptContact(
                                                widget.wallet,
                                                contactRequests[pos],
                                                "nocipher")),
                                  ))).then((value) => setState(() {
                            load = false;
                            member = false;
                            prog = 0;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Accept Contact Request")));
                          })),
                    ),
                  ))
        ],
      );
    }

    return Container(
      child: CircularProgressIndicator(
        value: prog / 2,
      ),
      width: 150,
      height: 150,
    );
  }

  @override
  Widget build(BuildContext context) {
    ArcaneSatchelUnlocker.walletCache[widget.satchel.id] = widget.wallet;
    NumberFormat nf = NumberFormat();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        tooltip: "Add Contact",
        heroTag: "card2",
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ArcaneAddContact(
                      wallet: widget.wallet,
                      satchel: widget.satchel,
                    ))),
      ),
      body: member
          ? Center(
              child: buildMember(context),
            )
          : waitingForTx
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                            width: 300,
                            height: 300,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 86,
                              ),
                              Padding(
                                padding: EdgeInsets.all(7),
                                child: Text(
                                  "Joining Arcane",
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              Text(
                                "Waiting on the Arch Mage...",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : FutureBuilder<bool>(
                  future: widget.wallet.privateKey.extractAddress().then(
                      (value) => ArcaneConnect.getContract().isUser(value)),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snap.data) {
                      return Center(
                        child: buildMember(context),
                      );
                    } else {
                      return FutureBuilder<int>(
                        future: ArcaneConnect.getManaFee(),
                        builder: (context, minmana) {
                          if (!minmana.hasData) {
                            return Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return FutureBuilder<ArcaneAmount>(
                            future: widget.wallet.getArcaneBalance(),
                            builder: (context, bal) {
                              if (!bal.hasData) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (bal.data.getMana().toInt() < minmana.data) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_fix_off,
                                          size: 86,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(7),
                                          child: Text(
                                            "Insufficient Mana",
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                        Text(
                                          "Please deposit at least ${nf.format(minmana.data)} Mana to start using the Arcane!",
                                          textAlign: TextAlign.center,
                                        ),
                                        TextButton(
                                          child: Text("Check again"),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_fix_high,
                                        size: 86,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 7),
                                        child: Text(
                                          "Join the Arcane",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () => setState(() {
                                                waitingForTx = true;
                                                ArcaneConnect.waitForTx(
                                                        ArcaneConnect
                                                                .getContract()
                                                            .becomeMage(
                                                                widget.wallet,
                                                                widget.satchel
                                                                    .name))
                                                    .then((value) {
                                                  setState(() {
                                                    waitingForTx = false;
                                                  });
                                                  if (!value) {}
                                                });
                                              }),
                                          child: Text(
                                              "Spend ${nf.format(minmana.data)} Mana"))
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
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
