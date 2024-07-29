// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DecentralizedMarketplaceContract {

    struct Item {
        uint256 id;
        string name;
        uint256 price;
        address owner;
        bool sold;
    }

    Item[] public itemArray;

    mapping(uint256 => Item) items;
    mapping(address => uint256[]) ownedItems; 
    mapping(address => uint256) withdrawals; 

    event ListItem (uint256 id, string name, uint256 price, address owner);
    event ItemPurchased(uint256 id, address buyer, uint256 price);
    event WithdrawFunds(address buyer, uint256 price);

    uint256 itemId = 0;

    function addNewItem(string memory _name, uint256 _price) external {
        require(_price > 0, "Price cannot be 0");
        ++itemId;
        items[itemId] = Item(
            itemId,
            _name,
            _price,
            msg.sender,
            false
        );
        emit ListItem(itemId, _name, _price, msg.sender);
    }

    function purchaseItem(uint256 _id) public payable {
        Item storage item = items[_id];
        require(_id > 0 && _id < itemId, "Invalid Item's Id");
        require(msg.value == item.price, "Incorrect amount of Ether sent");
        require(!item.sold, "Item already sold");
        require(item.owner != msg.sender, "Seller cannot buy their own item");
        item.owner = msg.sender;
        item.sold = true;
        ownedItems[msg.sender].push(_id);
        emit ItemPurchased(_id, msg.sender, item.price);
    }

    function withdrawFunds() public {
        uint256 amount = withdrawals[msg.sender];
        require(amount > 0, "No Balance");
        payable(msg.sender).transfer(amount);
        withdrawals[msg.sender] = 0;       
        emit WithdrawFunds(msg.sender, amount);
    }
}