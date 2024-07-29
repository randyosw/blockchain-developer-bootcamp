// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// tugas 1
// use a mapping to store members by their address.
// create addMember external function that accepts the address of new member.
// create removeMember external function that removes existing member.
// create isMember external function to check whether a given address
// is associated with the members in our system.

contract Membership {

    // Mapping to keep track of member addresses and their usernames
    mapping(address => bool) members;

    // External function to add a new member
    function addMember(address newMember) external {
        members[newMember] = true;
    }

    // External function to remove a member
    function removeMember(address removedMember) external {
        members[removedMember] = false;
    }

    // Public view function to check if an address is a member
    function isMember(address member0) public view returns (bool) {
        return members[member0];
    }

    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 randy
    // 0xa75b55D7B6ae3EecF5b5d9995636D59813E7c180 tania
}

contract membershipUpgrade {

// Tugas 2
// Change the identifier of the mapping from bool to a predefined Struct called Member with id, name, balance, membershipType, 
// and other information of your choice.
// Member ID always starts with 1, and not 0. Every time a member is added, the ID should be incremented.
// Use enum for membershipType with values of your choice.
// Create functions to modify each Member information (name, membershipType, etc).

    struct Member {
        uint Id;
        string name;
        uint balance;
        bool membership;
    }

    enum membershipType {
        Active,
        Deactive
    }
    uint memberId;
    mapping (address => Member) members;

    function addMember(address _member, string memory _name, uint _balance, membershipType _membership) external {
        memberId++; 

        members[_member] = Member({
            Id: memberId,
            name: _name,
            balance: _balance,
            membership: _membership == membershipType.Active
        });
        }
    function isMember(address _member) external view returns (bool) {
        return members[_member].Id != 0;
        }

    function removeMember(address _member) external {
        delete members[_member];
        }
}