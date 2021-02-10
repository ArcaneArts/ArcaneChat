import 'package:arcane_chat/arcane_connect.dart';
import 'package:arcane_chat/constant.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

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

  Future<String> acceptContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: acceptContactFunction,
              parameters: [user]));

  Future<String> declineContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: declineContactFunction,
              parameters: [user]));

  Future<String> addContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: addContactFunction,
              parameters: [user]));

  Future<String> blockContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: blockContactFunction,
              parameters: [user]));

  Future<String> unblockContact(Wallet me, EthereumAddress user) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: unblockContactFunction,
              parameters: [user]));

  Future<String> changeName(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: changeNameFunction,
              parameters: [name]));

  Future<String> sendMessage(
          Wallet me, EthereumAddress to, String message) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: sendMessageFunction,
              parameters: [to, message]));

  Future<String> createUser(Wallet me, String name) async =>
      ArcaneConnect.connect().sendTransaction(
          me.privateKey,
          Transaction.callContract(
              contract: contract,
              function: createUserFunction,
              parameters: [name]));

  Future<int> getSignupBlock(EthereumAddress me) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getSignupBlockFunction,
          params: [me]).then((value) => int.tryParse(value.toString()) ?? 0);

  Future<int> getLastReceivingBlock(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getLastReceivingBlockFunction,
          params: [
            me,
            other
          ]).then((value) => int.tryParse(value.toString()) ?? 0);

  Future<int> getLastSendingBlock(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getLastSendingBlockFunction,
          params: [
            me,
            other
          ]).then((value) => int.tryParse(value.toString()) ?? 0);

  Future<String> getName(EthereumAddress a) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getNameFunction,
          params: [a]).then((value) => value.toString());

  Future<bool> isUser(EthereumAddress a) async => ArcaneConnect.connect().call(
      contract: contract,
      function: isUserFunction,
      params: [a]).then((value) => value.toString() == "true");

  Future<ArcaneRelationship> getRelation(
          EthereumAddress me, EthereumAddress other) async =>
      ArcaneConnect.connect().call(
          contract: contract,
          function: getRelationFunction,
          params: [
            me,
            other
          ]).then((value) =>
          ArcaneRelationship.values[int.tryParse(value.toString()) ?? 0]);
}
