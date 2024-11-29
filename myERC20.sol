// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myUSD is ERC20 {

    // State variable to store the owner's address
    address public owner;

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor to initialize the token and set the owner
    constructor() ERC20("myUSD", "myUSD") {
        owner = msg.sender; // Set the owner as the initial owner
    }

    // Override the decimals function to return 6
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // Function to mint new tokens, only callable by the owner
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens from the owner's balance
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
