// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/ICircuitBreaker.sol";

/**
 * @title CircuitBreaker
 * @notice This contract is the CircuitBreaker implementation, which can be used by any contract to implement an
 *  on-chain circuitBreaker. The circuitBreaker can be configured by the contract owner to set a threshold percentage, block
 * interval and start parameter. The circuitBreaker works by checking if the parameter for a given user has changed by more
 * than the threshold, when updating it. If the parameter has changed by more than the threshold, the circuitBreaker will be
 * activated for the given user. In a sophistaced implementation, the parameter could possible be the result of a
 * mathematical formula, which takes into account vital parameters of a user (protocol) that should not change by more
 * than a certain threshold. The circuitBreaker can be manually deactivated and actived by the user (protocol) at any time.
 */
contract CircuitBreaker is ICircuitBreaker {
    /// @notice This error is thrown if the threshold value is greater than 100 (100%)
    error CircuitBreaker__InvalidThresholdValue();
    /// @notice This error is thrown if the block interval is greater than the total number of blocks
    error CircuitBreaker__InvalidBlockInterval();
    /// @notice This error is thrown if the cooldown period is greater than the total number of blocks
    error CircuitBreaker__InvalidCooldownPeriod();
    /// @notice This error is thrown if the startParameter is too big to be multiplied by the threshold percentage
    error CircuitBreaker__InvalidConfigValues();
    /// @notice This error is thrown if the parameter is decreased bellow zero
    error CircuitBreaker__CannotHaveNegativeParameter();

    /// @dev CircuitBreaker configuration values for a given user
    struct CircuitBreakerConfig {
        /// @dev threshold for changes as a percentage (represented as an integer)
        uint8 thresholdPercentage;
        /// @dev the number of blocks to "go-back" to find reference paramter for CircuitBreaker check
        uint256 blockInterval;
        /// @dev the number of blocks to wait before switch off the circuitBreaker after it has been triggered
        uint256 cooldownPeriod;
    }

    struct ParameterData {
        uint256 parameter;
        uint256 blockNumber;
    }

    /// @dev Dynamic circuitBreaker state data for a given user
    struct CircuitBreakerData {
        mapping(uint32 nonce => ParameterData) parameters;
        // TODO: remove this and use the block number as indicator for the circuitBreaker status (0 for false)
        bool circuitBreakerActive;
        uint32 nonce;
        uint256 lastActivatedBlock;
    }

    mapping(address => CircuitBreakerData) private s_circuitBreakerData;
    mapping(address => CircuitBreakerConfig) private s_circuitBreakerConfig;

    /**
     * @notice Function for setting the parameter for a given user
     * @param newParamter The new parameter to set
     * @dev This function is internal and should only be called by the contract itself
     * This function emits the {ParameterChanged} event
     */
    function _setParameter(uint256 newParamter) internal {
        uint32 nonce = s_circuitBreakerData[msg.sender].nonce;
        s_circuitBreakerData[msg.sender].parameters[nonce] = ParameterData(newParamter, block.number);
        s_circuitBreakerData[msg.sender].nonce++;
        emit ParameterChanged(msg.sender, newParamter);
    }

    /**
     * @notice Function for setting the circuitBreaker status for a given user
     * @param newStatus The new status to set
     * @dev This function is internal and should only be called by the contract itself
     * This function emits the {CircuitBreakerStatusUpdate} event
     */
    function _setCircuitBreakerStatus(bool newStatus) internal {
        s_circuitBreakerData[msg.sender].circuitBreakerActive = newStatus;
        if (newStatus) {
            s_circuitBreakerData[msg.sender].lastActivatedBlock = block.number;
        }
        emit CircuitBreakerStatusUpdate(msg.sender, newStatus);
    }

    /**
     * @notice Function for checking if the parameter update is below the threshold
     * @param newParameter The new parameter to check
     * @return bool true if the parameter update exceeds the threshold, false otherwise
     */
    function _checkIfParameterUpdateExceedsThreshold(uint256 newParameter) internal view returns (bool) {
        CircuitBreakerConfig memory m_circuitBreakerConfig = s_circuitBreakerConfig[msg.sender];

        // Finding the ParameterData with a block number closest to 'block.number - m_circuitBreakerConfig.blockInterval'
        uint256 targetBlockNumber = block.number - m_circuitBreakerConfig.blockInterval;
        uint256 referenceParameter;
        uint32 nonce = s_circuitBreakerData[msg.sender].nonce;

        for (uint32 i = nonce; i > 0; i--) {
            if (s_circuitBreakerData[msg.sender].parameters[i].blockNumber <= targetBlockNumber) {
                // TODO: find a solution to avoid accessing storage at every iteration (possibly store the value as an
                // array in memory)
                referenceParameter = s_circuitBreakerData[msg.sender].parameters[i - 1].parameter;
                break;
            }
        }

        // insufficient data
        if (referenceParameter == 0) return false;

        uint256 thresholdAmount = (referenceParameter * m_circuitBreakerConfig.thresholdPercentage) / 100;

        if (newParameter > referenceParameter) {
            return newParameter - referenceParameter >= thresholdAmount;
        } else {
            return referenceParameter - newParameter >= thresholdAmount;
        }
    }

    /**
     * @notice Function for updating the security parameter
     * @dev This function can be called by any user to update their security parameter. If the parameter exceeds the
     * threshold,
     * the circuitBreaker will be automatically activated. If the circuitBreaker is already active, the parameter will be updated
     * anyways.
     *
     * Emits the {ParameterChanged} event
     * Emits the {CircuitBreakerStatusUpdate} event
     * @param newParameter is the new parameter
     * @return Returns true if the circuitBreaker was activated, or had alrady been active
     */
    function setParameter(uint256 newParameter) public returns (bool) {
        CircuitBreakerConfig memory m_circuitBreakerConfig = s_circuitBreakerConfig[msg.sender];

        /// @dev gas savings by skipping threshold check in case of active circuitBreaker
        if (s_circuitBreakerData[msg.sender].circuitBreakerActive) {
            /// @dev check if the cooldown period has passed
            bool cooldownSurpassed = false;
            if (block.number - s_circuitBreakerData[msg.sender].lastActivatedBlock > m_circuitBreakerConfig.cooldownPeriod) {
                _setCircuitBreakerStatus(false);
                cooldownSurpassed = true;

                //TODO: To discuss: we shouldn't update the circuitBreaker status as long as it is active
                //If we make an early return here we prevent checking again the circuitBreaker status
                // see
                // https://github.com/ikigai-labs-xyz/hundred-finance-circuitBreaker-replica/pull/2/commits/09c5b312222afde44b26621645815238335b0944
            }

            if (!cooldownSurpassed) {
                _setParameter(newParameter);
                return true;
            }
        }

        bool triggerCircuitBreaker = _checkIfParameterUpdateExceedsThreshold(newParameter);
        if (triggerCircuitBreaker) {
            _setCircuitBreakerStatus(true);
            return true;
        }

        _setParameter(newParameter);
        return triggerCircuitBreaker;
    }

    /**
     * @notice Function for increasing the security parameter
     * @dev This function can be called by any user to increase their security parameter.
     *
     * @param increaseAmount is the amount by which to increase the parameter
     * @return Returns true if the circuitBreaker was activated, or had already been active
     */
    function increaseParameter(uint256 increaseAmount) external returns (bool) {
        uint256 newParameter = getParameterOf(msg.sender) + increaseAmount;
        return setParameter(newParameter);
    }

    /**
     * @notice Function for decreasing the security parameter
     * @dev This function can be called by any user to decrease their security parameter.
     *
     * Emits the {ParameterChanged} event
     * Emits the {CircuitBreakerStatusUpdate} event
     * @param decreaseAmount is the amount by which to decrease the parameter
     * @return Returns true if the circuitBreaker was activated, or had already been active
     */
    function decreaseParameter(uint256 decreaseAmount) external returns (bool) {
        uint256 currentParameter = getParameterOf(msg.sender);
        if (currentParameter < decreaseAmount) {
            revert CircuitBreaker__CannotHaveNegativeParameter();
        }
        uint256 newParameter = currentParameter - decreaseAmount;
        return setParameter(newParameter);
    }

    /**
     * @notice Function for setting the configuration values for a circuitBreaker user
     * @param thresholdPercentage The threshold percentage to set for the circuitBreaker
     * @param blockInterval The block interval to set for the circuitBreaker
     * @param startParameter The start parameter to set for the circuitBreaker
     * @param cooldownPeriod The cooldown period to set for the circuitBreaker
     * @dev The function emits the {ParameterChanged} event
     */
    function setUserConfig(
        uint8 thresholdPercentage,
        uint256 blockInterval,
        uint256 startParameter,
        uint256 cooldownPeriod
    )
        external
    {
        if (thresholdPercentage > 100 || thresholdPercentage == 0) {
            revert CircuitBreaker__InvalidThresholdValue();
        }
        if (blockInterval > block.number) {
            revert CircuitBreaker__InvalidBlockInterval();
        }
        if (cooldownPeriod > block.number) {
            revert CircuitBreaker__InvalidCooldownPeriod();
        }
        if (startParameter > type(uint256).max / thresholdPercentage) {
            revert CircuitBreaker__InvalidConfigValues();
        }

        s_circuitBreakerConfig[msg.sender] = CircuitBreakerConfig(thresholdPercentage, blockInterval, cooldownPeriod);
        _setParameter(startParameter);
    }

    /// @inheritdoc ICircuitBreaker
    function setCircuitBreakerStatus(bool newStatus) external {
        _setCircuitBreakerStatus(newStatus);
    }

    /// @inheritdoc ICircuitBreaker
    function getCircuitBreakerStatusOf(address user) external view returns (bool) {
        return s_circuitBreakerData[user].circuitBreakerActive;
    }

    /// @inheritdoc ICircuitBreaker
    function getParameterOf(address user) public view returns (uint256) {
        return s_circuitBreakerData[user].parameters[s_circuitBreakerData[user].nonce - 1].parameter;
    }

    /// @inheritdoc ICircuitBreaker
    function getSecurityParameterConfigOf(address user) external view returns (uint8, uint256) {
        CircuitBreakerConfig memory m_circuitBreakerConfig = s_circuitBreakerConfig[user];
        return (m_circuitBreakerConfig.thresholdPercentage, m_circuitBreakerConfig.blockInterval);
    }
}
