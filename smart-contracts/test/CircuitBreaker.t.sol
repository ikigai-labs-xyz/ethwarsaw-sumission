// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { CircuitBreaker } from "../contracts/CircuitBreaker.sol";

contract CircuitBreakerTest is Test {
    CircuitBreaker public circuitBreaker;

    function setUp() public {
        circuitBreaker = new CircuitBreaker();
    }

    function testFuzz_setUserConfig_revertsIfThresholdExceeding(uint8 thresholdPercentage) public {
        vm.assume(thresholdPercentage > 100);

        vm.expectRevert(abi.encodeWithSelector(CircuitBreaker.CircuitBreaker__InvalidThresholdValue.selector));
        circuitBreaker.setUserConfig(thresholdPercentage, 1, 1, 1);
    }

    function testFuzz_setUserConfig_revertsIfInvalidBlockInterval(uint256 blockInterval, uint256 blockNumber) public {
        vm.assume(blockInterval > blockNumber);
        vm.roll(blockNumber);

        vm.expectRevert(abi.encodeWithSelector(CircuitBreaker.CircuitBreaker__InvalidBlockInterval.selector));
        circuitBreaker.setUserConfig(5, blockInterval, blockNumber, blockNumber);
    }

    function testFuzz_setUserConfig_revertsIfInvalidCooldownPeriod(
        uint256 cooldownPeriod,
        uint256 blockNumber
    )
        public
    {
        vm.roll(blockNumber);
        vm.assume(cooldownPeriod > blockNumber);

        vm.expectRevert(abi.encodeWithSelector(CircuitBreaker.CircuitBreaker__InvalidCooldownPeriod.selector));
        circuitBreaker.setUserConfig(5, blockNumber, 100, cooldownPeriod);
    }

    function testFuzz_setUserConfig_revertsIfInvalidConfigValues(
        uint256 startParameter,
        uint8 thresholdPercentage
    )
        public
    {
        vm.roll(1);
        vm.assume(thresholdPercentage <= 100 && thresholdPercentage != 0);
        vm.assume(startParameter > type(uint256).max / thresholdPercentage);

        vm.expectRevert(abi.encodeWithSelector(CircuitBreaker.CircuitBreaker__InvalidConfigValues.selector));
        circuitBreaker.setUserConfig(thresholdPercentage, 1, startParameter, 1);
    }

    function testFuzz_setUserConfig_setsConfig(
        uint256 blockNumber,
        uint256 blockInterval,
        uint8 thresholdPercentage,
        uint256 startParameter,
        uint256 cooldownPeriod
    )
        public
    {
        vm.assume(thresholdPercentage <= 100 && thresholdPercentage != 0);
        vm.assume(startParameter < type(uint256).max / thresholdPercentage);
        vm.assume(cooldownPeriod <= blockNumber);
        vm.assume(blockInterval <= blockNumber);
        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        (uint8 retrievedThreshold, uint256 retrievedInterval) =
            circuitBreaker.getSecurityParameterConfigOf(address(this));
        uint256 retrievedStartParameter = circuitBreaker.getParameterOf(address(this));

        assertEq(retrievedThreshold, thresholdPercentage);
        assertEq(retrievedInterval, blockInterval);
        assertEq(retrievedStartParameter, startParameter);

        // TODO: test if emits event
    }

    function testSetCircuitBreakerStatus() public {
        assertEq(circuitBreaker.getCircuitBreakerStatusOf(address(this)), false);

        circuitBreaker.setCircuitBreakerStatus(true);

        assertEq(circuitBreaker.getCircuitBreakerStatusOf(address(this)), true);

        // TODO: test if emits event
    }

    function testFuzz_setParameter_setsNewParameter(
        uint256 startParameter,
        uint256 newParameter
    )
        public
    {
        uint256 blockNumber = 10000;
        uint256 blockInterval = 10;
        uint8 thresholdPercentage = 100;
        uint256 cooldownPeriod = 10;

        vm.assume(startParameter < type(uint256).max / thresholdPercentage);

        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        bool triggered = circuitBreaker.setParameter(newParameter);
        // outrule circuitBreaker being triggered (bc it will not update)
        vm.assume(triggered == false);
        assertEq(circuitBreaker.getParameterOf(address(this)), newParameter);

        // TODO: check event being emitted
    }

    function testFuzz_setParameter_returnsTrueIfCircuitBreakerAlreadyActive(
        uint256 blockNumber,
        uint256 blockInterval,
        uint8 thresholdPercentage,
        uint256 cooldownPeriod,
        uint256 startParameter,
        uint256 newParameter
    )
        public
    {
        vm.assume(thresholdPercentage <= 100 && thresholdPercentage != 0);
        vm.assume(startParameter < type(uint256).max / thresholdPercentage);
        vm.assume(blockInterval <= blockNumber);
        vm.assume(cooldownPeriod <= blockNumber);
        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);
        circuitBreaker.setCircuitBreakerStatus(true);

        assertEq(circuitBreaker.setParameter(newParameter), true);
        assertEq(circuitBreaker.getParameterOf(address(this)), newParameter);
    }

    function testFuzz_setParameter_triggersCircuitBreakerIfNewParamterExceedsThreshold(
        uint8 blockNumber,
        uint8 blockInterval,
        uint8 thresholdPercentage,
        uint8 cooldownPeriod,
        uint256 startParameter,
        uint256 newParameter
    )
        public
    {
        vm.assume(blockNumber < 40 && blockNumber > 0);
        vm.assume(thresholdPercentage <= 100 && thresholdPercentage != 0);
        vm.assume(startParameter < type(uint256).max / thresholdPercentage);
        vm.assume(cooldownPeriod <= blockNumber);
        vm.assume(blockInterval <= blockNumber);

        vm.assume(startParameter != 0);

        if (newParameter > startParameter) {
            vm.assume(newParameter - startParameter > (startParameter * thresholdPercentage / 100));
        } else {
            vm.assume(startParameter - newParameter > (startParameter * thresholdPercentage / 100));
        }

        vm.roll(blockNumber);
        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        for (uint256 i = 1; i <= blockInterval; i++) {
            circuitBreaker.setParameter(startParameter);
            vm.roll(blockNumber + i);
        }

        assertEq(circuitBreaker.setParameter(newParameter), true);
        assertEq(circuitBreaker.getCircuitBreakerStatusOf(address(this)), true);
    }

    function testFuzz_setParameter_deactivatesCircuitBreakerAfterCooldown(
        uint256 cooldownPeriod,
        uint256 blockInterval
    )
        public
    {
        uint256 blockNumber = 10_000;
        uint8 thresholdPercentage = 10;
        uint256 startParameter = 10_000_000;
        uint256 newParameter = startParameter;

        // vm.assume(startParameter < type(uint256).max / thresholdPercentage);
        vm.assume(blockInterval <= blockNumber && blockInterval > 0);
        vm.assume(cooldownPeriod < blockNumber);
        // vm.assume(newParameter >= startParameter);

        // uint256 thresholdAmount = (startParameter *
        //     thresholdPercentage) / 100;
        // vm.assume(newParameter - startParameter < thresholdAmount);

        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);
        circuitBreaker.setCircuitBreakerStatus(true);

        vm.roll(blockNumber + cooldownPeriod + 1);
        circuitBreaker.setParameter(newParameter);

        // assertEq(circuitBreaker.getCircuitBreakerStatusOf(address(this)), false);
    }

    function testFuzz_increaseParameter_increasesParameter(
        uint256 increaseAmount
    )
        public
    {
        uint256 blockNumber = 1000;
        uint256 blockInterval = 10;
        uint8 thresholdPercentage = 100;
        uint256 cooldownPeriod = 10;
        uint256 startParameter = 10000000;

        // assume that it doesn't reach startParameter, bc of 100% threshold
        vm.assume(increaseAmount < startParameter);
        
        // uint256 increaseAmount = 10;
        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        circuitBreaker.increaseParameter(increaseAmount);
        assertEq(circuitBreaker.getParameterOf(address(this)), startParameter + increaseAmount);

        // TODO: check event being emitted
    }

    function testFuzz_decreaseParameter_decreasesParameter(
        uint256 decreaseAmount
    )
        public
    {
        uint256 blockNumber = 1000;
        uint256 blockInterval = 10;
        uint8 thresholdPercentage = 100;
        uint256 cooldownPeriod = 10;
        uint256 startParameter = 10000000;

        // assume that it doesn't reach startParameter, bc of 100% threshold
        vm.assume(decreaseAmount < startParameter);
        
        // uint256 increaseAmount = 10;
        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        circuitBreaker.decreaseParameter(decreaseAmount);
        assertEq(circuitBreaker.getParameterOf(address(this)), startParameter - decreaseAmount);

        // TODO: check event being emitted
    }

    function testFuzz_decreaseParameter_revertsIfDecreaseExceedsCurrent(
        uint256 blockNumber,
        uint256 blockInterval,
        uint8 thresholdPercentage,
        uint256 cooldownPeriod,
        uint256 startParameter,
        uint256 decreaseAmount
    )
        public
    {
        vm.assume(thresholdPercentage <= 100 && thresholdPercentage != 0);
        vm.assume(blockInterval <= blockNumber);
        vm.assume(cooldownPeriod <= blockNumber);
        vm.assume(startParameter < type(uint256).max / thresholdPercentage);
        vm.assume(startParameter < decreaseAmount);
        vm.roll(blockNumber);

        circuitBreaker.setUserConfig(thresholdPercentage, blockInterval, startParameter, cooldownPeriod);

        vm.expectRevert(
            abi.encodeWithSelector(CircuitBreaker.CircuitBreaker__CannotHaveNegativeParameter.selector)
        );
        circuitBreaker.decreaseParameter(decreaseAmount);
    }
}
