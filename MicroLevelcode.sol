// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MicroLevelResearchValidator {

    struct SectorStats {
        uint256 meanGas;
        uint256 stdGas;
        uint256 meanFraud;
        uint256 meanFee;
    }

    struct ContractData {
        string sector;
        uint256 gasBefore;
        uint256 gasAfter;
        uint256 fraudBefore;
        uint256 fraudAfter;
        uint256 transactionValue;
        uint256 transactionFee;
        bool validated;
        uint256 anomalyScore;
    }

    mapping(bytes32 => SectorStats) public sectorStats;
    mapping(uint256 => ContractData) public records;

    uint256 public recordCount;

    uint256 constant GAS_TARGET = 40;
    uint256 constant FRAUD_TARGET = 2;
    uint256 constant FEE_TARGET = 2;
    uint256 constant GAS_GRIEF_MULTIPLIER = 3;

    // -------------------------
    // 1️⃣ Set Sector Baseline
    // -------------------------
    function setSectorStats(
        string memory sector,
        uint256 meanGas,
        uint256 stdGas,
        uint256 meanFraud,
        uint256 meanFee
    ) public {
        sectorStats[keccak256(bytes(sector))] =
            SectorStats(meanGas, stdGas, meanFraud, meanFee);
    }

    // -------------------------
    // 2️⃣ Add Record (Excel Row)
    // -------------------------
    function addRecord(
        string memory sector,
        uint256 gasBefore,
        uint256 gasAfter,
        uint256 fraudBefore,
        uint256 fraudAfter,
        uint256 transactionValue,
        uint256 transactionFee
    ) public {

        bytes32 key = keccak256(bytes(sector));
        SectorStats memory s = sectorStats[key];

        // -------- Missing Value Imputation --------
        if (gasBefore == 0) gasBefore = s.meanGas;
        if (fraudBefore == 0) fraudBefore = s.meanFraud;
        if (transactionValue == 0) transactionValue = 100;

        // -------- Z-Score Outlier Correction --------
        if (s.stdGas > 0) {
            uint256 z = gasBefore > s.meanGas ?
                (gasBefore - s.meanGas) / s.stdGas :
                (s.meanGas - gasBefore) / s.stdGas;

            if (z > 3) {
                gasBefore = s.meanGas;
            }
        }

        recordCount++;

        records[recordCount] = ContractData(
            sector,
            gasBefore,
            gasAfter,
            fraudBefore,
            fraudAfter,
            transactionValue,
            transactionFee,
            false,
            0
        );
    }

    // -------------------------
    // 3️⃣ Verify Hypotheses
    // -------------------------
    function verify(uint256 id) public returns (bool) {

        ContractData storage d = records[id];

        uint256 gasReduction =
            ((d.gasBefore - d.gasAfter) * 100) / d.gasBefore;

        uint256 fraudPercent =
            (d.fraudAfter * 100) / d.fraudBefore;

        uint256 feePercent =
            (d.transactionFee * 100) / d.transactionValue;

        // AI-like weighted anomaly scoring
        uint256 score = 0;
        if (gasReduction < GAS_TARGET) score += 30;
        if (fraudPercent > FRAUD_TARGET) score += 40;
        if (feePercent > FEE_TARGET) score += 30;

        d.anomalyScore = score;

        if (
            gasReduction >= GAS_TARGET &&
            fraudPercent <= FRAUD_TARGET &&
            feePercent <= FEE_TARGET
        ) {
            d.validated = true;
            return true;
        }

        return false;
    }

    // -------------------------
    // 4️⃣ Gas Griefing Detection
    // -------------------------
    function detectGasGriefing(uint256 id)
        public
        view
        returns (bool)
    {
        ContractData memory d = records[id];
        bytes32 key = keccak256(bytes(d.sector));
        SectorStats memory s = sectorStats[key];

        if (d.gasBefore > s.meanGas * GAS_GRIEF_MULTIPLIER) {
            return true;
        }

        return false;
    }

    // -------------------------
    // 5️⃣ Batch Validation
    // -------------------------
    function batchVerify(uint256[] memory ids)
        public
        returns (uint256 successCount)
    {
        for (uint i = 0; i < ids.length; i++) {
            if (verify(ids[i])) {
                successCount++;
            }
        }
    }
}
