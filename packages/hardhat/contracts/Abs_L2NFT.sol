// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import { OVM_CrossDomainEnabled } from "@eth-optimism/contracts/build/contracts/libraries/bridge/OVM_CrossDomainEnabled.sol";
import { iOVM_L2ERC721 } from "./interfaces/iOVM_L2ERC721.sol";
import { iOVM_L1ERC721ETHGateway } from "./interfaces/iOVM_L1ERC721ETHGateway.sol";


/**
 * @title Abs_L2DepositedToken
 * @dev An L2 Deposited Token is an L2 representation of funds which were deposited from L1.
 * Usually contract mints new tokens when it hears about deposits into the L1 ERC20 gateway.
 * This contract also burns the tokens intended for withdrawal, informing the L1 gateway to release L1 funds.
 *
 * NOTE: This abstract contract gives all the core functionality of a deposited token implementation except for the
 * token's internal accounting itself.  This gives developers an easy way to implement children with their own token code.
 *
 * Compiler used: optimistic-solc
 * Runtime target: OVM
 */
abstract contract Abs_L2NFT is iOVM_L2ERC721, OVM_CrossDomainEnabled {

    /*******************
     * Contract Events *
     *******************/

    event Initialized(iOVM_L1ERC721ETHGateway _l1TokenGateway);

    /********************************
     * External Contract References *
     ********************************/

    iOVM_L1ERC721ETHGateway public l1TokenGateway;

    /********************************
     * Constructor & Initialization *
     ********************************/

    /**
     * @param _l2CrossDomainMessenger L1 Messenger address being used for cross-chain communications.
     */
    constructor(
        address _l2CrossDomainMessenger
    )
    OVM_CrossDomainEnabled(_l2CrossDomainMessenger)
    {}

    /**
     * @dev Initialize this contract with the L1 token gateway address.
     * The flow: 1) this contract gets deployed on L2, 2) the L1
     * gateway is deployed with addr from (1), 3) L1 gateway address passed here.
     *
     * @param _l1TokenGateway Address of the corresponding L1 gateway deployed to the main chain
     */

    function init(
        iOVM_L1ERC721ETHGateway _l1TokenGateway
    )
    public
    {
        require(address(l1TokenGateway) == address(0), "Contract has already been initialized");

        l1TokenGateway = _l1TokenGateway;

        emit Initialized(l1TokenGateway);
    }

    /**********************
     * Function Modifiers *
     **********************/

    modifier onlyInitialized() {
        require(address(l1TokenGateway) != address(0), "Contract has not yet been initialized");
        _;
    }

    /********************************
     * Overridable Accounting logic *
     ********************************/

    // Default gas value which can be overridden if more complex logic runs on L2.
    uint32 constant DEFAULT_FINALIZE_WITHDRAWAL_L1_GAS = 100000;

    /**
     * @dev Core logic to be performed when a withdrawal from L2 is initialized.
     * In most cases, this will simply burn the withdrawn L2 funds.
     *
     * @param _to Address being withdrawn to
     * @param _amount Amount being withdrawn
     */

    function _handleInitiateWithdrawal(
        address _to
    )
    internal
    virtual
    {
        revert("Accounting must be implemented by child contract.");
    }

    /**
     * @dev Overridable getter for the *L1* gas limit of settling the withdrawal, in the case it may be
     * dynamic, and the above public constant does not suffice.
     *
     */

    function getFinalizeWithdrawalL1Gas()
    public
    view
    virtual
    returns(
        uint32
    )
    {
        return DEFAULT_FINALIZE_WITHDRAWAL_L1_GAS;
    }


    /***************
     * Withdrawing *
     ***************/

    /**
     * @dev initiate a withdraw of some tokens to the caller's account on L1
     * @param _amount Amount of the token to withdraw
     */
    function withdraw()
    external
    override
    onlyInitialized()
    {
        _initiateWithdrawal(msg.sender);
    }

    /**
     * @dev initiate a withdraw of some token to a recipient's account on L1
     * @param _to L1 adress to credit the withdrawal to
     * @param _amount Amount of the token to withdraw
     */
    function withdrawTo(
        address _to
    )
    external
    override
    onlyInitialized()
    {
        _initiateWithdrawal(_to);
    }

    /**
     * @dev Performs the logic for deposits by storing the token and informing the L2 token Gateway of the deposit.
     *
     * @param _to Account to give the withdrawal to on L1
     * @param _amount Amount of the token to withdraw
     */
    function _initiateWithdrawal(
        address _to
    )
    internal
    {
        // Call our withdrawal accounting handler implemented by child contracts (usually a _burn)
        _handleInitiateWithdrawal(_to);

        // Construct calldata for l1TokenGateway.finalizeWithdrawal(_to, _amount)
        bytes memory data = abi.encodeWithSelector(
            iOVM_L1ERC721ETHGateway.finalizeWithdrawal.selector,
            _to
        );

        // Send message up to L1 gateway
        sendCrossDomainMessage(
            address(l1TokenGateway),
            data,
            getFinalizeWithdrawalL1Gas()
        );

        emit WithdrawalInitiated(msg.sender, _to, _amount);
    }
}
