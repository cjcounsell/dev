# modules/ssh/

## Responsibility
Fetches SSH keys from Bitwarden and configures local SSH identity.

## Design
Secrets-driven module with hard failure if the SSH key ID is missing. It writes private/public keys with correct permissions and primes `ssh-agent`.

## Data & Control Flow
Ensures a Bitwarden session, extracts key material with `jq`, stores it under `~/.ssh`, then adds the key to the agent and rewires git remote if this repo is present.

## Integration Points
Depends on `cli-tools` and `secrets`; touches GitHub SSH remotes and local agent state.
