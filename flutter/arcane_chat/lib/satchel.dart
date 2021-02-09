import 'dart:convert';

import 'package:arcane_chat/lzstring.dart';
import 'package:arcane_chat/wallet_manager.dart';
import 'package:web3dart/web3dart.dart';

class Satchel {
  String id;
  String data;
  String name;

  Satchel({this.id, this.data, this.name});

  static Satchel fromJson(String json) {
    Map<String, dynamic> j = jsonDecode(json);
    return Satchel(data: j["data"], name: j["name"], id: j["id"]);
  }

  static Future<Satchel> createRandom(
      String id, List<int> rng, String password) async {
    Wallet w = await WalletManager.generate(rng, password);
    Satchel s = Satchel(id: id, name: "New Satchel", data: "loading");
    s.setWallet(w);
    return s;
  }

  String toJsonString() =>
      jsonEncode(<String, dynamic>{"data": data, "name": name, "id": id});

  String getEncodedJson() =>
      LZString.decompressFromEncodedURIComponentSync(data);

  void setEncodedJson(String json) =>
      data = LZString.compressToEncodedURIComponentSync(json);

  void setWallet(Wallet wallet) => setEncodedJson(wallet.toJson());

  Wallet getWallet(String password) =>
      Wallet.fromJson(getEncodedJson(), password);
}
