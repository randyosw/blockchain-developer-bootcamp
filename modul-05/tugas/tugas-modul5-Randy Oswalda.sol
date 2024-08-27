// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./VotingSystem.sol";

contract VotingSystemTest is Test {
    VotingSystem votingSystem;

    address owner = address(0x1);
    address voter1 = address(0x2);
    address voter2 = address(0x3);

    function setUp() public {
        votingSystem = new VotingSystem(2, 5 days);
        vm.startPrank(owner);
        votingSystem.addCandidate("Alice");
        votingSystem.addCandidate("Bob");
        vm.stopPrank();
    }

    function testStartVoting() public {
        vm.startPrank(owner);
        votingSystem.startVoting();
        vm.stopPrank();

        assertEq(uint(votingSystem.voteState()), uint(VotingSystem.VoteState.STARTED));
    }

    function testVote() public {
        vm.startPrank(owner);
        votingSystem.startVoting();
        vm.stopPrank();

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.stopPrank();

        assertEq(votingSystem.getCandidateVoteCount(1), 1);
    }

    function testVoteAlreadyVoted() public {
        vm.startPrank(owner);
        votingSystem.startVoting();
        vm.stopPrank();

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.expectRevert("Voter has already voted");
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testEndVoting() public {
        vm.startPrank(owner);
        votingSystem.startVoting();
        vm.stopPrank();

        vm.warp(block.timestamp + 6 days); // Move time forward
        vm.startPrank(owner);
        votingSystem.endVoting();
        vm.stopPrank();

        assertEq(uint(votingSystem.voteState()), uint(VotingSystem.VoteState.ENDED));
    }

    function testChooseWinner() public {
        vm.startPrank(owner);
        votingSystem.startVoting();
        vm.stopPrank();

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.stopPrank();

        vm.startPrank(voter2);
        votingSystem.vote(2);
        vm.stopPrank();

        vm.warp(block.timestamp + 6 days); // Move time forward
        vm.startPrank(owner);
        votingSystem.endVoting();
        votingSystem.chooseTheWinner();
        vm.stopPrank();

        assertEq(votingSystem.winner().id, 2);
    }
}