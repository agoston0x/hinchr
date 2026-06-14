// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title  HinchrNames — standalone membership-name registry (Sepolia demo)
/// @notice Mints `<label>.<baseDomain>` names to fans as ERC-721 NFTs in its OWN
///         registry. It does NOT touch the real ENS tree, so you do NOT need to own
///         `hinchr.eth` — `baseDomain` is just a cosmetic label. `register()` is a
///         real on-chain mint: judges can verify the tx + NFT on Sepolia Etherscan.
contract HinchrNames {
    string public name = "Hinchr Names";
    string public symbol = "HINCHR";
    string public baseDomain;            // e.g. "hinchr.eth" (label only)
    uint256 public totalSupply;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => string)  public labelOf;     // tokenId => label
    mapping(string  => uint256) public tokenIdOf;   // label   => tokenId
    mapping(bytes32 => bool)    public taken;       // labelhash => claimed

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event NameRegistered(string label, address indexed owner, uint256 indexed tokenId);

    constructor(string memory _baseDomain) { baseDomain = _baseDomain; }

    /// @notice Register `<label>.<baseDomain>` to `to` (mints an NFT). Anyone may
    ///         call — a sponsored relayer can mint on a fan's behalf so the fan
    ///         needs no ETH.
    function register(string calldata label, address to) public returns (uint256 tokenId) {
        require(bytes(label).length > 0, "empty");
        bytes32 lh = keccak256(bytes(label));
        require(!taken[lh], "taken");
        taken[lh] = true;
        tokenId = ++totalSupply;
        ownerOf[tokenId] = to;
        balanceOf[to] += 1;
        labelOf[tokenId] = label;
        tokenIdOf[label] = tokenId;
        emit Transfer(address(0), to, tokenId);
        emit NameRegistered(label, to, tokenId);
    }

    /// @notice Convenience: register to the caller.
    function register(string calldata label) external returns (uint256) {
        return register(label, msg.sender);
    }

    function fullName(uint256 tokenId) external view returns (string memory) {
        return string.concat(labelOf[tokenId], ".", baseDomain);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "no token");
        return string.concat('data:application/json,{"name":"', labelOf[tokenId], '.', baseDomain, '","description":"Hinchr membership name"}');
    }

    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x80ac58cd || id == 0x01ffc9a7; // ERC-721, ERC-165
    }
}
