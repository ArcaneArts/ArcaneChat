import 'dart:async';
import 'dart:math';

import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

typedef BlockWalkerProgress(double progress);

enum ArcaneRelationship {
  None,
  OutgoingRequest,
  IncomingRequest,
  Contacts,
  Blocked
}

class ArcaneContract {
  DeployedContract contract;
  ContractEvent nameChangeEvent;
  ContractEvent newUserEvent;
  ContractEvent messageEvent;
  ContractEvent addContactEvent;
  ContractEvent acceptContactEvent;
  ContractEvent declineContactEvent;
  ContractEvent blockContactEvent;
  ContractEvent unblockContactEvent;
  ContractFunction createUserFunction;
  ContractFunction changeNameFunction;
  ContractFunction sendMessageFunction;
  ContractFunction addContactFunction;
  ContractFunction acceptContactFunction;
  ContractFunction declineContactFunction;
  ContractFunction blockContactFunction;
  ContractFunction unblockContactFunction;
  ContractFunction getRelationFunction;
  ContractFunction isUserFunction;
  ContractFunction getNameFunction;
  ContractFunction getSignupBlockFunction;
  ContractFunction getLastSendingBlockFunction;
  ContractFunction getLastReceivingBlockFunction;

  static ArcaneContract connect() {
    ArcaneContract c = ArcaneContract()
      ..contract = DeployedContract(
          ContractAbi.fromJson(Constant.CONTRACT_ABI, 'Arcane'),
          EthereumAddress.fromHex(Constant.CONTRACT_ADDRESS));
    c.nameChangeEvent = c.contract.event("nameChangeEvent");
    c.newUserEvent = c.contract.event("newUserEvent");
    c.messageEvent = c.contract.event("messageEvent");
    c.addContactEvent = c.contract.event("addContactEvent");
    c.acceptContactEvent = c.contract.event("acceptContactEvent");
    c.declineContactEvent = c.contract.event("declineContactEvent");
    c.blockContactEvent = c.contract.event("blockContactEvent");
    c.unblockContactEvent = c.contract.event("unblockContactEvent");
    c.createUserFunction = c.contract.function("createUser");
    c.changeNameFunction = c.contract.function("changeName");
    c.sendMessageFunction = c.contract.function("sendMessage");
    c.getNameFunction = c.contract.function("getName");
    c.isUserFunction = c.contract.function("isUser");
    c.addContactFunction = c.contract.function("addContact");
    c.acceptContactFunction = c.contract.function("acceptContact");
    c.declineContactFunction = c.contract.function("declineContact");
    c.blockContactFunction = c.contract.function("blockContact");
    c.unblockContactFunction = c.contract.function("unblockContact");
    c.getRelationFunction = c.contract.function("getRelation");
    c.getSignupBlockFunction = c.contract.function("getSignupBlock");
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

  Future<List<EthereumAddress>> getContactRequests(
      Wallet w, BlockWalkerProgress p) async {
    EthereumAddress addr = await w.privateKey.extractAddress();
    int start = await getSignupBlock(addr);
    List<EthereumAddress> addrs = List<EthereumAddress>();
    Completer<List<EthereumAddress>> c = Completer();
    streamLogs(
        FilterOptions.events(
            contract: contract,
            event: addContactEvent,
            fromBlock: BlockNum.exact(start),
            toBlock: BlockNum.current()),
        p,
        () => c.complete(addrs)).listen((event) {
      List<dynamic> data =
          addContactEvent.decodeResults(event.topics, event.data);
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

  Future<String> acceptContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: acceptContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> declineContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: declineContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> addContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: addContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> blockContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: blockContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> unblockContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: unblockContactFunction,
              parameters: [user]),
          chainId: Constant.CHAIN_ID);

  Future<String> changeName(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: changeNameFunction,
              parameters: [name]),
          chainId: Constant.CHAIN_ID);

  Future<String> sendMessage(
          Wallet me, EthereumAddress to, String message) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: sendMessageFunction,
              parameters: [to, message]),
          chainId: Constant.CHAIN_ID);

  Future<String> createUser(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              maxGas: Constant.GAS_LIMIT_SEND.toInt(),
              gasPrice: await ArcaneConnect.connect().getGasPrice(),
              contract: contract,
              function: createUserFunction,
              parameters: [name]),
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

  Future<String> getName(EthereumAddress a) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getNameFunction,
          params: [a]).then((value) => value.toString());

  Future<bool> isUser(EthereumAddress a) async => ArcaneConnect.connect().call(
      contract: contract,
      function: isUserFunction,
      params: [a]).then((value) => value[0] as bool);

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
