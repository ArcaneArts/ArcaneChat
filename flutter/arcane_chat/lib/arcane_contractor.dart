import 'dart:async';
import 'dart:math';

import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/arcane_message.dart';
import 'package:arcane_chat/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

typedef BlockWalkerProgress(double progress);

typedef MessageCallback(ArcaneMessage msg);

enum ArcaneRelationship { None, OutgoingRequest, IncomingRequest, Contacts }

class ArcaneContract {
  DeployedContract contract;
  ContractEvent nameChangeEvent;
  ContractEvent newMageEvent;
  ContractEvent messageEvent;
  ContractEvent requestContactEvent;
  ContractEvent acceptContactEvent;
  ContractEvent declineContactEvent;
  ContractFunction becomeMageFunction;
  ContractFunction changeNameFunction;
  ContractFunction sendMessageFunction;
  ContractFunction requestContactFunction;
  ContractFunction acceptContactFunction;
  ContractFunction declineContactFunction;
  ContractFunction getRelationFunction;
  ContractFunction isUserFunction;
  ContractFunction getNameFunction;
  ContractFunction getCipherFunction;
  ContractFunction getSignupBlockFunction;
  ContractFunction getLastSendingBlockFunction;
  ContractFunction getLastReceivingBlockFunction;
  ContractFunction getManaValueFunction;
  ContractFunction getTipFunction;
  ContractFunction getTipInWeiFunction;
  ContractFunction getStatMessagesFunction;
  ContractFunction getStatUsersFunction;
  ContractFunction getStatConnectionsFunction;
  ContractFunction isGrandArchmageFunction;
  ContractFunction adminTransferGrandArchmageFunction;
  ContractFunction adminUpdateManaValueFunction;
  ContractFunction adminUpdateTipFunction;

  static ArcaneContract connect() {
    ArcaneContract c = ArcaneContract()
      ..contract = DeployedContract(
          ContractAbi.fromJson(Constant.CONTRACT_ABI, 'Arcane'),
          EthereumAddress.fromHex(Constant.CONTRACT_ADDRESS));
    c.nameChangeEvent = c.contract.event("nameChangeEvent");
    c.newMageEvent = c.contract.event("newMageEvent");
    c.messageEvent = c.contract.event("messageEvent");
    c.requestContactEvent = c.contract.event("requestContactEvent");
    c.acceptContactEvent = c.contract.event("acceptContactEvent");
    c.declineContactEvent = c.contract.event("declineContactEvent");
    c.getStatMessagesFunction = c.contract.function("getStatMessages");
    c.getStatUsersFunction = c.contract.function("getStatUsers");
    c.getStatConnectionsFunction = c.contract.function("getStatConnections");
    c.becomeMageFunction = c.contract.function("becomeMage");
    c.changeNameFunction = c.contract.function("changeName");
    c.sendMessageFunction = c.contract.function("sendMessage");
    c.getManaValueFunction = c.contract.function("getManaValue");
    c.getTipFunction = c.contract.function("getTip");
    c.getTipInWeiFunction = c.contract.function("getTipInWei");
    c.getNameFunction = c.contract.function("getName");
    c.isUserFunction = c.contract.function("isUser");
    c.requestContactFunction = c.contract.function("requestContact");
    c.acceptContactFunction = c.contract.function("acceptContact");
    c.declineContactFunction = c.contract.function("declineContact");
    c.getRelationFunction = c.contract.function("getRelation");
    c.getCipherFunction = c.contract.function("getCipher");
    c.getSignupBlockFunction = c.contract.function("getSignupBlock");
    c.isGrandArchmageFunction = c.contract.function("isGrandArchmage");
    c.adminTransferGrandArchmageFunction =
        c.contract.function("adminTransferGrandArchmage");
    c.adminUpdateManaValueFunction =
        c.contract.function("adminUpdateManaValue");
    c.adminUpdateTipFunction = c.contract.function("adminUpdateTip");
    c.getLastSendingBlockFunction = c.contract.function("getLastSendingBlock");
    c.getLastReceivingBlockFunction =
        c.contract.function("getLastReceivingBlock");
    return c;
  }

  Future<int> getBlockNumber(BlockNum n) async {
    if (n.useAbsolute) {
      return n.blockNum;
    }

    if (n.blockNum == 0) {
      return 1;
    }

    if (n.blockNum == 1) {
      int m = await ArcaneConnect.connect().getBlockNumber();
      print("Current Block Number is $m");
      return m;
    }

    return n.blockNum;
  }

