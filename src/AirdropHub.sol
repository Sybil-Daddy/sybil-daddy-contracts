// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AirdropFactory {
    function createNewAirdrop() public {
        // only Admin
    } // call Airdropmain()
} // generate a new Airdrop contract for each airdrop

contract AirdropMain {
    mapping(address => uint256) addressAmountEligibility; //address => airdrop ammount
    mapping(uint256 => uint256) fidAmountEligibility; // fid => airdrop ammount
    mapping(uint256 => address) linkedFid; // address => linked fid, for dynamic wallets ( AA wallets )
    ERC20 airdropToken;

    constructor(
        ERC20 airdropToken_,
        address[] memory eligibleAddresses,
        uint256[] memory addressAmounts,
        uint256[] memory eligibleFIDs,
        uint256[] memory fidAmounts
    ) {
        require(eligibleAddresses.length == addressAmounts.length);
        require(eligibleFIDs.length == fidAmounts.length);
        airdropToken = airdropToken_;

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < eligibleAddresses.length; i++) {
            addressAmountEligibility[eligibleAddresses[i]] = addressAmounts[i];
            totalAmount += addressAmounts[i];
        }

        for (uint256 i = 0; i < eligibleFIDs.length; i++) {
            fidAmountEligibility[eligibleFIDs[i]] = fidAmounts[i];
            totalAmount += fidAmounts[i];
        }

        airdropToken.transferFrom(msg.sender, address(this), totalAmount);
    }

    function claimAirdrop() public {
        require(addressAmountEligibility[msg.sender] > 0);
        uint256 amount = addressAmountEligibility[msg.sender];
        addressAmountEligibility[msg.sender] = 0;

        airdropToken.transfer(msg.sender, amount);
    }

    function linkAddressToFid(uint256 fid, address addressToLink) public {
        //only admin role
        linkedFid[fid] = addressToLink;
    }

    function claimAirdropForFID(uint256 fid) public {
        require(linkedFid[fid] == msg.sender);

        uint256 amount = fidAmountEligibility[fid];
        fidAmountEligibility[fid] = 0;

        airdropToken.transfer(msg.sender, amount);
    }
}
