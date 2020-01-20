pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {
    //State Variables
    address payable public owner = msg.sender; 
    uint public TICKET_PRICE = 100 wei;

    uint public idGenerator;
    uint public eventId; 

    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    } 

    Event myEvent;
    
    mapping(uint => Event) public events;

    //Events
    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    //Modifier
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    //Functions
    function addEvent(string memory _description, string memory _website, uint _numberOfTickets) public isOwner returns(uint) {
        require(msg.sender == owner);
        
        events[idGenerator].description = _description;
        events[idGenerator].website = _website;
        events[idGenerator].totalTickets = _numberOfTickets;
        events[idGenerator].isOpen = true;
        idGenerator += 1;
        
        emit LogEventAdded(_description, _website, _numberOfTickets, idGenerator);
        return (idGenerator - 1);
    }
    
    function readEvent(uint _eventId) public view returns(string memory description, string memory website, uint ticketsAvailable, uint sales, bool isOpen){ 
        ticketsAvailable = events[_eventId].totalTickets - events[_eventId].sales;
        return (events[eventId].description, events[eventId].website, ticketsAvailable, events[eventId].sales, events[eventId].isOpen);
    }
    
    function buyTickets(uint _eventId, uint _numberOfTickets) public payable {
        require(events[_eventId].isOpen);
        require(msg.value >= _numberOfTickets * TICKET_PRICE);
        require(events[_eventId].totalTickets >= _numberOfTickets);
        
        events[_eventId].totalTickets -= _numberOfTickets;
        events[_eventId].buyers[msg.sender] += _numberOfTickets;
        events[_eventId].sales += _numberOfTickets;  
        msg.sender.transfer(msg.value - (_numberOfTickets * TICKET_PRICE));
        emit LogBuyTickets(msg.sender, _eventId, _numberOfTickets);
    }
    
    function getRefund(uint _eventId) public payable {
        require(idGenerator > _eventId);
        require(events[_eventId].isOpen == true);
        require(events[_eventId].buyers[msg.sender] > 0);
        
        events[_eventId].totalTickets += events[_eventId].buyers[msg.sender];
        events[_eventId].sales = events[_eventId].sales - events[_eventId].buyers[msg.sender];
        msg.sender.transfer(events[_eventId].buyers[msg.sender] * TICKET_PRICE);
        events[_eventId].buyers[msg.sender] = 0;
        emit LogGetRefund(msg.sender, _eventId, 1);
    }
    
    function getBuyerNumberTickets(uint _eventId) public view returns(uint){
        return events[_eventId].buyers[msg.sender];
    }

    function endSale(uint _eventId) public payable isOwner {
       events[_eventId].isOpen = false;
       emit LogEndSale(owner, address(this).balance, _eventId);
       owner.transfer(msg.value);
    }
}
