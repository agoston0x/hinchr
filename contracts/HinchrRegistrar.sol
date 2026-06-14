// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Minimal ENS interfaces (registry + resolver) we rely on.
interface ENS {
    function owner(bytes32 node) external view returns (address);
    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;
}

interface AddrResolver {
    function setAddr(bytes32 node, address addr) external;
}

/// @title  HinchrRegistrar
/// @notice Mints `<label>.hinchr.eth` membership names to fans on ENS.
///         The owner of `hinchr.eth` authorises this contract once
///         (`ENS.setApprovalForAll(registrar, true)`); thereafter any fan can
///         claim a free, untaken subdomain pointing at their own address.
/// @dev    Deployed on Sepolia for the Hinchr demo. `rootNode` is
///         namehash("hinchr.eth"); `resolver` is the public ENS resolver.
contract HinchrRegistrar {
    ENS public immutable ens;
    address public immutable resolver;
    bytes32 public immutable rootNode; // namehash("hinchr.eth")
    address public owner;

    mapping(bytes32 => address) public ownerOfLabel; // labelhash => fan
    event NameMinted(string label, address indexed fan, bytes32 indexed node);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(ENS _ens, address _resolver, bytes32 _rootNode) {
        ens = _ens;
        resolver = _resolver;
        rootNode = _rootNode;
        owner = msg.sender;
    }

    /// @notice Claim `<label>.hinchr.eth` for `fan`, resolving the name to `fan`.
    /// @dev    Reverts if the label is already taken. Anyone may call on behalf
    ///         of a fan (e.g. a sponsored relayer) so the fan needs no gas.
    function mint(string calldata label, address fan) external {
        bytes32 labelhash = keccak256(bytes(label));
        require(ownerOfLabel[labelhash] == address(0), "label taken");
        ownerOfLabel[labelhash] = fan;

        // 1) create the subnode owned by this contract so it can set the record
        ens.setSubnodeRecord(rootNode, labelhash, address(this), resolver, 0);

        // 2) point the name at the fan's address
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelhash));
        AddrResolver(resolver).setAddr(node, fan);

        // 3) hand the name to the fan
        ens.setSubnodeRecord(rootNode, labelhash, fan, resolver, 0);

        emit NameMinted(label, fan, node);
    }

    /// @notice Compute the namehash of `<label>.hinchr.eth` off the root node.
    function nodeOf(string calldata label) external view returns (bytes32) {
        return keccak256(abi.encodePacked(rootNode, keccak256(bytes(label))));
    }

    function transferOwnership(address to) external onlyOwner {
        owner = to;
    }
}
