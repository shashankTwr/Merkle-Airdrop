// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {KunafaToken} from "./KunafaToken.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop  {
    // some list of addresses
    // Allow someone in list to claim tokens
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    using SafeERC20 for IERC20;

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    event ClaimToken(address  account, uint256   amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

   // Allow someone to claim ERC-20 tokens

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {

        if(s_hasClaimed[account]) 
            revert MerkleAirdrop__AlreadyClaimed();
        // Calculate using the account and amount
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // Verify the proof
        if(!MerkleProof.verify(merkleProof,i_merkleRoot, leaf))
            revert MerkleAirdrop__InvalidProof();
        


        // Mint them ERC20 token
        emit ClaimToken(account, amount);
        i_airdropToken.safeTransfer(account, amount);

        
    } 

    function getMerkleRoot() external view returns(bytes32){
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns(IERC20){
        return i_airdropToken;
    }

}

