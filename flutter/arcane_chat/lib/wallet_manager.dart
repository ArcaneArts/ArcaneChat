import 'dart:math';

import 'package:arcane_chat/arcane_storage.dart';
import 'package:arcane_chat/satchel.dart';
import 'package:web3dart/credentials.dart';

class WalletManager {
  static List<Satchel> getSatchels() {
    List<Satchel> s = List<Satchel>();

    ArcaneStorage.getWallets().values.forEach((element) {
      try {
        s.add(Satchel.fromJson(element));
      } catch (e) {}
    });

    return s;
  }

  static void setSatchel(Satchel s) {
    ArcaneStorage.getWallets().put(s.id, s.toJsonString());
  }

  static Satchel getSatchel(String id) {
    return Satchel.fromJson(ArcaneStorage.getWallets().get(id));
  }

  static Future<Wallet> generate(List<int> seedlings, String password) async {
    int c = seedlings.length;
    int ma = 9223372036854775807;
    int mi = -9223372036854775808;
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
      for (int j = 0; j < i + 1; j++) {
        g = rx.nextInt(7) + 32 - rx2.nextInt(18);
        z += rbuf.nextInt(ma) % 2 == 0 ? rx.nextInt(ma) : rx.nextInt(mi);
        z += rbufx.nextInt(ma) % 2 == 0 ? rx2.nextInt(ma) : rx2.nextInt(mi);

        for (int k = 0; k < g; k++) {
          rx.nextDouble();
          rx2.nextBool();
          x += rx.nextInt(24 * k) + 1 + rx2.nextInt(k);
          z += rbuf.nextInt(ma) % 2 == 0 ? rx.nextInt(ma) : rx.nextInt(mi);
          z += rbufx.nextInt(ma) % 2 == 0 ? rx2.nextInt(ma) : rx2.nextInt(mi);
        }

        x += rx.nextInt(x + g - c - rx2.nextInt(mi));
        x += rx2.nextInt(x - g + c + rx.nextInt(ma));
        rx = Random(x + c - g + 344956 - z);
        rx2 = Random(z * c + g - 3597 + z);
        z += rbuf.nextInt(ma) % 2 == 0 ? rx.nextInt(ma) : rx.nextInt(mi);
        z += rbufx.nextInt(ma) % 2 == 0 ? rx2.nextInt(ma) : rx2.nextInt(mi);
      }

      rbuf = Random(z + x + c + g + (ma - mi));
      rbufx = Random(x * z - c - g + (ma - mi) * 235);
    }

    return new Wallet.createNew(
        EthPrivateKey.createRandom(rbuf), password, rbufx);
  }
}
