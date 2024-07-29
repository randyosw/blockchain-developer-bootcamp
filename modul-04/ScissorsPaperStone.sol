// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract RockPaperScissors{


    enum  Move { Rock, Paper, Scissors, None } 

    struct Player {
        uint256 playerId;
        address playerAddress;
        bytes32 secret;
        Move move;
        bool isMoved;
    }

    event RegisterPlayer(uint256 playerId, address player);
    event MoveAction(uint256 playerId, address player);
    event RevealMove(address playerAddress, Move move);

    error MaximumPlayer();
    error RegisterFirst();
    error InvalidMove();
    error MoveActionFirst();
    error RevealMoveFirst();
    error InvalidSameAddress();

    uint counter = 0;
    Player[2] public Players;

    modifier checkRegisterFirst() {
        if (counter != 2) revert RegisterFirst();
        _;
    }

    //Master Function
    function setRules(address _address1, address _address2, Move _move1, Move _move2) public pure returns(string memory winner, address winnerAddress){
        if(_move1 == _move2){
            return ("Draw Game ", address(0));
        }
        else{
            if((_move1 == Move.Rock && _move2 == Move.Scissors) || (_move1 == Move.Paper && _move2 == Move.Rock) || (_move1 == Move.Scissors && _move2 == Move.Paper)){
                return ("Congratulations ", _address1);
            }
            else  return ("Congratulations ", _address2);
        }
    }

    function hashing(Move _move) public view returns (bytes32){
        if(_move == Move.None) revert InvalidMove();
        return keccak256(abi.encodePacked(_move, msg.sender));
    }
    //End Master Function

     function registerPlayer() external {
        if(counter == 2) revert MaximumPlayer();
        else{
            if(counter == 1)
            {
                if(Players[0].playerAddress == msg.sender) revert InvalidSameAddress();
            }
            Players[counter] = Player(counter,msg.sender,  bytes32(0), Move.None, false); // bytes32(0) -> belom diisi apa2 didalamnya
            counter++;
            emit RegisterPlayer(counter, msg.sender);
        }
    }

    function moveAction(Move _move) checkRegisterFirst external {
        for (uint a = 0; a < counter; a++) {
            if (Players[a].playerAddress == msg.sender) {
                Players[a].secret = hashing(_move);
                Players[a].isMoved = true;
                emit MoveAction(a, msg.sender);
                return;
            }
        }
    }

    function revealMove(Move _move) checkRegisterFirst external{
        for(uint a=0 ; a<counter ; a++){
            if (Players[a].playerAddress == msg.sender) {
                bytes32 hash = hashing(_move);

                if (hash != Players[a].secret) {
                    revert InvalidMove();
                }
                Players[a].move = _move;
                emit RevealMove(msg.sender, _move);
            }
        }
    }

    function setWinner() checkRegisterFirst external view returns (string memory winner, address Address){
        if(Players[0].isMoved == false || Players[1].isMoved == false ) revert MoveActionFirst();
        if(Players[0].move == Move.None || Players[1].move == Move.None) revert RevealMoveFirst();

        return setRules(Players[0].playerAddress, Players[1].playerAddress, Players[0].move, Players[1].move);
    }
}