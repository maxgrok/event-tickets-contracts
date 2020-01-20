pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    //State Variables
    address payable public owner = msg.sender;

    uint256 TICKET_PRICE = 100 wei;

    struct Event {
        string description; 
        string website;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    mapping(address => uint) public buyers;

    Event myEvent;

    //Events

    event LogBuyTickets(address _purchaser,uint _numberOfTickets);
    event LogGetRefund(address _refundRequester, uint _numberOfTickets);
    event LogEndSale(address _owner, uint _balanceTransfered);
    
    //Modifier
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }

    constructor(string memory description, string memory website, uint numberOfTicketsForSale) public {
        owner  == msg.sender;
        uint256 sales = 0;
        bool isOpen;
        isOpen = true;
       myEvent = Event(description, website, numberOfTicketsForSale, sales, isOpen);
    }
    
    //Functions
    
    function readEvent()
        public view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    
    function getBuyerTicketCount(address _buyer) public view returns(uint){
        return buyers[_buyer];
    }
    
    function buyTickets(uint _numberOfTickets) public payable {
        require(myEvent.isOpen == true);
        require(myEvent.totalTickets >= _numberOfTickets);
        require(msg.value >= _numberOfTickets * TICKET_PRICE);
        
        myEvent.totalTickets -= _numberOfTickets;
        buyers[msg.sender] += _numberOfTickets;
        myEvent.sales += _numberOfTickets;  
        msg.sender.transfer(msg.value - (_numberOfTickets * TICKET_PRICE));
        emit LogBuyTickets(msg.sender, _numberOfTickets);
    }
    
    function getRefund() public payable {
        require(buyers[msg.sender] > 0);
        myEvent.sales = myEvent.sales - buyers[msg.sender];
        msg.sender.transfer(buyers[msg.sender] * TICKET_PRICE);
        buyers[msg.sender] = 0;
        emit LogGetRefund(msg.sender, buyers[msg.sender]);
    }

    function endSale() public payable isOwner {
        myEvent.isOpen = false;
        //transfer the contract balance to the owner
        uint _balanceTransfered = address(this).balance;
        owner.transfer(_balanceTransfered);
        emit LogEndSale(owner, _balanceTransfered);
    }
}
