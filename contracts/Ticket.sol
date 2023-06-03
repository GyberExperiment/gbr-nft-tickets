// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract NFTTicket is ERC721 {
    struct Ticket {
        string first_name;
        string last_name;
    }

    address public owner;
    IERC20 public gbrToken;

    uint256 public ticketPrice;
    uint256 public ticketsCount;
    mapping (uint256 => Ticket) private _tickets;

    constructor(address _gbrTokenAddress, uint256 _ticketPrice) ERC721("NFTTicket", "NFTT") {
        owner = msg.sender;
        gbrToken = IERC20(_gbrTokenAddress);
        ticketPrice = _ticketPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function changeTicketPrice(uint256 price) external onlyOwner {
        ticketPrice = price;
    }

    function buyTicket(string memory first_name, string memory last_name) external {
        require(gbrToken.balanceOf(msg.sender) >= ticketPrice, "Insufficient balance of GBR on your wallet");
        require(gbrToken.transferFrom(msg.sender, address(this), ticketPrice), "Error in the transfer of GBR tokens to purchase a ticket");

        ticketsCount++;
        _tickets[ticketsCount] = Ticket(first_name, last_name);

        _safeMint(msg.sender, ticketsCount);
    }

    function getTicketInfo(uint256 tokenId) public view returns (string memory, string memory) {
        require(_exists(tokenId), "Token does not exist");

        Ticket memory ticket = _tickets[tokenId];
        return (ticket.first_name, ticket.last_name);
    }
}
