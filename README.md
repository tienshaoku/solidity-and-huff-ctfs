## Foundry Commands

- Specify which address to use: `cast wallet address --mnemonic <mnemonic-path> --mnemonic-index <index>`

- remember to `--broadcast` to send out txs when running deployment script with `forge script`

## Tips

- `source .env` to use secrets with command line

## Forking with Anvil

- `anvil --fork-url <rpc-url>`

- if running tests in forked env, remember to `--rpc-url 127.0.0.1:8545` (Anvil's default endpoint)
