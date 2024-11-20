// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {KunafaToken} from "../src/KunafaToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    KunafaToken public kuna;
    MerkleAirdrop public merkleAirdrop;
    DeployMerkleAirdrop public deployer;

    bytes32 public merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // the proof should be an array of 32 bytes, but it is currently an array of two identical 32 bytes
    // this is likely a mistake, and the correct proof should be provided
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proof1, proof2];

    uint256 public amountToClaim = 25 * 1e18;
    uint256 public amountToSend = amountToClaim * 4;

    address user;
    uint256 userPrivateKey;

    address public gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            // deploy with the script
            deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, kuna) = deployer.run();
        } else {
            kuna = new KunafaToken();
            merkleAirdrop = new MerkleAirdrop(merkleRoot, IERC20(kuna));
            kuna.mint(kuna.owner(), amountToSend); // mints amountToSend kuna
            kuna.transfer(address(merkleAirdrop), amountToSend); // transfer all the minted amount to the airdrop contract
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = kuna.balanceOf(user);
        console.log("startingBalance", startingBalance);
        bytes32 digest = merkleAirdrop.getMessageHash(user, amountToClaim);
        vm.startPrank(user);
        // sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        // we actually don't need to prank the User here i think because we have the userPrivateKey
        vm.stopPrank();

        // gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        merkleAirdrop.claim(user, amountToClaim, proof, v, r, s);

        uint256 endingBalance = kuna.balanceOf(user);
        console.log("Ending Balance of User", endingBalance);
        assertEq(endingBalance, startingBalance + amountToClaim);
    }
}