  Future<List<EthereumAddress>> getContacts(
      Wallet w, BlockWalkerProgress p) async {
    EthereumAddress addr = await w.privateKey.extractAddress();
    int start = await getSignupBlock(addr);
    List<EthereumAddress> addrs = List<EthereumAddress>();
    Completer<List<EthereumAddress>> c = Completer();
    streamLogs(
        FilterOptions.events(
            contract: contract,
            event: acceptContactEvent,
            fromBlock: BlockNum.exact(start),
            toBlock: BlockNum.current()),
        p,
        () => c.complete(addrs)).listen((event) {
      List<dynamic> data =
          acceptContactEvent.decodeResults(event.topics, event.data);
      EthereumAddress from = data[0] as EthereumAddress;
      EthereumAddress to = data[1] as EthereumAddress;

      if (addr.hex == from.hex) {
        addrs.add(to);
      } else if (addr.hex == to.hex) {
        addrs.add(from);
      }
    });

    List<EthereumAddress> v = await c.future;
    List<EthereumAddress> a = List<EthereumAddress>();

    for (int i = 0; i < v.length; i++) {
      if ((await getRelation(addr, v[i])) == ArcaneRelationship.Contacts) {
        a.add(v[i]);
      }
    }

    return a;
  }

  Future<void> onMessageSingle(
      Wallet w, EthereumAddress otherMember, MessageCallback cb) async {
    EthereumAddress addr = await w.privateKey.extractAddress();

    ArcaneConnect.connect()
        .events(FilterOptions.events(contract: contract, event: messageEvent))
        .where((event) {
          List<dynamic> data =
              messageEvent.decodeResults(event.topics, event.data);
          EthereumAddress from = data[0] as EthereumAddress;
          EthereumAddress to = data[1] as EthereumAddress;
          String message = data[2] as String;

          if ((from.hex == otherMember.hex && to.hex == addr.hex)) {
            return true;
          }
          return false;
        })
        .take(1)
        .map((event) {
          List<dynamic> data =
              messageEvent.decodeResults(event.topics, event.data);
          EthereumAddress from = data[0] as EthereumAddress;
          EthereumAddress to = data[1] as EthereumAddress;
          String message = data[2] as String;
          return ArcaneMessage()
            ..recipient = to
            ..sender = from
            ..message = message;
        })
        .listen((event) {
          cb(event);
        });
  }

  Future<Stream<ArcaneMessage>> getMessages(
      Wallet w, EthereumAddress otherMember, BlockWalkerProgress p) async {
    EthereumAddress addr = await w.privateKey.extractAddress();
    int start1 = await getSignupBlock(addr);
    int start2 = await getSignupBlock(otherMember);
    List<ArcaneMessage> messages = List<ArcaneMessage>();
    Completer<List<ArcaneMessage>> c = Completer();
    return streamLogs(
        FilterOptions.events(
            contract: contract,
            event: messageEvent,
            fromBlock: BlockNum.exact(min(start1, start2)),
            toBlock: BlockNum.current()),
        p,
        () => c.complete(messages)).where((event) {
      List<dynamic> data = messageEvent.decodeResults(event.topics, event.data);
      EthereumAddress from = data[0] as EthereumAddress;
      EthereumAddress to = data[1] as EthereumAddress;
      String message = data[2] as String;

      if ((from.hex == otherMember.hex && to.hex == addr.hex) ||
          (to.hex == otherMember.hex && from.hex == addr.hex)) {
        return true;
      }
      return false;
    }).map((event) {
      List<dynamic> data = messageEvent.decodeResults(event.topics, event.data);
      EthereumAddress from = data[0] as EthereumAddress;
      EthereumAddress to = data[1] as EthereumAddress;
      String message = data[2] as String;
      return ArcaneMessage()
        ..recipient = to
        ..sender = from
        ..message = message;
    });
  }

  Future<List<EthereumAddress>> getContactRequests(
      Wallet w, BlockWalkerProgress p) async {
    EthereumAddress addr = await w.privateKey.extractAddress();
    int start = await getSignupBlock(addr);
    List<EthereumAddress> addrs = List<EthereumAddress>();
    Completer<List<EthereumAddress>> c = Completer();
    streamLogs(
        FilterOptions.events(
            contract: contract,
            event: requestContactEvent,
            fromBlock: BlockNum.exact(start),
            toBlock: BlockNum.current()),
        p,
        () => c.complete(addrs)).listen((event) {
      List<dynamic> data =
          requestContactEvent.decodeResults(event.topics, event.data);
      EthereumAddress from = data[0] as EthereumAddress;
      EthereumAddress to = data[1] as EthereumAddress;

      if (to.hex == addr.hex) {
        addrs.add(from);
      }
    });

    List<EthereumAddress> v = await c.future;
    List<EthereumAddress> a = List<EthereumAddress>();

    for (int i = 0; i < v.length; i++) {
      if ((await getRelation(addr, v[i])) ==
          ArcaneRelationship.IncomingRequest) {
        a.add(v[i]);
      }
    }

    return a;
  }

