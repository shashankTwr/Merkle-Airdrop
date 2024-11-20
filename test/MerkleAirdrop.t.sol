// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {KunafaToken} from "../src/KunafaToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";


contract MerkleAirdropTest is Test {

    KunafaToken public kuna;
    MerkleAirdrop public merkleAirdrop;
    DeployMerkleAirdrop public deployer;

    bytes32 public merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // the proof should be an array of 32 bytes, but it is currently an array of two identical 32 bytes
    // this is likely a mistake, and the correct proof should be provided
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proof1, proof2];

    uint256 public AMOUNT_TO_CLAIM= 25*1e18;
    uint256 public AMOUNT_TO_SEND= AMOUNT_TO_CLAIM * 4;

    address user;
    uint256 userPrivateKey;

    function setUp() public{
        
        kuna = new KunafaToken();
        merkleAirdrop = new MerkleAirdrop(merkleRoot, kuna);
        kuna.mint(kuna.owner(), AMOUNT_TO_SEND); // mints AMOUNT_TO_SEND kuna
        kuna.transfer(address(merkleAirdrop), AMOUNT_TO_SEND); // transfer all the minted amount to the airdrop contract
        deployer = new DeployMerkleAirdrop();
        (user, userPrivateKey) = makeAddrAndKey("user");
    }


    function testUsersCanClaim() public {
        uint256 startingBalance = kuna.balanceOf(user);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, proof);

        uint256 endingBalance = kuna.balanceOf(user);
        assertEq(endingBalance, startingBalance + AMOUNT_TO_CLAIM);
    }
}