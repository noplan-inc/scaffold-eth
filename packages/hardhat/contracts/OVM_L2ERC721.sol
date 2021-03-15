// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

/* Library Imports */
import { OVM_L2DepositedERC20 } from "@eth-optimism/contracts/build/contracts/OVM/bridge/tokens/OVM_L2DepositedERC20.sol";
import { Abs_L2NFT } from "./Abs_L2NFT.sol";
import { ERC721BurnableMintable } from "./ERC721BurnableMintable.sol";

/**
 * @title L2DepositedERC20
 * @dev The L2 Deposited ERC20 is an ERC20 implementation which represents L1 assets deposited into L2.
 * This contract mints new tokens when it hears about deposits into the L1 ERC20 gateway.
 * This contract also burns the tokens intended for withdrawal, informing the L1 gateway to release L1 funds.
 *
 * Compiler used: optimistic-solc
 * Runtime target: OVM
 */
contract OVM_L2ERC721 is Abs_L2NFT, ERC721BurnableMintable {

    constructor(
        address _l2CrossDomainMessenger,
        string memory _name,
        string memory _symbol
    )
    public
    Abs_L2NFT(_l2CrossDomainMessenger)
    ERC721BurnableMintable(_name, _symbol)
    {}

    // When a withdrawal is initiated, we burn the withdrawer's funds to prevent subsequent L2 usage.
    function _handleInitiateWithdrawal(uint256 tokenId)
    internal
    override
    {
        burn(tokenId);
    }
}
