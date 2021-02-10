import 'package:arcane_chat/constant.dart';

class ArcaneAmount {
  double _usdPrice;
  double _value;

  ArcaneAmount({double usdPrice, double value}) {
    _usdPrice = usdPrice;
    _value = value;
  }

  double getMana() => _value * Constant.MANA_PER_ETH;
  double getUsd() => _value * _usdPrice;
  double getEther() => _value;
}
