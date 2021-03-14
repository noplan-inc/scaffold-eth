// SPDX-License-Identifier: MIT
// @unsupported: ovm
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import { OVM_CrossDomainEnabled } from "@eth-optimism/contracts/build/contracts/libraries/bridge/OVM_CrossDomainEnabled.sol";
import "./interfaces/iOVM_L1ERC721ETHGateway.sol";

/* Library Imports */

/**
 * @title Abs_L1TokenGateway
 * @dev An L1 Token Gateway is a contract which stores deposited L1 funds that are in use on L2.
 * It synchronizes a corresponding L2 representation of the "deposited token", informing it
 * of new deposits and releasing L1 funds when there are newly finalized withdrawals.
 *
 * NOTE: This abstract contract gives all the core functionality of an L1 token gateway,
 * but provides easy hooks in case developers need extensions in child contracts.
 * In many cases, the default OVM_L1ERC20Gateway will suffice.
 *
 * Compiler used: solc
 * Runtime target: EVM
 */
abstract contract Abs_L1TokenGateway is iOVM_L1ERC721ETHGateway, OVM_CrossDomainEnabled {

    /********************************
     * External Contract References *
     ********************************/


    /***************
     * Constructor *
     ***************/

    /**
     * @param _l2DepositedToken iOVM_L2DepositedToken-compatible address on the chain being deposited into.
     * @param _l1messenger L1 Messenger address being used for cross-chain communications.
     */
    constructor(
        address _l1messenger
    )
    OVM_CrossDomainEnabled(_l1messenger)
    {
    }

    /********************************
     * Overridable Accounting logic *
     ********************************/

    // Default gas value which can be overridden if more complex logic runs on L2.
    uint32 public DEFAULT_FINALIZE_DEPOSIT_L2_GAS = 1200000;

    /**
     * @dev Core logic to be performed when a withdrawal is finalized on L1.
     * In most cases, this will simply send locked funds to the withdrawer.
     *
     * @param _to Address being withdrawn to.
     * @param _amount Amount being withdrawn.
     */
    function _handleFinalizeWithdrawal(
        address _to,
        uint256 _amount
    )
    internal
    virtual
    {
        revert("Implement me in child contracts");
    }


    /**
     * @dev Overridable getter for the L2 gas limit, in the case it may be
     * dynamic, and the above public constant does not suffice.
     *
     */

    function getFinalizeDepositL2Gas()
    public
    view
    returns(
        uint32
    )
    {
        return DEFAULT_FINALIZE_DEPOSIT_L2_GAS;
    }

    /*************************
     * Cross-chain Functions *
     *************************/

    /**
     * @dev Complete a withdrawal from L2 to L1, and credit funds to the recipient's balance of the
     * L1 ERC20 token.
     * This call will fail if the initialized withdrawal from L2 has not been finalized.
     *
     * @param _to L1 address to credit the withdrawal to
     * @param _amount Amount of the ERC20 to withdraw
     */
    function finalizeWithdrawal(
        address _to
    )
    external
    override
    {
        // Call our withdrawal accounting handler implemented by child contracts.
        _handleFinalizeWithdrawal(
            _to
        );

        emit WithdrawalFinalized(_to);
    }
}
