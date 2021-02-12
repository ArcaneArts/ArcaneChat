import 'dart:convert';

import 'package:arcane_chat/arcane_contractor.dart';
import 'package:arcane_chat/constant.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ArcaneConnect {
  static Web3Client _client;
  static double lastPrice;
  static int lastSpent = 0;

  static ArcaneContract getContract() => ArcaneContract.connect();

  static Future<int> getManaFee() async {
    double gasPrice = (await ArcaneConnect.connect().getGasPrice())
        .getValueInUnit(EtherUnit.gwei)
        .toDouble();
    EtherAmount fee = EtherAmount.fromUnitAndValue(
        EtherUnit.gwei, (gasPrice * Constant.GAS_LIMIT_SEND).toInt());
    return (Constant.MANA_PER_ETH *
                fee.getValueInUnit(EtherUnit.ether).toDouble())
            .toInt() +
        Constant.TIP_IN_MANA;
  }

  static Future<bool> waitForTx(Future<String> f) {
    return f.onError((error, stackTrace) => null).then((value) {
      if (value == null) {
        return false;
      } else {
        return waitForTxHash(value);
      }
    });
  }

  static void reset() {
    _client = null;
  }

  static Web3Client connect() {
    if (_client == null) {
      _client = new Web3Client(Constant.INFURA_API, Client());
    }

    return _client;
  }

  static Future<double> getUSDPrice() async =>
      lastPrice ??
      Client()
          .get(
              "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD&api_key=${Constant.CRYPTO_COMPARE_API_KEY}")
          .then((value) {
        print("Got result ${value.body}");
        return lastPrice = (double.tryParse(
                (jsonDecode(value.body) as Map<String, dynamic>)["USD"]
                    .toString()) ??
            0);
      });

  static Future<bool> waitForTxHash(String value) async {
    TransactionInformation info = await connect()
        .getTransactionByHash(value)
        .onError((error, stackTrace) => null);

    if (info == null) {
      print("Couldnt find Tx $value. Waiting 10s");
      return Future.delayed(Duration(seconds: 10), () => waitForTxHash(value));
    }

    if (info.blockNumber.isPending) {
      print("Couldnt find real block for Tx $value. Waiting 6s");
      return Future.delayed(Duration(seconds: 6), () => waitForTxHash(value));
    }

    int manaSpent = (EtherAmount.fromUnitAndValue(
                    EtherUnit.gwei,
                    (info.gasPrice.getValueInUnit(EtherUnit.gwei).toDouble() *
                            info.gas.toDouble())
                        .toInt())
                .getValueInUnit(EtherUnit.ether)
                .toDouble() *
            Constant.MANA_PER_ETH.toDouble())
        .toInt();
    lastSpent = manaSpent;
    print("Transaction Finished: Spent $manaSpent in fees");

    return true;
  }
}
