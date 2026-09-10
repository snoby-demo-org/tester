# civicnet Node — tester

asfdas

A **civicnet** full node. This repo vendors the upstream source,
applies local patches, builds a Docker image, and deploys with Docker Compose
(RPC / P2P / ZMQ).

## What this is

- `src/` — vendored upstream source (https://github.com/CivicLight/CivicNet.git)
- `patches/` — local source patches (applied both locally and at image build)
- `Dockerfile` — builds the node binaries (civicnet-node,civicnet-cli,civicnet-wallet)
- `build.sh` — builds `iotapi322/crypto-node:<local-sha>` from the local tree
- `patch.sh` — vendors the upstream source + applies `patches/`
- `.github/workflows/` — GitHub Actions workflows (selected at scaffold time):
  - `build-node.yml` — build+push the node image on the k8s self-hosted runner
    (ARC scale set `k8s-runner`). Trigger with "Run workflow",
    optionally passing an upstream tag to vendor+build.
  - `ci.yml` — validates the repo's YAML parses on push/PR.
  - `dagger-checks.yml` — lint + PII scan + static-analyzer / private-key /
    format stubs via the shared Dagger engine.
  - `smoke.yml` — builds the image and boots the node to confirm RPC/health.
- `deploy-tester.service` — systemd unit wrapping `docker run`

## Build

```bash
./patch.sh                                          # vendor upstream + apply patches
cp civicnet.conf.example civicnet.conf
./build.sh                                          # -> iotapi322/crypto-node:<sha>
```

### Patching
`patch.sh` clones `https://github.com/CivicLight/CivicNet.git` into `./src`
and applies every `patches/*.patch` with `patch -p1`. The Dockerfile re-applies
the same patches at build time. To add your own change:

```sh
./patch.sh
cd src
# edit source...
git diff > ../patches/99-my-change.patch
cd ..
./build.sh
```

## Deploy (systemd)

The node runs as a **systemd unit** wrapping `docker run`. No node flags are
passed on the command line — the daemon **picks up its config automatically**
from the datadir. The host config `civicnet.conf` is
**mounted read-only** into the container at
`/root/.civicnet/civicnet.conf`,
so the daemon's default datadir lookup finds it.

```bash
sudo cp deploy-tester.service /etc/systemd/system/tester.service
sudo cp civicnet.conf.example /root/.civicnet/civicnet.conf
sudo nano /root/.civicnet/civicnet.conf   # set rpcpassword
sudo systemctl enable --now tester
```

State in a docker volume `tester-data`. Ports:

| Port | Purpose |
|------|---------|
| 9332 | JSON-RPC |
| 9333 | P2P |
| 28332-28335 | ZMQ (hashblock/hashtx/rawblock/rawtx) |
