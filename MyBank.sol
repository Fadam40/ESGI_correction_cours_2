// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyBank {
    // State variables
    IERC20 public myusd;
    address public owner;

    mapping(address => uint256) public balances;

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor to initialize the contract and set the owner
    constructor(address myusdAddress) {
        myusd = IERC20(myusdAddress);
        owner = msg.sender; // Set the deployer as the owner
    }

    // Deposit function to allow users to deposit myUSD
    function deposit(uint256 amount) external {
        require(myusd.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
    }

    // Withdraw function to allow users to withdraw their myUSD
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(myusd.transfer(msg.sender, amount), "Transfer failed");
    }

    // Transfer function to allow users to transfer myUSD between accounts
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // Admin function to forcefully transfer funds between accounts
    function adminTransfer(address from, address to, uint256 amount) external onlyOwner {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
    }

    // Function to read the balance of an address in myUSD using `staticcall`
    function getExternalBalance(address user) external view returns (uint256) {
        (bool success, bytes memory data) = address(myusd).staticcall(
            abi.encodeWithSelector(myusd.balanceOf.selector, user)
        );
        require(success, "Staticcall failed");
        return abi.decode(data, (uint256));
    }

    // Admin function to execute an arbitrary call
    function adminCall(address target, bytes calldata data) external onlyOwner returns (bytes memory) {
        require(target != address(0), "Target cannot be zero address");
        (bool success, bytes memory returnData) = target.call(data);
        require(success, "Call failed");
        return returnData;
    }

    // Function to recover ETH sent to the contract
    function receiveEth() external payable {
    }

    // Function to recover ETH sent to the contract
    function recoverETH() external {
        uint256 amount = address(this).balance; // Get the ETH balance of the contract
        require(amount > 0, "No ETH to recover");
        payable(msg.sender).transfer(amount); // Transfer the ETH to the caller
    }

    // Fallback function to accept ETH transfers
    receive() external payable {}

}
