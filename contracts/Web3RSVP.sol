//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract Web3RSVP {
    struct CreateEvent{
        bytes32 eventId;
        string eventDataCID; 
        address eventOwner; 
        uint256 eventTimestamp; 
        uint256 deposit; 
        uint256 maxCapacity; 
        address[] confirmedRSVPs;
        address[] claimedRSVPs; 
        bool paidOut; 
    }

    mapping(bytes32 => CreateEvent) public idToEvent; 

    function createNewEvent(
        uint256 eventTimestamp, 
        uint256 deposit, 
        uint256 maxCapacity, 
        string calldata eventDataCID
    ) external {
        // generate event ID based on information to generate a hash 
        bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender, 
                address(this),
                eventTimestamp, 
                deposit, 
                maxCapacity
            )
        );

        address[] memory confirmedRSVPs; 
        address[] memory claimedRSVPs; 

        // Create new CreateEvent struct and add it to idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID, 
            msg.sender,
            eventTimestamp, 
            deposit, 
            maxCapacity, 
            confirmedRSVPs, 
            claimedRSVPs, 
            false
        );
    }

    function createNewRSVP(bytes32 eventId) external payable {
        //lookup event from mapping
        Create storage myEvent = idToEvent[eventId]; 

        //transfer deposit to contract/ require enough ETH to cover the deposit requirement for event
        require(msg.value == myEvent.deposit, "Not Enough");

        //require that the event hasn't already happened (<eventTimestamp)
        require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED" );

        // make sure event is under max capacity
        require(
            myEvent.confirmedRSVPs.length < myEvent.maxCapacity, 
            "This event has reached capacity" 
        ); 

        // require that msg.sender isn't already in myEvent.confirmedRSVPs AKA hasn't already RSVP'd
        for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
            require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CONFIRMED");
        }
    }

    function confirmAttendee(bytes32 eventId, address attendee) public {
        // look up event from struct using the eventId
        CreateEvent storage myEvent = idToEvent[eventId];

        // require that msg.sender is the owner of the event - only the host should be able to check in people
        require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");
        
        // require that attendee trying to check in actually RSVP'd
        address rsvpConfirm; 

        for (uint8 i =0; i < myEvent.confirmedRSVPs.length; i = 0) {
            if(myEvent.confirmedRSVPs[i] == attendee){
                rsvpConfirm = myEvent.confirmedRSVPs[i]; 
            }
        }

        require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM"); 

        // require that attendee is NOT already in the claimedRSVPs list AKA make sure they haven't checked in
        for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
            require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CLAIMED");
        }

        // require that deposits are not already claimed by the event owner
        require(myEvent.paidOut == false, "ALREADY PAID OUT"); 

        //add the attendee to the claimedRSVPs list
        myEvent.claimedRSVPs.push(attendee); 

        // sending eth back to the staker `https://solidity-by-example.org/sending-ether`
        (bool sent,) = attendee.call{value: myEvent.deposit}(""); 

        // if this fails, remove this user from the array of claimed RSVPs
        if (!sent) {
            myEvent.claimedRSVPs.pop();
        }

        require(sent, "Failed to send Ether"); 
    }


    function confirmAllAttendees(bytes32 eventId) external {
        // look up event from our struct with with the eventId
        CreateEvent memory myEvent = idtoEvent[eventId]; 

        // make sure you require that msg.sender is the owner of the event 
        require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED"); 

        // confirm each attendee in the rsvp array 
        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
            confirmAttendee(eventId, myEvent.confirmedRSVP[i]); 
        }
    }

    


}
