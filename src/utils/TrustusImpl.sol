// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "trustus/Trustus.sol";

/***
    An Implementation contract  needed for testing the trustus verification 
    in the offchain script scripts/sign-message.js
  */
contract TrustusImpl is Trustus {
    constructor(address _trustedAddress) {
        _setIsTrusted(_trustedAddress, true);
    }

    function verify(bytes32 request, Trustus.TrustusPacket calldata packet)
        public
        view
        returns (bool)
    {
        return _verifyPacket(request, packet);
    }

    function checkIsTrusted(address _acc) public view returns (bool) {
        return isTrusted[_acc];
    }

    function recoveredAddress1(
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        return ecrecover(messageHash, v, r, s);
    }

    function recoveredAddress2(Trustus.TrustusPacket calldata packet)
        public
        view
        returns (address)
    {
        // return
        //     keccak256(
        //         abi.encodePacked(
        //             "\x19\x01",
        //             _computeDomainSeparator(),
        //             keccak256(
        //                 abi.encode(
        //                     keccak256(
        //                         "VerifyPacket(bytes32 request,uint256 deadline,bytes payload)"
        //                     ),
        //                     packet.request,
        //                     packet.deadline,
        //                     packet.payload
        //                 )
        //             )
        //         )
        //     );
        return
            ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        _computeDomainSeparator(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "VerifyPacket(bytes32 request,uint256 deadline,bytes payload)"
                                ),
                                packet.request,
                                packet.deadline,
                                packet.payload
                            )
                        )
                    )
                ),
                packet.v,
                packet.r,
                packet.s
            );
    }
}
