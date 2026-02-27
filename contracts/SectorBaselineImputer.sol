
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SectorBaselineImputer {

    struct SectorStats {
        uint256 meanGas;
        uint256 stdGas;
    }

    mapping(bytes32 => SectorStats) public sectorStats;

    function setSectorStats(
        string memory sector,
        uint256 meanGas,
        uint256 stdGas
    ) public {
        sectorStats[keccak256(bytes(sector))] =
            SectorStats(meanGas, stdGas);
    }

    function imputeGas(string memory sector, uint256 value)
        public
        view
        returns (uint256)
    {
        SectorStats memory s = sectorStats[keccak256(bytes(sector))];

        if (s.stdGas == 0) return s.meanGas;

        uint256 z = (value > s.meanGas)
            ? (value - s.meanGas) / s.stdGas
            : (s.meanGas - value) / s.stdGas;

        if (z > 3) {
            return s.meanGas;
        }

        return value;
    }
}
