# Hinchr contracts

## HinchrNames.sol — membership-name registry (Sepolia)

Standalone registry that mints `<label>.hinchr.eth` membership names as ERC-721 NFTs
in its **own** registry. It does **not** touch the real ENS tree, so no `hinchr.eth`
ownership is needed — `baseDomain` is a cosmetic label. `register()` is a real
on-chain mint; judges verify the tx + NFT on Sepolia Etherscan.

### Deploy (Remix, no keys shared)
1. remix.ethereum.org → new file → paste `HinchrNames.sol`.
2. Compile (0.8.20+).
3. Deploy & Run → Environment **Injected Provider (MetaMask on Sepolia)**.
4. Constructor `_baseDomain` = `hinchr.eth` → Deploy. Fund the wallet with Sepolia
   ETH from a faucet first.
5. Copy the deployed **contract address** → hand it to the app to wire the mint.

### Real per-user minting from the app
The app is a static (keyless) site, so it can't sign txs itself. Two options:
- **Demo (recommended):** app shows the real contract address + a real example
  `register()` tx (verifiable on Etherscan); in-app "mint" stays simulated.
- **Fully live:** add a small relayer that holds a throwaway funded key and calls
  `register(label, fanAddress)` — then the app's mint is a real tx per user.
