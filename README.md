## Foundry Commands

- Specify which address to use: `cast wallet address --mnemonic <mnemonic-path> --mnemonic-index <index>`

- Remember to `--broadcast` to send out txs when running deployment script with `forge script`

### Forking with Anvil

- `anvil --fork-url <rpc-url>`

- If running tests in forked env, remember to `--rpc-url 127.0.0.1:8545` (Anvil's default endpoint)

## Tips

- `source .env` to import secrets in command line
