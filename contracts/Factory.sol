// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {
    uint256 public constant TARGET = 3 ether;
    uint256 public constant TOKEN_LIMIT = 500_000 ether;
    
    uint256 public immutable fee;
    address public owner;

    uint256 public totalTokens;
    address[] public tokens;
    mapping(address => TokenSale) public tokenToSale;

    struct TokenSale {
        address token;
        string name;
        address creator;
        uint256 sold;
        uint256 raised;
        bool isOpen;
    }

    // Events
    event Created(address indexed token);
    event Buy(address indexed token, uint256 amount);


    constructor(uint256 _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    function getTokenSale(
        uint256 _index
    ) public view returns (TokenSale memory) {
        return tokenToSale[tokens[_index]];
    }

    function getCost(uint256 _sold) public pure returns (uint256) {
        uint256 floor = 0.0001 ether;
        uint256 step = 0.0001 ether;
        uint256 increment = 10000 ether;

        uint256 cost = (step * (_sold / increment)) + floor;
        return cost;
    }


    function create(
        string memory _name,
        string memory _symbol
    ) external payable {
        //check if the fee is paid
        require(msg.value >= fee, "Insufficient fee paid");

        //create new token
        Token token = new Token(msg.sender, _name, _symbol, 1_000_000 ether);

        //save the token for later use
        tokens.push(address(token));

        totalTokens++;

        //list the token for sale
        TokenSale memory sale = TokenSale(
            address(token),
            _name,
            msg.sender,
            0,
            0,
            true
        );

        tokenToSale[address(token)] = sale;

        //tell people it's live
        emit Created(address(token));
    }

    function buy(address _token, uint256 _amount) external payable {
        TokenSale storage sale = tokenToSale[_token];

        require(sale.isOpen == true, "Factory: Buying closed");
        require(_amount >= 1 ether, "Factory: Amount too low");
        require(_amount <= 10000 ether, "Factory: Amount exceeded");

        // Calculate the price of 1 token based on the total bought.
        uint256 cost = getCost(sale.sold);

        // Determine the total price for X amount.
        uint256 price = cost * (_amount / 10 ** 18);

        // Check to ensure enough ETH is sent.
        require(msg.value >= price, "Factory: Insufficient ETH received");

        // Update contract states.
        sale.sold += _amount;
        sale.raised += price;

        // If we have reached our ETH goal OR buy limit, stop allowing buys.
        if (sale.sold >= TOKEN_LIMIT || sale.raised >= TARGET) {
            sale.isOpen = false;
        }

        // Transfer tokens to buyer.
        Token(_token).transfer(msg.sender, _amount);

        emit Buy(_token, _amount);
    }
}
