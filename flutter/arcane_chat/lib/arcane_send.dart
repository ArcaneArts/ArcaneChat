import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/constant.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneSend extends StatefulWidget {
  @override
  _ArcaneSendState createState() => _ArcaneSendState();
}

class _ArcaneSendState extends State<ArcaneSend> {
  TextEditingController tc = TextEditingController();
  TextEditingController tca = TextEditingController();

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
                child: Container(
                  width: 350,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back),
                          alignment: Alignment.topLeft,
                          onPressed: () => Navigator.pop(context)),
                      FutureBuilder<EtherAmount>(
                        future: ArcaneConnect.connect().getGasPrice(),
                        builder: (context, gas) {
                          if (!gas.hasData) {
                            return Container();
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  child: Icon(
                                Icons.send_rounded,
                                size: 86,
                              )),
                              Flexible(
                                  child: TextField(
                                controller: tc,
                                decoration: InputDecoration(
                                    hintText: "Etherium Address"),
                              )),
                              Flexible(
                                  child: TextField(
                                controller: tca,
                                style: TextStyle(fontSize: 48),
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: false, decimal: true),
                                decoration: InputDecoration(
                                    hintText: "0", suffix: Text("Mana")),
                              )),
                              Flexible(
                                  child: ListTile(
                                title: Text("Transaction Fee"),
                                leading: Icon(Icons.attach_money_outlined),
                                subtitle: Text(
                                    "${(gas.data.getValueInUnit(EtherUnit.ether).toDouble() * 21000.0 * Constant.MANA_PER_ETH).toInt()} Mana"),
                              ))
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.all(14),
              ),
            ),
            tag: "card",
          ),
        ),
      ),
    );
  }
}
