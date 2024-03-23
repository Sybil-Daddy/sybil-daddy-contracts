// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AirdropFactory is AccessControl {
    mapping(ERC20 => AirdropMain) airdropContracts;
    address immutable defaultAdmin;

    constructor() {
        defaultAdmin = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function createNewAirdrop(
        ERC20 airdropToken_,
        address[] memory eligibleAddresses,
        uint256[] memory addressAmounts,
        uint256[] memory eligibleFIDs,
        uint256[] memory fidAmounts
    ) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        require(eligibleAddresses.length == addressAmounts.length);
        require(eligibleFIDs.length == fidAmounts.length);

        AirdropMain newAirdrop = new AirdropMain(
            airdropToken_,
            eligibleAddresses,
            addressAmounts,
            eligibleFIDs,
            fidAmounts,
            defaultAdmin
        );

        airdropContracts[airdropToken_] = newAirdrop;
    }
} // generate a new Airdrop contract for each airdrop

contract AirdropMain is AccessControl {
    uint256 immutable totalAmountToAirdrop;
    mapping(address => uint256) addressAmountEligibility; //address => airdrop ammount
    mapping(uint256 => uint256) fidAmountEligibility; // fid => airdrop ammount
    mapping(uint256 => address) linkedFid; // address => linked fid, for dynamic wallets ( AA wallets )
    ERC20 airdropToken;

    constructor(
        ERC20 airdropToken_,
        address[] memory eligibleAddresses,
        uint256[] memory addressAmounts,
        uint256[] memory eligibleFIDs,
        uint256[] memory fidAmounts,
        address defaultAdmin
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);

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

        totalAmountToAirdrop = totalAmount;

        airdropToken.transferFrom(msg.sender, address(this), totalAmount);
    }

    function claimAirdrop() public {
        require(addressAmountEligibility[msg.sender] > 0);
        uint256 amount = addressAmountEligibility[msg.sender];
        addressAmountEligibility[msg.sender] = 0;

        airdropToken.transfer(msg.sender, amount);
    }

    function linkAddressToFid(uint256 fid, address addressToLink) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        linkedFid[fid] = addressToLink;
    }

    function claimAirdropForFID(uint256 fid) public {
        require(linkedFid[fid] == msg.sender);

        uint256 amount = fidAmountEligibility[fid];
        fidAmountEligibility[fid] = 0;

        airdropToken.transfer(msg.sender, amount);
    }
}
