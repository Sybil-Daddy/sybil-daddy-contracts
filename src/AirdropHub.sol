// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract AirdropFactory {} // generate a new Airdrop contract for each airdrop

contract AirdropMain {
    mapping(address => uint256) addressAmountEligibility; //address => airdrop ammount
    mapping(uint256 => uint256) fidAmountEligibility; // fid => airdrop ammount
    mapping(address => uint256) linkedFid; // address => linked fid

    constructor() {} // pull that amount of ERC20 tokens from wallet

    function claimAirdrop() public {
        require(addressAmountEligibility[msg.sender] > 0);
        uint256 amount = addressAmountEligibility[msg.sender];
        addressAmountEligibility[msg.sender] = 0;

        //send the token as airdrop
    } // give it to him the same amount

    function linkAddressToFid(uint256 fid, address addressToLink) public {
        //only admin role
        linkedFid[addressToLink] = fid;
    }
}
