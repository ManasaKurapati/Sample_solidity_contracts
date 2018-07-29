pragma solidity ^0.4.19;

contract casino {
    
    mapping(address => uint) _tickets;
    address[] _entries;
    address[] _verified;
    
    function generateHash(uint number, uint salt) public returns(bool) {
        return buyTickets(uint(keccak256(number + salt)));
    }
    function buyTickets(uint hash) public payable returns(bool) {
        require(1 ether == msg.value);
        require(_tickets[msg.sender] == 0);
        _tickets[msg.sender] = hash;
        _entries.push(msg.sender);
    }
}
