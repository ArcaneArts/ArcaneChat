// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract LoggingTest {
    event nameChangeEvent(address indexed from, string newName);
    event newUserEvent(address indexed from);
    event messageEvent(address indexed from, address indexed to, string message);
    event addContactEvent(address indexed from, address indexed to);
    event acceptContactEvent(address indexed from, address indexed to);
    event declineContactEvent(address indexed from, address indexed to);
    event blockContactEvent(address indexed from, address indexed to);
    event unblockContactEvent(address indexed from, address indexed to);

    enum Relation {
        None,
        OutgoingRequest,
        IncomingRequest,
        Contacts,
        Blocked
    }

    struct User {
        string name;
        bool exists;
    }

    mapping (address => mapping (address => Relation)) relations;
    mapping (address => mapping (address => uint)) lastBlockSend;
    mapping (address => mapping (address => uint)) lastBlockReceive;
    mapping (address => User) users;

    function createUser(string memory name) public
    {
        require(users[msg.sender].exists == false);
        users[msg.sender] = User(name, true);
        emit newUserEvent(msg.sender);
        emit nameChangeEvent(msg.sender, name);
    }

    function changeName(string memory name) public forusers 
    {
        users[msg.sender].name = name;
        emit nameChangeEvent(msg.sender, name);
    }

    function sendMessage(address to, string memory message) public forusers
    {
        require(relations[msg.sender][to] == Relation.Contacts);
        require(relations[to][msg.sender] == Relation.Contacts);
        lastBlockSend[msg.sender][to] = block.number;
        lastBlockReceive[to][msg.sender] = block.number;
        emit messageEvent(msg.sender, to, message);
    }

    function addContact(address a) public forusers 
    {
        require(relations[msg.sender][a] == Relation.None && relations[a][msg.sender] == Relation.None);
        relations[msg.sender][a] = Relation.OutgoingRequest;
        relations[a][msg.sender] = Relation.IncomingRequest;
        emit addContactEvent(msg.sender, a);
    }

    function acceptContact(address a) public forusers
    {
        require(relations[msg.sender][a] == Relation.IncomingRequest && relations[a][msg.sender] == Relation.OutgoingRequest);
        relations[msg.sender][a] = Relation.Contacts;
        relations[a][msg.sender] = Relation.Contacts;
        emit acceptContactEvent(msg.sender, a);
    }

    function declineContact(address a) public forusers
    {
        require(relations[msg.sender][a] == Relation.IncomingRequest && relations[a][msg.sender] == Relation.OutgoingRequest);
        relations[msg.sender][a] = Relation.None;
        relations[a][msg.sender] = Relation.None;
        emit declineContactEvent(msg.sender, a);
    }

    function blockContact(address a) public forusers
    {
        relations[msg.sender][a] = Relation.Blocked;
        relations[a][msg.sender] = Relation.None;
        emit blockContactEvent(msg.sender, a);
    }

    function unblockContact(address a) public forusers
    {
        relations[msg.sender][a] = Relation.None;
        emit unblockContactEvent(msg.sender, a);
    }
    modifier forusers() {
        require(users[msg.sender].exists);
        _;
    }

    function getRelation(address a) public forusers view returns (Relation) {
        return relations[msg.sender][a];
    }

    function getLastSendingBlock(address a) public forusers view returns (uint) {
        return lastBlockSend[msg.sender][a];
    }

    function getLastReceivingBlock(address a) public forusers view returns (uint) {
        return lastBlockReceive[msg.sender][a];
    }

    function getName() public forusers view returns (string memory) {
        return users[msg.sender].name;
    }

    function isUser() public view returns (bool) {
        return users[msg.sender].exists;
    }
}