# Hinchr contracts

## HinchrRegistrar.sol

Mints `<label>.hinchr.eth` membership subdomains to fans on ENS (Sepolia testnet).

**How it works**
1. Owner of `hinchr.eth` authorises the registrar once:
   `ENS.setApprovalForAll(<registrar address>, true)`.
2. A fan (or a sponsored relayer, so the fan needs no gas) calls
   `mint("elmuneco", <fanAddress>)`.
3. The registrar creates the subnode, sets the resolver record to point the name
   at the fan, then transfers the name to the fan. Emits `NameMinted`.

**Deploy params (Sepolia)**
- `ens`      = `0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e` (ENS registry, same on Sepolia)
- `resolver` = Sepolia public resolver
- `rootNode` = `namehash("hinchr.eth")`

The app's "Become a member" flow calls `mint(...)` (simulated in the demo build;
swap the stub for a sponsored `mint` tx once `hinchr.eth` is held on Sepolia).
