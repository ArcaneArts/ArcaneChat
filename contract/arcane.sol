// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract ArcaneChat {
    // Fired when someone changes their name
    event nameChangeEvent(address indexed from, string newName);

    // Fired when a new mage has joined Arcane
    event newMageEvent(address indexed from);

    // Fired when a user sends a message to another user
    event messageEvent(address indexed from, address indexed to, string message);

    // Fired when a contact is added
    event requestContactEvent(address indexed from, address indexed to);

    // Fired when a contact is accepted
    event acceptContactEvent(address indexed from, address indexed to);

    // Fired when a contact is declined
    event declineContactEvent(address indexed from, address indexed to);

    // Relationship types stored in each person's relationship with another person
    enum Relation {
        // No relation, the default
        None,

        // The user[otheruser] means user is requesting to add a contact (otheruser)
        OutgoingRequest,

        // The user[otheruser] means otheruser is requesting to add a contact (user)
        IncomingRequest,

        // The users are contacts such that user[otheruser] = Contacts = otheruser[user]
        Contacts
    }

    // The user data. Each user has this
    struct User {
        // Exists, used to check if a user actually exists
        bool exists;

        // The name of this user
        string name;

        // The block number this user signed up at
        uint signupBlock;
    }

    // The owner of this smart contract
    address grandarchmage;

    // The value (in wei) of 1 mana
    uint manaValue = 10000000000000;

    // The amount of mana per contract write option required
    uint tip = 1;

    // Tracks how many created users there are
    uint statUsers = 0;

    // Tracks how many connections (accepted contact requests) have been created
    uint statConnections = 0;

    // Tracks how many messages have been sent
    uint statMessages = 0;

    // Maps cipher data per user such that user[otheruser] = cipher. These are write keys
    mapping (address => mapping (address => string)) cipher;

    // Maps user[otheruser] to relationships
    mapping (address => mapping (address => Relation)) relations;

    // Maps user[otheruser] to the last block user sent
    mapping (address => mapping (address => uint)) lastBlockSend;

    // Maps user[otheruser] to to the last block user received
    mapping (address => mapping (address => uint)) lastBlockReceive;

    // Maps users to their data object (User)
    mapping (address => User) users;

    // Upon creation, sets the archmage & grandarchmage to the creator
    constructor()
    {
        grandarchmage = msg.sender;
    }
    
    // An administrative function. Allows the grand archmage to transfer ownership of this contract
    function adminTransferGrandArchmage(address newmage) public {
        require(grandarchmage == msg.sender, "You cannot do this, you are not the Grand Archmage");
        grandarchmage = newmage;
    }
    
    // An administrative function. Allows the grand archmage to adjust the mana value (in wei)
    function adminUpdateManaValue(uint valueInWei) public {
        require(grandarchmage == msg.sender, "You cannot do this, you are not the Grand Archmage");
        manaValue = valueInWei;
    }
    
    // An administrative function. Allows the grand archmage to adjust the tip (in mana) per write transaction
    function adminUpdateTip(uint tipInMana) public {
        require(grandarchmage == msg.sender, "You cannot do this, you are not the Grand Archmage");
        tip = tipInMana;
    }
    
    // Allows a wallet to create a user account with arcane. Requires a name
    function becomeMage(string memory name) public payable {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        require(users[msg.sender].exists == false, "You are already a member.");
        users[msg.sender] = User(true, name, block.number);
        emit newMageEvent(msg.sender);
        emit nameChangeEvent(msg.sender, name);
        relations[msg.sender][msg.sender] = Relation.Contacts;
        statUsers++;
    }

    // Allows any user to change their name
    function changeName(string memory name) public payable forusers {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        users[msg.sender].name = name;
        emit nameChangeEvent(msg.sender, name);
    }

    // Allows any user to send a message to another user. They must be users & contacts
    function sendMessage(address to, string memory message) public payable forusers {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        require(relations[msg.sender][to] == Relation.Contacts, "the recipient is not in your contacts.");
        require(relations[to][msg.sender] == Relation.Contacts, "the recipient does not have you in your contacts.");
        lastBlockSend[msg.sender][to] = block.number;
        lastBlockReceive[to][msg.sender] = block.number;
        emit messageEvent(msg.sender, to, message);
        statMessages++;
    }

    // Allows any user to request a contact (another user).
    // The user must add their write key for this contact
    function requestContact(address user, string memory cipherdata) public payable forusers  {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        require(relations[msg.sender][user] == Relation.None && relations[user][msg.sender] == Relation.None, "You or the recipient are already contacts, or pending contacts, or blocking.");
        relations[msg.sender][user] = Relation.OutgoingRequest;
        relations[user][msg.sender] = Relation.IncomingRequest;
        cipher[user][msg.sender] = cipherdata;
        emit requestContactEvent(msg.sender, user);
    }

    // Allows any user to accept a contact from an existing outgoing contact request.
    // The user must provide their write key for the requesting party
    function acceptContact(address user, string memory cipherdata) public payable forusers {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        require(relations[msg.sender][user] == Relation.IncomingRequest && relations[user][msg.sender] == Relation.OutgoingRequest, "The recipient does not have an outgoing contact request.");
        relations[msg.sender][user] = Relation.Contacts;
        relations[user][msg.sender] = Relation.Contacts;
        cipher[user][msg.sender] = cipherdata;
        emit acceptContactEvent(msg.sender, user);
        statConnections++;
    }

    // Allows any user to decline a contact request against them
    function declineContact(address user) public payable forusers {
        require(msg.value >= tip * manaValue, "Must contain at least 1 Mana in value.");
        require(relations[msg.sender][user] == Relation.IncomingRequest && relations[user][msg.sender] == Relation.OutgoingRequest, "The recipient does not have an outgoing contact request.");
        relations[msg.sender][user] = Relation.None;
        relations[user][msg.sender] = Relation.None;
        cipher[user][msg.sender] = "";
        cipher[msg.sender][user] = "";
        emit declineContactEvent(msg.sender, user);
    }

    // A simple modifier that requires invokers to be actual users of arcane
    modifier forusers() {
        require(users[msg.sender].exists, "You are not a user of Arcane. Use createUser");
        _;
    }

    // Gets the relationship of 'other' from the perspective of 'me'
    function getRelation(address me, address other) public view returns (Relation) {
        return relations[me][other];
    }

    // Gets the block that 'me' signed up at.
    function getSignupBlock(address me) public view returns (uint) {
        return users[me].signupBlock;
    }

    // Gets the last block that 'me' sent a message to 'other'
    function getLastSendingBlock(address me, address other) public view returns (uint) {
        return lastBlockSend[me][other];
    }

    // Gets the last block that 'me' received a message from 'other'
    function getLastReceivingBlock(address me, address other) public view returns (uint) {
        return lastBlockReceive[me][other];
    }

    // Gets the name of 'a'
    function getName(address a) public view returns (string memory) {
        return users[a].name;
    }

    // Gets the cipher (write key) used to write data from me -> other that other can read.
    function getCipher(address me, address other) public view returns (string memory) {
        return cipher[me][other];
    }

    // Returns true if 'a' is a user of Arcane
    function isUser(address a) public view returns (bool) {
        return users[a].exists;
    }
    
    // Gets the mana value in wei
    function getManaValue() public view returns (uint) {
        return manaValue;
    }
    
    // Gets the required minimum tip value in mana
    function getTip() public view returns (uint) {
        return tip;
    }
    
    // Gets the required minimum tip value in wei
    function getTipInWei() public view returns (uint) {
        return tip * manaValue;
    }
    
    // Gets the user count
    function getStatUsers() public view returns (uint) {
        return statUsers;
    }
    
    // Gets the count of bi-directional contact connections there are
    function getStatConnections() public view returns (uint) {
        return statConnections;
    }
    
    // Gets the count of messages that have been sent
    function getStatMessages() public view returns (uint) {
        return statMessages;
    }
    
    // Returns true if 'a' is the grand archmage (owner of this contract)
    function isGrandArchmage(address a) public view returns (bool) {
        return grandarchmage == a;
    }
}