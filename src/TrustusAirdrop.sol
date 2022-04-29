// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "trustus/Trustus.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/** contract to airdrop tokens to users using Trustus Oracle by ZeframLou
    The protocol needs to send a ECDSA signature to the users offchain 
    The user can then use that signature to withdraw tokens from the contract
 */
contract TrustusAirdrop is Trustus {
    IERC20 public token;
    // Packet Hash => withdrawn or not
    mapping(bytes32 => bool) private _withdrawn;

    constructor(address _token, address[] memory _trustedAddresses) {
        token = IERC20(_token);
        for (uint256 i = 0; i < _trustedAddresses.length; i++) {
            _setIsTrusted(_trustedAddresses[i], true);
        }
    }

    function withdrawTokens(bytes32 _request, TrustusPacket calldata _packet)
        public
        verifyPacket(_request, _packet)
    {
        // TODO: check the difference in gas costs between hashing the packet here & sending the packetHash in the function parameters itself
        bytes32 packetHash = hashPacket(_packet);
        require(!_withdrawn[packetHash], "Already withdrawn");

        (address account, uint256 amount) = abi.decode(
            _packet.payload,
            (address, uint256)
        );

        _withdrawn[packetHash] = true;

        require(token.transfer(account, amount), "Insufficient balance");
    }

    function hashPacket(TrustusPacket calldata _packet)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_packet));
    }
}
