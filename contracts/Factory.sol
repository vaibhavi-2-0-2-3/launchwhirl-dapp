// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {
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
    // event Buy(address indexed token, uint256 amount);


    constructor(uint256 _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    function getTokenSale(
        uint256 _index
    ) public view returns (TokenSale memory) {
        return tokenToSale[tokens[_index]];
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
}
