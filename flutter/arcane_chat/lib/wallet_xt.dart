import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcaneamount.dart';
import 'package:arcane_chat/constant.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

extension WalletXT on Wallet {
  Future<EthereumAddress> getAddress() => this.privateKey.extractAddress();
  EthereumAddress getAddressSync() => EthereumAddress(
      publicKeyToAddress(privateKeyBytesToPublic(this.privateKey.privateKey)));

  Future<EtherAmount> getBalance() =>
      getAddress().then((value) => ArcaneConnect.connect().getBalance(value));

  Future<double> getUSD() => getEther()
      .then((value) => ArcaneConnect.getUSDPrice().then((usd) => usd * value));

  Future<double> getMana() =>
      getEther().then((value) => value * Constant.MANA_PER_ETH);

  Future<double> getEther() => getBalance()
      .then((value) => value.getValueInUnit(EtherUnit.ether).toDouble());

  Future<ArcaneAmount> getArcaneBalance() =>
      getEther().then((value) => ArcaneConnect.getUSDPrice()
          .then((usd) => ArcaneAmount(usdPrice: usd, value: value)));
}
