import 'dart:math';

import 'package:arcane_chat/arcane_storage.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:web3dart/credentials.dart';

typedef Progressor(double p);

class WalletManager {
  static List<Satchel> getSatchels() {
    List<Satchel> s = List<Satchel>();

    ArcaneStorage.getWallets().values.forEach((element) {
      try {
        Satchel ss = Satchel.fromJson(element);

        if (ss.data == null) {
          print("Null data for satchel $element. Ignoring.");
          return;
        }

        s.add(ss);
      } catch (e) {}
    });

    return s;
  }

  static void setSatchel(Satchel s) {
    ArcaneStorage.getWallets().put(s.id, s.toJsonString());
    print("Saved " + s.toJsonString());
  }

  static Satchel getSatchel(String id) {
    return Satchel.fromJson(ArcaneStorage.getWallets().get(id));
  }

  static Future<Wallet> generate(List<int> seedlings, String password) async {
    int c = seedlings.length;
    int ma = 7;
    int mi = 1;
    int g = 0;
    int x = 0;
    int z = 0;
    Random rbuf = Random(-4483386 * c);
    Random rbufx = Random(83386 + c);
    z += rbuf.nextInt(ma) % 2 == 0 ? rbuf.nextInt(ma) : rbuf.nextInt(mi);

    for (int i = 0; i < c; i++) {
      Random rx = Random((c * i) + c - 495);
      Random rx2 = Random((c * (i * 2)) - c + 415);
      z += rbuf.nextInt(ma) % 2 == 0 ? rx.nextInt(ma) : rx.nextInt(mi);
      z += rbufx.nextInt(ma) % 2 == 0 ? rx2.nextInt(ma) : rx2.nextInt(mi);
      rbuf = Random(z + x + c + g + (ma - mi));
      rbufx = Random(x * z - c - g + (ma - mi) * 235);
    }

    return new Wallet.createNew(
        EthPrivateKey.createRandom(rbuf), password, rbufx);
  }

  static String nextSatchelId() {
    int m = 0;

    while (true) {
      m++;
      String id = "satchel-" + ("s-$m".hashCode).toString();

      if (!ArcaneStorage.getWallets().keys.contains(id)) {
        return id;
      }
    }
  }

  static void deleteSatchel(Satchel satchel) {
    ArcaneStorage.getWallets().delete(satchel.id);
  }
}
