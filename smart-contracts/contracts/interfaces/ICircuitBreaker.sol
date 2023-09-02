// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ICircuitBreaker {
    /// @notice Event emitted whenever the parameter for a given user gets changed
    event ParameterChanged(address indexed user, uint256 indexed newParameter);
    /// @notice Event emitted whenever the circuitBreaker status for a given user gets changed
    event CircuitBreakerStatusUpdate(address indexed user, bool indexed newStatus);

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
    function setParameter(uint256 newParameter) external returns (bool);

    /**
     * @notice Function for setting the configuration values for a circuitBreaker user
     * @param thresholdPercentage The threshold percentage to set for the circuitBreaker
     * @param blockInterval The block interval to set for the circuitBreaker
     * @dev The function emits the {ParameterChanged} event
     */
    function setUserConfig(
        uint8 thresholdPercentage,
        uint256 blockInterval,
        uint256 startParameter,
        uint256 cooldownPeriod
    )
        external;

    /**
     * @notice Function for manually setting the circuitBreaker status for a given user
     * @param newStatus The new status to set for the circuitBreaker
     * @dev This function can be used to manually activate or deactivate the circuitBreaker for a given user
     * ATTENTION: This function should especially be used to deactivate the circuitBreaker, in case it got triggered.
     * This function emits the {CircuitBreakerStatusUpdate} event
     */
    function setCircuitBreakerStatus(bool newStatus) external;

    /**
     * @notice Function for getting the circuitBreaker status for a given user
     * @param user The address to get the circuitBreaker status for
     * @return bool if the circuitBreaker is active for the given user
     */
    function getCircuitBreakerStatusOf(address user) external view returns (bool);

    /**
     * @notice Function for getting the security parameter for a given circuitBreaker user
     * @param user The address of the circuitBreaker user
     * @return uint256 the security parameter for the given user
     */
    function getParameterOf(address user) external view returns (uint256);

    /**
     * @notice Function for getting the security parameters for a given address
     * @param user The address to get the security parameters for
     * @return Returns The threshold and block interval set as security parameters for the address
     */
    function getSecurityParameterConfigOf(address user) external view returns (uint8, uint256);
}
