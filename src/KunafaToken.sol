// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KunafaToken is ERC20, Ownable  {

    error KunafaToken__MustBeMoreThanZero();
    error KunafaToken__ExceedsBalance();
    error KunafaToken__ZeroAddress();
    
    constructor() ERC20("KunafaToken", "KUNA") Ownable(msg.sender) {}
    
    function mint(address _to, uint256 _amount) external onlyOwner returns(bool) {
        if(_to == address(0)) revert KunafaToken__ZeroAddress();

        if(_amount == 0) revert KunafaToken__MustBeMoreThanZero();

        _mint(_to, _amount);
        return true;
    }

}