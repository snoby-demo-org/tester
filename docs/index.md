# civicnet Node — tester

asfdas

A **civicnet** full node. This repo vendors the upstream source,
applies local patches, builds a Docker image, and deploys via systemd.

## Quick Links

- **Upstream source:** https://github.com/CivicLight/CivicNet.git
- **Binaries:** civicnet-node,civicnet-cli,civicnet-wallet

## Repository layout

| Path | Purpose |
|------|---------|
| `src/` | Vendored upstream source |
| `patches/` | Local source patches (applied locally + at image build) |
| `Dockerfile` | Builds the node binaries |
| `build.sh` | Builds `iotapi322/crypto-node:<local-sha>` |
| `patch.sh` | Vendors upstream + applies `patches/` |
| `deploy-tester.service` | systemd unit wrapping `docker run` |
| `.github/workflows/build-node.yml` | CI: build + push image on self-hosted runner |

## Networking

| Port | Purpose |
|------|---------|
| 9332 | JSON-RPC |
| 9333 | P2P |

## Build

```bash
./patch.sh                                          # vendor upstream + apply patches
cp civicnet.conf.example civicnet.conf
./build.sh                                          # -> iotapi322/crypto-node:<sha>
```

## Deploy (systemd)

```bash
sudo cp deploy-tester.service /etc/systemd/system/tester.service
sudo cp civicnet.conf.example /root/.civicnet/civicnet.conf
sudo nano /root/.civicnet/civicnet.conf   # set rpcpassword
sudo systemctl enable --now tester
```

State lives in a docker volume `tester-data`. The host config
is mounted read-only into the container, and the daemon picks it up automatically
from its default datadir — no node CLI flags are required.
