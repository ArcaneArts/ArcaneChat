import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcane_contractor.dart';
import 'package:arcane_chat/arcane_tx_waiter.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneAddContact extends StatefulWidget {
  final Wallet wallet;
  final Satchel satchel;

  ArcaneAddContact({this.wallet, this.satchel});

  @override
  _ArcaneAddContactState createState() => _ArcaneAddContactState();
}

class _ArcaneAddContactState extends State<ArcaneAddContact> {
  TextEditingController tc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Hero(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Container(
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back),
                          alignment: Alignment.topLeft,
                          onPressed: () => Navigator.pop(context)),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(
                          child: Icon(
                            Icons.person_add_rounded,
                            size: 86,
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            controller: tc,
                            decoration: InputDecoration(
                                hintText: "Contact Address (0x123...abc)"),
                            onChanged: (a) => setState(() {}),
                          ),
                        ),
                        Flexible(
                            child: tc.value.text.length == 42
                                ? FutureBuilder<ArcaneRelationship>(
                                    future: widget.wallet.privateKey
                                        .extractAddress()
                                        .then((value) =>
                                            ArcaneConnect.getContract()
                                                .getRelation(
                                                    value,
                                                    EthereumAddress.fromHex(
                                                        tc.value.text))),
                                    builder: (context, rel) {
                                      if (!rel.hasData) {
                                        return Padding(
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(),
                                          ),
                                          padding: EdgeInsets.all(14),
                                        );
                                      }

                                      if (rel.data == ArcaneRelationship.None) {
                                        return FutureBuilder<bool>(
                                          future: ArcaneConnect.getContract()
                                              .isUser(EthereumAddress.fromHex(
                                                  tc.value.text)),
                                          builder: (context, isuser) {
                                            if (!isuser.hasData) {
                                              return Padding(
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                padding: EdgeInsets.all(14),
                                              );
                                            }

                                            if (!isuser.data) {
                                              return Text("Not an Arcane User");
                                            }

                                            return FutureBuilder<int>(
                                              future:
                                                  ArcaneConnect.getManaFee(),
                                              builder: (context, mana) {
                                                if (!mana.hasData) {
                                                  return Padding(
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    padding: EdgeInsets.all(14),
                                                  );
                                                }
                                                return TextButton(
                                                  child: Text(
                                                    "Add Contact for ${mana.data} Mana",
                                                    style: TextStyle(
                                                        color: tc.value.text
                                                                    .length ==
                                                                42
                                                            ? null
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .subtitle2
                                                                .color
                                                                .withOpacity(
                                                                    0.7)),
                                                  ),
                                                  onPressed: tc.value.text
                                                              .length ==
                                                          42
                                                      ? () => Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ArcaneTxWaiter(
                                                                        waiter:
                                                                            ArcaneConnect.waitForTx(ArcaneConnect.getContract().requestContact(
                                                                          widget
                                                                              .wallet,
                                                                          EthereumAddress.fromHex(tc
                                                                              .value
                                                                              .text),
                                                                        )),
                                                                      ))).then(
                                                              (value) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Added Contact")));
                                                            Navigator.pop(
                                                                context);
                                                          })
                                                      : null,
                                                );
                                              },
                                            );
                                          },
                                        );
                                      } else if (rel.data ==
                                          ArcaneRelationship.IncomingRequest) {
                                        return Text(
                                            "Accept their request instead.");
                                      } else if (rel.data ==
                                          ArcaneRelationship.OutgoingRequest) {
                                        return Text("Already Requested!");
                                      } else if (rel.data ==
                                          ArcaneRelationship.Contacts) {
                                        return Text("Already Contacts!");
                                      }

                                      return Text("Not an Arcane User");
                                    },
                                  )
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ))
                      ])
                    ],
                  ),
                  width: 350,
                ),
              ),
            ),
            tag: "card2",
          ),
        ),
      ),
    );
  }
}
