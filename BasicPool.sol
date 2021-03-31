pragma solidty ^0.8.0;

contract BasicPool {
    
    private uint _price;
    
    constructor(uint price_) {
        _price = price_;
    }
    // Hold participants in a mapping; address to tickets
    mapping (address => uint) funderToTicket;

    // Pay to contract
    function fundPool(uint _tickets) payable external {
        // Add tickets to address
        funderToTicket[msg.sender] += _tickets;
        
        require(msg.value == _tickets * _price);
    }
    
    // Get random address internal
    
    
    // Send to address
    function sendToAddress(address payable _winner) external {
        uint balance = address(this).balance;
        _winner.transfer(balance);
    }
}
