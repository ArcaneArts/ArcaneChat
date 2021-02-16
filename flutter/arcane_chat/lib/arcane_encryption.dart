import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/lzstring.dart';
import 'package:arcane_chat/wallet_xt.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:web3dart/credentials.dart';

class ArcaneEncryption {
  static Future<String> publicKeyFor(Wallet wallet, EthereumAddress to) async =>
      encodePublicKey(
          (await compute(getRsaKeyPair, <dynamic>[wallet, to])).publicKey);

  static String encodePublicKey(RSAPublicKey publicKey) =>
      Base64Codec.urlSafe().encode((ASN1Sequence()
            ..add(ASN1Integer(publicKey.modulus))
            ..add(ASN1Integer(publicKey.exponent)))
          .encodedBytes);

  static RSAPublicKey decodePublicKey(String asn) {
    if (asn.startsWith("[")) {
      asn = asn.substring(1, asn.length - 1);
    }

    ASN1Sequence a = ASN1Sequence.fromBytes(Base64Codec.urlSafe().decode(asn));
    return RSAPublicKey((a.elements[0] as ASN1Integer).valueAsBigInteger,
        (a.elements[1] as ASN1Integer).valueAsBigInteger);
  }

  static String encrypt(RSAPublicKey key, String data) {
    return Base64Codec.urlSafe()
        .encode(_encryptRaw(key, Uint8List.fromList(data.codeUnits)));
  }

  static String decrypt(RSAPrivateKey key, String data) {
    return String.fromCharCodes(
        _decryptRaw(key, Base64Codec.urlSafe().decode(data)));
  }

  static Uint8List _encryptRaw(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

    return _processInBlocks(encryptor, dataToEncrypt);
  }

  static Uint8List _decryptRaw(RSAPrivateKey myPrivate, Uint8List cipherText) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false,
          PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

    return _processInBlocks(decryptor, cipherText);
  }

  static Uint8List _processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }

  static String hashSha512(String msg) =>
      sha512.convert(msg.codeUnits).toString();

  static String hashSha256(String msg) =>
      sha256.convert(msg.codeUnits).toString();
}

AsymmetricKeyPair<PublicKey, PrivateKey> getRsaKeyPair(List<dynamic> data) {
  Wallet from = data[0];
  EthereumAddress to = data[1];
  String h = sha512
      .convert((Base64Codec.urlSafe().encode(from.privateKey.privateKey) +
              to.hex +
              from.uuid)
          .codeUnits)
      .toString();
  List<int> m = h.codeUnits;

  Random rng = Random(129496666);

  for (int i = 0; i < m.length; i++) {
    rng = Random(rng.nextInt(8192 + i) * (i ~/ 32));
  }

  FortunaRandom secureRandom = FortunaRandom();
  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(rng.nextInt(255));
  }
  secureRandom.seed(new KeyParameter(Uint8List.fromList(seeds)));
  var rsapars = new RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 5);
  var params = new ParametersWithRandom(rsapars, secureRandom);
  var keyGenerator = new RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}

Future<Messenger> createMessenger(
    Wallet wallet, EthereumAddress recipient) async {
  AsymmetricKeyPair<PublicKey, PrivateKey> pair =
      await compute(getRsaKeyPair, <dynamic>[wallet, recipient]);
  EthereumAddress sender = wallet.getAddressSync();
  return Messenger()
    .._wallet = wallet
    .._recipient = recipient
    .._keypair = pair
    .._sender = sender
    .._recipientPublicKey = ArcaneEncryption.decodePublicKey(
        await ArcaneConnect.getContract().getCipher(sender, recipient));
}

class Messenger {
  Wallet _wallet;
  EthereumAddress _sender;
  EthereumAddress _recipient;
  RSAPublicKey _recipientPublicKey;
  AsymmetricKeyPair<PublicKey, PrivateKey> _keypair;

  static Future<Messenger> of(Wallet wallet, EthereumAddress recipient) async {
    return createMessenger(wallet, recipient);
  }

  // Receiver read
  String pullLeft(String data) {
    String encrypted = LZString.decompressFromEncodedURIComponentSync(data);
    String left = encrypted.substring(0, encrypted.length ~/ 2);
    String msg = ArcaneEncryption.decrypt(_keypair.privateKey, left);
    return msg.startsWith("l=") ? msg.substring(2) : "Error Decrypting: $msg";
  }

  // Sender read
  String pullRight(String data) {
    String encrypted = LZString.decompressFromEncodedURIComponentSync(data);
    String right = encrypted.substring(encrypted.length ~/ 2);
    String msg = ArcaneEncryption.decrypt(_keypair.privateKey, right);
    return msg.startsWith("r=") ? msg.substring(2) : "Error Decrypting: $msg";
  }

  String push(String message) => LZString.compressToEncodedURIComponentSync(
      ArcaneEncryption.encrypt(_recipientPublicKey, "l=" + message) +
          ArcaneEncryption.encrypt(_keypair.publicKey, "r=" + message));
}
