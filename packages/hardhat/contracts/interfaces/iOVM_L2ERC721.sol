// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @title iOVM_L2DepositedToken
 */
interface iOVM_L2ERC721 {

    /**********
     * Events *
     **********/

    event WithdrawalInitiated(
        address indexed _from,
        address _to
    );

    /********************
     * Public Functions *
     ********************/

    function withdraw(
        uint _amount
    )
    external;

    function withdrawTo(
        address _to,
        uint _amount
    )
    external;
}
