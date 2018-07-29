pragma solidity ^0.4.19;

contract multiNumberBetting {
    
    uint8[3] numArray; //to store the numbers to be accepted
    address owner; //owner address
    
    modifier ownerOnly {
        require(msg.sender == owner); //validation to be a owner only
        _;
    }
    
    struct Winners { //to store winneres address
        string name;
        address winnerAddr;
        uint guess;
        uint guessedAt;
        uint ethersReceived;
    }
    
    uint public constant Max_amt = 5 ether; //declare min and max amounts for betting
    uint public constant Min_amt = 1 ether;
    
    uint lastWinnerAt; //time at which last guess was made
    uint winnerCount; // to store winner and looser counts 
    uint loserCount;
    
    address winner;
    
    mapping(address=>Winners) winnersMapping;
    
    event WinningBet(address indexed winner, string name, uint amount);
    event LosingBet(address indexed winner, string name,uint amount);
    
    function MultiNumberBetting(uint8 num0,uint8 num1,uint8 num2) payable {
        numArray[0] = num0;
        numArray[1] = num1;
        numArray[2] = num2;
        owner = msg.sender;
    }
    
    function totalGuesses() returns(uint) {
        return (loserCount+winnerCount);
    }
    
    function daysSinceLastWinning() returns(uint) {
        return(now - lastWinnerAt*1 days);
    }
    
    function hoursSinceLastWinning() returns (uint) {
    return (now - lastWinnerAt*1 hours);
    }
    function minutesSinceLastWinning() returns(uint) {
        return(now - lastWinnerAt* 1 minutes);
    }
    
    function getWinnerInfo() returns (address winnerAddr,
                                      string name,
                                      uint guess,
                                      uint guessedAt,
                                      uint ethersReceived) {
              winnerAddr = winnersMapping[winner].winnerAddr;
              name = winnersMapping[winner].name;
              guess = winnersMapping[winner].guess;
              guessedAt = winnersMapping[winner].guessedAt;
              ethersReceived = winnersMapping[winner].ethersReceived;
                                          
                                      
     }
    
    function ownerWithdraw(uint amt) ownerOnly payable {
        if((this.balance - amt) > 3 * Max_amt) {
            msg.sender.transfer(amt);
        } else {
            revert();
        }
    }
     
    function checkWinning(address winnerAddr) returns(address retWinnerAddr, string name,
                                                      uint guessVal, uint guessedAt) {
       Winners memory winnerlocal = winnersMapping[winnerAddr];
       if(winnerlocal.guessedAt != 0) {
           retWinnerAddr = winnerlocal.winnerAddr;
           name = winnerlocal.name;
           guessVal = winnerlocal.guess;
           guessedAt = winnerlocal.guessedAt;
       }
    }
    
    function() public payable {
        
    }
    
    function guessMade (uint8 num, string name) public payable returns(bool) {
        var betAmount = msg.value;
        
        require(this.balance > 2*betAmount);
        
        if(num > 10){
            revert();
        }
        if (betAmount > Max_amt || betAmount < Min_amt) {
            revert();
        }
        
        for(uint i=0;i < numArray.length;i++) {
            if (numArray[i] == num) {
                winnerCount++;
                winnersMapping[msg.sender].winnerAddr = msg.sender;
                winnersMapping[msg.sender].name = name;
                winnersMapping[msg.sender].guess = num;
                winnersMapping[msg.sender].guessedAt = now;
                winnersMapping[msg.sender].ethersReceived = betAmount;
                
                lastWinnerAt = winnersMapping[msg.sender].guessedAt;
                winner = msg.sender;
                
                uint sendBack = 2*msg.value;
                msg.sender.transfer(sendBack);
                
                WinningBet(winner, name, msg.value);
                return true;
            }
            
            loserCount ++;
            LosingBet(winner, name, msg.value);
            return false;
        }
    }
}
