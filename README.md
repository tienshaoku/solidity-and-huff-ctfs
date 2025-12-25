# Solidity & Huff CTFs

## Sources

- `openzeppelin-ethernaut`: [The Ethernaut](https://ethernaut.openzeppelin.com/)
- `capture-the-ether`: [Capture the Ether](https://capturetheether.com/)
- `rareskills`: [RareSkills/huff-puzzles](https://github.com/RareSkills/huff-puzzles)
- `huff-challenges`: [Huff Discord](https://discord.com/channels/980519274600882306)

## Foundry Commands

- Run tests in sets: `forge test test/<directory>/*.t.sol`

- Specify which address to use: `cast wallet address --mnemonic <mnemonic-path> --mnemonic-index <index>`

- Remember to `--broadcast` to send out txs when running deployment script with `forge script`

- Send ether on calls: `--value <value>`, e.g. `--value 0.01ether`

### Forking with Anvil

- `anvil --fork-url <rpc-url>`

- If running tests in forked env, remember to `--rpc-url 127.0.0.1:8545` (Anvil's default endpoint)

---

## Tips

- `source .env` to import secrets in command line

### Specs

- For test/capture-the-ether/FuzzingIdentity.t.sol, append `--gas-limit 1000000000000` to `forge test` and don't modify the file at all s.t. salt generation can be guaranteed
