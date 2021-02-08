import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/credentials.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(Arcane());
}

class Constant
{
  static final String endpoint = "https://goerli.infura.io/v3/a7c468d6a0914a10a94705cd83eddcf3";
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

  Future<bool> setup() async
  {
    EthereumAddress a = (await wallet.privateKey.extractAddress());
    exactAddress = a.hex;
    credentials = await wc.credentialsFromPrivateKey(exactAddress);
    
    EtherAmount amt =await wc.getBalance(a);
    print("Address: ${a.hex}");
    print("Value: ${amt.getValueInUnit(EtherUnit.ether)}");
    return true;
  }

  @override
  void initState() {
    super.initState();
    wallet = Wallet.createNew(EthPrivateKey.createRandom(Random(1337)), "1337", Random(1337));
    c  = Client();
    wc = Web3Client(Constant.endpoint, c);
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arcane",
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light
          )
        ),
        primaryColor: Color(0xFF422fbd)
      ),
      home: Scaffold(appBar: AppBar(
        title: Text("Arcane"),
      ), body: FutureBuilder<bool>(
        future: setup(),
        builder: (context, snap) {
    Size s =  MediaQuery.of(context).size;
    double w = min(s.width, s.height);
          if(!snap.hasData)
          { 
            return Center(
            child: Container(width: w/3, height: w/3, child: CircularProgressIndicator(

            ),),
          );
          }

          return Text(exactAddress);
        },
      ),),
    );
  }
}
