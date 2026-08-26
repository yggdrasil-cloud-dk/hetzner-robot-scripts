# hetzner-api

Utility scripts for interacting with the Hetzner Cloud API.

## Quick start
1. Install prerequisites.
2. Copy `.env.sample` to `.env` and populate credentials.
3. Run the server listing script.
4. Redeploy a server with its number from the list.

## Set a firewall rule

`set-FW-rule.sh` sets one input rule on a server's Hetzner Robot firewall:

```console
./set-FW-rule.sh SERVER RULE_NAME IP_VERSION PROTOCOL SOURCE_IP DESTINATION_IP SOURCE_PORT DESTINATION_PORT TCP_FLAGS ACTION
```

Use `-` for an unused optional rule value. For example, this permits SSH from
one IPv4 address:

```console
./set-FW-rule.sh 123456 ssh ipv4 tcp 203.0.113.10/32 - - 22 syn accept
```

The firewall endpoint receives the rule as input rule index `0`; consequently,
it replaces the firewall's input-rule list rather than appending to it.

## Open source metadata
- **License:** Apache License 2.0 (`LICENSE`)
- **Notices:** Attribution and legal notices in `NOTICE`

By contributing to this repository, you agree that your contributions are licensed under Apache-2.0.
