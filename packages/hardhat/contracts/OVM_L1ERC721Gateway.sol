// SPDX-License-Identifier: MIT
// @unsupported: ovm
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

/* Interface Imports */
import { Abs_L1TokenGateway } from "./Abs_L1TokenGateway.sol";
import { IERC721 } from "./interfaces/IERC721.sol";

contract OVM_L1ERC721Gateway is Abs_L1TokenGateway {

    /********************************
     * External Contract References *
     ********************************/


    IERC72　public l1ERC721;

    /***************
     * Constructor *
     ***************/

    /**
     * @param _l1ERC20 L1 ERC20 address this contract stores deposits for
     * @param _l2DepositedERC20 L2 Gateway address on the chain being deposited into
     */
    constructor(
        address _l1ERC721,
        address _l1messenger
    )
    Abs_L1TokenGateway(
        _l1messenger
    )
    {
        require(address(_l1ERC721) != address(0), "Contract must have erc721 address.");
        l1ERC721 = _l1ERC721;
    }


    /**************
     * Accounting *
     **************/

    /**
     * @dev When a withdrawal is finalized on L1, the L1 Gateway
     * transfers the funds to the withdrawer
     *
     * @param _to L1 address that the ERC20 is being withdrawn to
     * @param _amount Amount of ERC20 to send
     */
    function _handleFinalizeWithdrawal(
        address _to
    )
    internal
    override
    {
        // Transfer withdrawn funds out to withdrawer
        l1ERC721.mint(_to);
    }
}