  Stream<FilterEvent> streamLogs(
      FilterOptions options, BlockWalkerProgress p, VoidCallback done) async* {
    p(0);
    int start = await getBlockNumber(options.fromBlock);
    int end = await getBlockNumber(options.toBlock);

    if ((end - start) ~/ Constant.BLOCK_WALK_BATCH_SIZE > 1) {
      for (int i = start; i < end; i += Constant.BLOCK_WALK_BATCH_SIZE) {
        p((i - start) / (end - start).ceilToDouble());
        int a = i;
        int b = min(i + Constant.BLOCK_WALK_BATCH_SIZE - 1, end);
        List<FilterEvent> evt = await ArcaneConnect.connect().getLogs(
            FilterOptions(
                address: options.address,
                topics: options.topics,
                fromBlock: BlockNum.exact(a),
                toBlock: BlockNum.exact(b)));
        for (int i = 0; i < evt.length; i++) {
          yield evt[i];
        }
      }
      p(1);
    } else {
      p(1);
      List<FilterEvent> evt = await ArcaneConnect.connect().getLogs(options);
      for (int i = 0; i < evt.length; i++) {
        yield evt[i];
      }
    }

    done();
  }

  Future<String> acceptContact(
          Wallet me, EthereumAddress user, String cipher) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: acceptContactFunction,
              parameters: [user, cipher]),
          chainId: Constant.CHAIN_ID);

  Future<String> declineContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: declineContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> requestContact(
          Wallet me, EthereumAddress user, String cipher) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: requestContactFunction,
              parameters: [user, cipher]),
          chainId: Constant.CHAIN_ID);

  Future<String> changeName(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: changeNameFunction,
              parameters: [name]),
          chainId: Constant.CHAIN_ID);

  Future<String> sendMessage(
          Wallet me, EthereumAddress to, String message, int nonce) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              nonce: nonce,
              function: sendMessageFunction,
              parameters: [to, message]),
          chainId: Constant.CHAIN_ID);

  Future<String> becomeMage(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              value: Constant.TIP,
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: becomeMageFunction,
              parameters: [name]),
          chainId: Constant.CHAIN_ID);

  Future<String> adminTransferGrandArchmage(
          Wallet me, EthereumAddress newmage) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: adminTransferGrandArchmageFunction,
              parameters: [newmage]),
          chainId: Constant.CHAIN_ID);

  Future<String> adminUpdateManaValue(Wallet me, int valueInWei) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: adminUpdateManaValueFunction,
              parameters: [valueInWei]),
          chainId: Constant.CHAIN_ID);

  Future<String> adminUpdateTip(Wallet me, int tipInMana) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: adminUpdateTipFunction,
              parameters: [tipInMana]),
          chainId: Constant.CHAIN_ID);

  Future<int> getSignupBlock(EthereumAddress me) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getSignupBlockFunction,
          params: [me]).then((value) => (value[0] as BigInt).toInt());

  Future<int> getLastReceivingBlock(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getLastReceivingBlockFunction,
          params: [me, other]).then((value) => (value[0] as BigInt).toInt());

  Future<int> getLastSendingBlock(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getLastSendingBlockFunction,
          params: [me, other]).then((value) => (value[0] as BigInt).toInt());

  Future<int> getManaValue() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getManaValueFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<int> getTip() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getTipFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<int> getTipInWei() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getTipInWeiFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<int> getStatMessages() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getStatMessagesFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<int> getStatConnections() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getStatConnectionsFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<int> getStatUsers() async => ArcaneConnect.connect().call(
      contract: contract,
      function: getStatUsersFunction,
      params: []).then((value) => (value[0] as BigInt).toInt());

  Future<String> getName(EthereumAddress a) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getNameFunction,
          params: [a]).then((value) => value.toString());

  Future<bool> isUser(EthereumAddress a) async => ArcaneConnect.connect().call(
      contract: contract,
      function: isUserFunction,
      params: [a]).then((value) => value[0] as bool);

  Future<bool> isGrandArchmage(EthereumAddress a) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: isGrandArchmageFunction,
          params: [a]).then((value) => value[0] as bool);

  Future<String> getCipher(EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getCipherFunction,
          params: [me, other]).then((value) => value.toString());

  Future<ArcaneRelationship> getRelation(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getRelationFunction,
          params: [
            me,
            other
          ]).then(
          (value) => ArcaneRelationship.values[(value[0] as BigInt).toInt()]);
}
