
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GasGriefingDetector {

    uint256 public baselineGas = 30000;
    uint256 public thresholdMultiplier = 3;

    function detectGasAttack(uint256 gasUsed)
        public
        view
        returns (bool)
    {
        return gasUsed > baselineGas * thresholdMultiplier;
    }
}
