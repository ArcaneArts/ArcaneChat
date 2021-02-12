import 'package:arcane_chat/arcane_connect.dart';
import 'package:web3dart/web3dart.dart';

class Constant {
  static double MANA_PER_ETH = null;
  static int MANA_WEI_VALUE = null;
  static EtherAmount TIP = null;
  static int TIP_IN_MANA = 0;

  static Future<bool> init() async {
    if (MANA_PER_ETH == null) {
      MANA_WEI_VALUE = await ArcaneConnect.getContract().getManaValue();
      int gwei = EtherAmount.fromUnitAndValue(EtherUnit.wei, MANA_WEI_VALUE)
          .getValueInUnit(EtherUnit.gwei);
      MANA_PER_ETH = 1.0 / (gwei.toDouble() / 1000000000.0);
    }

    if (TIP == null) {
      TIP = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, await await ArcaneConnect.getContract().getTipInWei());
      TIP_IN_MANA = TIP.getValueInUnit(EtherUnit.wei) * MANA_WEI_VALUE;
    }
  }

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
      "0xf5a3D9F98d14F86dB9A3a6D262cfCbC1Fa3a1658";
  static final String CONTRACT_ABI =
      '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"acceptContactEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"addContactEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"declineContactEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"string","name":"message","type":"string"}],"name":"messageEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"string","name":"newName","type":"string"}],"name":"nameChangeEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"}],"name":"newUserEvent","type":"event"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"cipherdata","type":"string"}],"name":"acceptContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"cipherdata","type":"string"}],"name":"addContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"newmage","type":"address"}],"name":"adminAddArchmage","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"mage","type":"address"}],"name":"adminRemoveArchmage","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newmage","type":"address"}],"name":"adminTransferGrandArchmage","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"valueInWei","type":"uint256"}],"name":"adminUpdateManaValue","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"tipInMana","type":"uint256"}],"name":"adminUpdateTip","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"changeName","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"createUser","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"declineContact","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getCipher","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getLastReceivingBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getLastSendingBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getManaValue","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"getName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"},{"internalType":"address","name":"other","type":"address"}],"name":"getRelation","outputs":[{"internalType":"enum ArcaneChat.Relation","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"me","type":"address"}],"name":"getSignupBlock","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatConnections","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatMembers","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStatMessages","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTip","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTipInWei","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"isArchmage","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"isGrandArchmage","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"a","type":"address"}],"name":"isUser","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"string","name":"message","type":"string"}],"name":"sendMessage","outputs":[],"stateMutability":"payable","type":"function"}]';
}
