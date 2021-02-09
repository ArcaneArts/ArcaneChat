import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(Arcane());
}

class Constant {
  static final String endpoint =
      "https://kovan.infura.io/v3/a7c468d6a0914a10a94705cd83eddcf3";
}

class Arcane extends StatefulWidget {
  Arcane({Key key}) : super(key: key);

  @override
  _ArcaneState createState() => _ArcaneState();
}

class _ArcaneState extends State<Arcane> {
  Wallet wallet;
  Client c;
  Web3Client wc;
  Credentials credentials;
  String exactAddress;

  Future<bool> setup() async {
    wallet = Wallet.fromJson(
        '{"version":3,"id":"2fbf0f5a-610c-45b2-8fd0-e6780acc0b2f","address":"908d4cba13452631da25b8b2b17896dd060815cb","crypto":{"ciphertext":"1a71a3cd5af3b35a9995d4787b231895062df0a41bb3cf0fae75930ac49d0573","cipherparams":{"iv":"533ef70a636f578099115431cc7d94f6"},"cipher":"aes-128-ctr","kdf":"scrypt","kdfparams":{"dklen":32,"salt":"c40edd1a1e33e85ee1501e5670e971f6054c8b2fe81bc07fc390f25f6fbf81bf","n":8192,"r":8,"p":1},"mac":"811901eb3cead45f85c268d1cad64c47b741a129ffc191e9399407eaf3a38ee2"}}',
        "(*Qz12311232)");
    c = Client();
    wc = Web3Client(Constant.endpoint, c);
    EthereumAddress a = (await wallet.privateKey.extractAddress());
    exactAddress = a.hex;
    credentials = await wc.credentialsFromPrivateKey(exactAddress);
    EtherAmount amt = await wc.getBalance(a);
    print("Address: ${a.hex}");
    print("Value: ${amt.getValueInUnit(EtherUnit.ether)}");
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arcane",
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light)),
          primaryColor: Color(0xFF422fbd)),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Arcane"),
        ),
        body: FutureBuilder<bool>(
          future: setup(),
          builder: (context, snap) {
            Size s = MediaQuery.of(context).size;
            double w = min(s.width, s.height);
            if (!snap.hasData) {
              return Center(
                child: Container(
                  width: w / 3,
                  height: w / 3,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Text(exactAddress);
          },
        ),
      ),
    );
  }
}
