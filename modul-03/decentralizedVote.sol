// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedCandidateId;
    }

    constructor() {
        owner = msg.sender;
        votingOpen = false;
    }

    address public owner;
    uint public candidatesCount;
    bool public votingOpen;

    event candidateAdded(uint id, string name);
    event voteAdded(address eVoter, uint IdCandidate);
    event winner(string WinnerName);

    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier votingIsOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    function addCandidate(string memory _name) public onlyOwner {
        //candidates id increment
        candidatesCount++;
        //disini variable candidatesCount adalah id pada struct candidates
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit candidateAdded(candidatesCount, _name);
    }

    function openVoting() public onlyOwner {
        votingOpen = true;
    }

    function closeVoting() public onlyOwner {
        votingOpen = false;
    }

    function vote(uint _candidateId) public votingIsOpen {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        voters[msg.sender] = Voter(true, _candidateId);
        candidates[_candidateId].voteCount++;
        emit voteAdded(msg.sender, _candidateId);
    }

    function voteCount(uint _candidateId) public view returns (string memory Nama, uint JumlahVote) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function getWinner() public view returns (string memory) {
        require(!votingOpen, "Voting is still open");

        uint winningVoteCount = 0;
        uint winningCandidateId;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        return candidates[winningCandidateId].name;
    }
}
