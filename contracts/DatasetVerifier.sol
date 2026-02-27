
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DatasetVerifier {

    struct ContractData {
        uint32 gasBefore;
        uint32 gasAfter;
        uint16 fraudBefore;
        uint16 fraudAfter;
        uint32 transactionValue;
        uint32 transactionFee;
        bool isValid;
    }

    mapping(uint256 => ContractData) public contractsData;
    uint256 public contractCount;

    function addContractData(
        uint32 _gasBefore,
        uint32 _gasAfter,
        uint16 _fraudBefore,
        uint16 _fraudAfter,
        uint32 _transactionValue,
        uint32 _transactionFee
    ) public {

        contractCount++;

        contractsData[contractCount] = ContractData(
            _gasBefore,
            _gasAfter,
            _fraudBefore,
            _fraudAfter,
            _transactionValue,
            _transactionFee,
            false
        );
    }

    function verifyConstraints(uint256 _id) public returns (bool) {

        ContractData storage data = contractsData[_id];

        uint256 gasReduction =
            ((data.gasBefore - data.gasAfter) * 100) / data.gasBefore;

        uint256 fraudPercent =
            (data.fraudAfter * 100) / data.fraudBefore;

        uint256 feePercent =
            (data.transactionFee * 100) / data.transactionValue;

        if (gasReduction >= 40 && fraudPercent <= 2 && feePercent <= 2) {
            data.isValid = true;
            return true;
        }

        return false;
    }
}
