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

        address[] memory confirmedRSVPS; 
        address[] memory claimedRSVPS; 

        // Create new CreateEvent struct and add it to idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID, 
            msg.sender,
            eventTimestamp, 
            deposit, 
            maxCapacity, 
            confirmedRSVPS, 
            claimedRSVPS, 
            false
        );

    }
}
