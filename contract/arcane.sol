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
        uint signupBlock;
    }

    mapping (address => mapping (address => Relation)) relations;
    mapping (address => mapping (address => uint)) lastBlockSend;
    mapping (address => mapping (address => uint)) lastBlockReceive;
    mapping (address => User) users;

    function createUser(string memory name) public {
        require(users[msg.sender].exists == false, "You are already a member.");
        users[msg.sender] = User(name, true, block.number);
        emit newUserEvent(msg.sender);
        emit nameChangeEvent(msg.sender, name);
        relations[msg.sender][msg.sender] = Relation.Contacts;
    }

    function changeName(string memory name) public forusers {
        users[msg.sender].name = name;
        emit nameChangeEvent(msg.sender, name);
    }

    function sendMessage(address to, string memory message) public forusers {
        require(relations[msg.sender][to] == Relation.Contacts, "the recipient is not in your contacts.");
        require(relations[to][msg.sender] == Relation.Contacts, "the recipient does not have you in your contacts.");
        lastBlockSend[msg.sender][to] = block.number;
        lastBlockReceive[to][msg.sender] = block.number;
        emit messageEvent(msg.sender, to, message);
    }

    function addContact(address user) public forusers  {
        require(relations[msg.sender][user] == Relation.None && relations[user][msg.sender] == Relation.None, "You or the recipient are already contacts, or pending contacts, or blocking.");
        relations[msg.sender][user] = Relation.OutgoingRequest;
        relations[user][msg.sender] = Relation.IncomingRequest;
        emit addContactEvent(msg.sender, user);
    }

    function acceptContact(address user) public forusers {
        require(relations[msg.sender][user] == Relation.IncomingRequest && relations[user][msg.sender] == Relation.OutgoingRequest, "The recipient does not have an outgoing contact request.");
        relations[msg.sender][user] = Relation.Contacts;
        relations[user][msg.sender] = Relation.Contacts;
        emit acceptContactEvent(msg.sender, user);
    }

    function declineContact(address user) public forusers {
        require(relations[msg.sender][user] == Relation.IncomingRequest && relations[user][msg.sender] == Relation.OutgoingRequest, "The recipient does not have an outgoing contact request.");
        relations[msg.sender][user] = Relation.None;
        relations[user][msg.sender] = Relation.None;
        emit declineContactEvent(msg.sender, user);
    }

    function blockContact(address user) public forusers {
        relations[msg.sender][user] = Relation.Blocked;
        relations[user][msg.sender] = Relation.None;
        emit blockContactEvent(msg.sender, user);
    }

    function unblockContact(address user) public forusers {
        relations[msg.sender][user] = Relation.None;
        emit unblockContactEvent(msg.sender, user);
    }

    modifier forusers() {
        require(users[msg.sender].exists, "You are not a user of arcane. Use createUser");
        _;
    }

    function getRelation(address me, address other) public view returns (Relation) {
        return relations[me][other];
    }

    function getSignupBlock(address me) public view returns (uint) {
        return users[me].signupBlock;
    }

    function getLastSendingBlock(address me, address other) public view returns (uint) {
        return lastBlockSend[me][other];
    }

    function getLastReceivingBlock(address me, address other) public view returns (uint) {
        return lastBlockReceive[me][other];
    }

    function getName(address a) public view returns (string memory) {
        return users[a].name;
    }

    function isUser(address a) public view returns (bool) {
        return users[a].exists;
    }
}