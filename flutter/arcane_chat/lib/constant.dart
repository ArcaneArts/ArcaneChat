import 'package:arcane_chat/arcane_connect.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class Constant {
  static double MANA_PER_ETH = null;
  static int MANA_WEI_VALUE = null;
  static EtherAmount TIP = null;
  static int TIP_IN_MANA = 0;

  static Future<bool> init() async {
    if (MANA_PER_ETH == null) {
      MANA_WEI_VALUE =
          (await ArcaneConnect.getContract().getManaValue()).toInt();

      int gwei =
          EtherAmount.fromUnitAndValue(EtherUnit.wei, MANA_WEI_VALUE.toInt())
              .getValueInUnit(EtherUnit.gwei)
              .toInt();
      MANA_PER_ETH = (1.0 / (gwei.toDouble() / 1000000000.0)).ceilToDouble();
    }

    if (TIP == null) {
      TIP = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, await ArcaneConnect.getContract().getTipInWei());
      TIP_IN_MANA = await ArcaneConnect.getContract().getTip();
    }

    NumberFormat nf = NumberFormat();
    print("1 ETH = ${nf.format(MANA_PER_ETH.toInt())} Mana");
    print("Tip is ${nf.format(TIP_IN_MANA)} Mana (" +
        (TIP_IN_MANA.toDouble() / MANA_PER_ETH.toDouble()).toString() +
        " ETH)");
  }

  static int getManaFromEther(EtherAmount a) =>
      (a.getInWei.toDouble() / MANA_WEI_VALUE.toDouble()).round();

  static EtherAmount getEtherFromMana(int mana) =>
      EtherAmount.fromUnitAndValue(EtherUnit.wei, MANA_WEI_VALUE * mana);

  static final int BLOCK_WALK_BATCH_SIZE = 10000; // 4 blocks/m 240 blocks/h
  static final int SEED_BITS = 256;
  static final double GAS_LIMIT_SEND = (300 * 1000).toDouble();
  static final String CRYPTO_COMPARE_API_KEY =
      "1d37c00d2f956ade5ec565c419745e7a08f559a7539c0b666c07b2e7eced81f7";
  static final int CHAIN_ID_KOVAN = 42;
  static final int CHAIN_ID_MAIN = 1;
  static final String INFURA_KOVAN_API =
      "https://kovan.infura.io/v3/a7c468d6a0914a10a94705cd83eddcf3";
  static final String INFURA_API = INFURA_KOVAN_API;
  static final int CHAIN_ID = CHAIN_ID_KOVAN;
  static final String CONTRACT_ADDRESS =
      "0x8a324A7B8B451dF44F258712bB30D31aBa1e099B";
  static final String CONTRACT_ABI =
      '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"acceptContactEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"declineContactEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"string","name":"message","type":"string"}],"name":"messageEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"string","name":"newName","type":"string"}],"name":"nameChangeEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"}],"name":"newMageEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"requestContactEvent","type":"event"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"cipherdata","type":"string"}],"name":"acceptContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"newmage","type":"address"}],"name":"adminTransferGrandArchmage","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"valueInWei","type":"uint256"}],"name":"adminUpdateManaValue","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"tipInMana","type":"uint256"}],"name":"adminUpdateTip","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"becomeMage","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"changeName","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"declineContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getCipher","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getLastReceivingBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getLastSendingBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getManaValue","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"getName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getRelation","outputs":[{"internalType":"enum ArcaneChat.Relation","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"}],"name":"getSignupBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatConnections","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatMessages","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatUsers","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTip","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTipInWei","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"isGrandArchmage","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"isUser","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"cipherdata","type":"string"}],"name":"requestContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"string","name":"message","type":"string"}],"name":"sendMessage","outputs":[],"stateMutability":"payable","type":"function"}]';
}
