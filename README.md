# machines

Inventory of every SSH-reachable machine, and the generator that turns it into
real ssh config.

## Flow

```
machines.yaml  --( make sync )-->  ~/.ssh/config.d/machines  <--Include--  ~/.ssh/config
```

`machines.yaml` is the only file you edit. Everything else is generated.

`~/.ssh/config` contains a single `Include ~/.ssh/config.d/*` at the top; add
hand-written overrides below that line and they will survive `make sync`.

## Daily use

Because the names land in real ssh config, they work in every tool that reads
it, not just in `make`:

```sh
ssh oci
scp dump.sql hosto-prod:/tmp/
rsync -a ./dist/ staticsite1:/var/www/
ssh -L 5432:localhost:5432 hostodash
code --remote ssh-remote+pve-2 /root
docker save hosto-api:prod | ssh hosto-prod "docker load"
```

## Commands

| command | does |
| --- | --- |
| `make sync` | regenerate ssh config from `machines.yaml` |
| `make ls` | table of every machine |
| `make ping` | TCP-check which machines are alive |
| `make audit` | ssh into each active machine, report hostname/os/uptime/disk/docker/vhosts |
| `make dead` | list decommissioned machines |

`make audit` logs into live machines. It is read-only, but it is not passive -
run it deliberately. Limit it with `./bin/machines audit --only oci hostodash`.

## Adding a machine

```yaml
  newbox:
    host: 10.0.0.5          # IP, DNS name, or tailscale MagicDNS name
    user: root              # optional, defaults to `defaults.user`
    key: keys/newbox.key    # optional; relative paths resolve to this repo
    port: 2222              # optional
    provider: digitalocean
    purpose: "what it runs"
    status: active
```

Then `make sync`. `ssh newbox` works immediately.

## status field

| value | emitted to ssh config? | meaning |
| --- | --- | --- |
| `active` | yes | in use |
| `offline` | yes | real machine, currently down or off-network |
| `dead` | **no** | decommissioned; kept only so we remember it existed |

`dead` entries are the point of having an inventory file rather than just an
ssh config: the knowledge survives without cluttering tab-completion.

## Notes

- Tailscale peers here do **not** have Tailscale SSH enabled (`sshHostKeys` is
  empty on every peer). They are reached over MagicDNS but authenticate against
  plain `sshd`, so each still needs `user` and usually `key` pinned.
- The shared tailnet (`tail80da2c`: app-01t, control-01t, state-01t) only
  resolves by FQDN. Short names do not resolve from this node.
- Hosts with `proxy_command` are skipped by `make ping` - they are never
  reached by direct TCP, so a connect test would report a meaningless DOWN.
