// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @title iOVM_L1ETHGateway
 */
interface iOVM_L1ERC721ETHGateway {

    /**********
     * Events *
     **********/

    event WithdrawalFinalized(
        address indexed _to
    );


    /*************************
     * Cross-chain Functions *
     *************************/

    function finalizeWithdrawal(
        address _to
    )
        external;
}
