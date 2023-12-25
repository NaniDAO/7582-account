// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {SimpleAccount} from '@aa/samples/SimpleAccount.sol';

/// @notice ERC7570 extends ERC4337 accounts by specifying a plugin scheme for user operations.
contract ERC7570 is SimpleAccount {
    function validateUserOp(
        UserOperation calldata userOp, 
        bytes32 userOpHash, 
        uint256 missingAccountFunds
    ) external virtual override(BaseAccount) returns (uint256 validationData) {
        _requireFromEntryPoint();
        if (userOp.nonce > type(uint64).max) {
            bytes32 validatorHash = bytes32(userOp.nonce >> 64);
            validationData = _validateSignature(userOp, validatorHash);
            if (validationData == SIGNATURE_VALIDATION_FAILED) {
                return SIGNATURE_VALIDATION_FAILED;
            }
            ERC7570 validator = ERC7570(address(uint160(uint256(validatorHash))));
            validationData = validator.validateUserOp(userOp, userOpHash, missingAccountFunds);
        } else {
            validationData = _validateSignature(userOp, userOpHash);
        }
        _payPrefund(missingAccountFunds);
    }
}
