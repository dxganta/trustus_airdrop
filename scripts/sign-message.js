const hre = require("hardhat");
const ethers = hre.ethers;
const assert = require("assert");

const { utils } = ethers;

const { solidityKeccak256, AbiCoder } = utils;

let abiCoder = new ethers.utils.AbiCoder();

const TrustusImpl = require("../out/TrustusImpl.sol/TrustusImpl.json");

// privateKey of the message signer
/***
 * Script showing how to sign a message offchain using ethers and
 * a simple test to prove the signing is correct
 */
const privateKey =
  "0xe237643df9533b98defe1e6540d90edfc66168e1941ffed8ccc39e8ecb912c80";

// the address of the EOA for the above mentioned privateKey
const trustedAddress = "0x703484b2c3f1e5f4034c27c979fe600eaf247086";

async function main() {
  const accounts = await ethers.getSigners();

  let trustusFactory = new ethers.ContractFactory(
    TrustusImpl.abi,
    TrustusImpl.bytecode,
    accounts[0]
  );

  let trustusImpl = await trustusFactory.deploy(trustedAddress);

  let request = utils.formatBytes32String("GetPrice(address)");
  const deadline = Date.now() + 100000;
  let payload = utils.formatBytes32String("69420");

  let packetHash = solidityKeccak256(
    ["bytes"],
    [
      abiCoder.encode(
        ["bytes32", "bytes32", "uint256", "bytes"],
        [
          solidityKeccak256(
            ["string"],
            ["VerifyPacket(bytes32 request,uint256 deadline,bytes payload)"]
          ),
          request,
          deadline,
          payload,
        ]
      ),
    ]
  );

  let domainSeparator = solidityKeccak256(
    ["bytes"],
    [
      abiCoder.encode(
        ["bytes32", "bytes32", "bytes32", "uint256", "address"],
        [
          solidityKeccak256(
            ["string"],
            [
              "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)",
            ]
          ),
          solidityKeccak256(["string"], ["Trustus"]),
          solidityKeccak256(["string"], ["1"]),
          31337,
          trustusImpl.address,
        ]
      ),
    ]
  );

  let messageHashOffChain = solidityKeccak256(
    ["bytes"],
    [
      utils.solidityPack(
        ["string", "bytes", "bytes32"],
        ["\x19\x01", domainSeparator, packetHash]
      ),
    ]
  );

  // sign the message with the private key
  const signingKey = new utils.SigningKey(privateKey);
  const { r, s, v } = signingKey.signDigest(messageHashOffChain);

  let packet = {
    v,
    r,
    s,
    request,
    deadline,
    payload,
  };

  let isVerified = await trustusImpl.verify(request, packet);
  assert(isVerified);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
