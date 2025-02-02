// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.10;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {AnchorBaseStrategy} from "./AnchorBaseStrategy.sol";
import {PercentMath} from "../../lib/PercentMath.sol";

/**
 * An Eth Anchor strategy that uses UST as the underlying currency
 */
contract AnchorUSTStrategy is AnchorBaseStrategy {
    using SafeERC20 for IERC20;
    using PercentMath for uint256;

    /**
     * Constructor of UST Strategy
     *
     * @notice The underlying token must be UST token.
     */
    constructor(
        address _vault,
        address _ethAnchorRouter,
        AggregatorV3Interface _aUstToUstFeed,
        IERC20 _ustToken,
        IERC20 _aUstToken,
        address _owner
    )
        AnchorBaseStrategy(
            _vault,
            _ethAnchorRouter,
            _aUstToUstFeed,
            _ustToken,
            _aUstToken,
            _owner
        )
    {
        require(
            underlying == _ustToken,
            "AnchorUSTStrategy: invalid underlying"
        );
    }

    /**
     * Initiates a deposit of all the currently held UST into EthAnchor
     *
     * @notice since EthAnchor uses an asynchronous model, this function
     * only starts the deposit process, but does not finish it.
     *
     * @dev external data is not required
     */
    function invest(bytes calldata) external override onlyManager {
        (address operator, uint256 ustAmount) = _initDepositStable();

        emit InitDepositStable(
            operator,
            depositOperations.length - 1,
            ustAmount,
            ustAmount
        );
    }

    /**
     * Calls EthAnchor with a pending redeem ID, and attempts to finish it.
     *
     * @notice Must be called some time after `initRedeemStable()`. Will only work if
     * the EthAnchor bridge has finished processing the deposit.
     *
     * @param idx Id of the pending redeem operation
     */
    function finishRedeemStable(uint256 idx) external onlyManager {
        (
            address operator,
            uint256 aUstAmount,
            uint256 ustAmount
        ) = _finishRedeemStable(idx);
        emit FinishRedeemStable(operator, aUstAmount, ustAmount, ustAmount);

        underlying.safeTransfer(vault, _getUnderlyingBalance());
    }

    /**
     * Amount, expressed in the underlying currency, currently in the strategy
     *
     * @notice both held and invested amounts are included here, using the
     * latest known exchange rates to the underlying currency.
     *
     * @return The total amount of underlying
     */
    function investedAssets() external view override returns (uint256) {
        return pendingDeposits + _estimateAUstBalanceInUst();
    }
}
