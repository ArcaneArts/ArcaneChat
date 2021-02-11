import 'package:web3dart/credentials.dart';

class ArcaneMessage {
  EthereumAddress sender;
  EthereumAddress recipient;
  String message;
  bool pending = false;
}
