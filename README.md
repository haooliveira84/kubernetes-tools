# Kubernetes Tools

Kubernetes Tools is a set of scripts that simplifies daily Kubernetes operations.

## Available tools

### Context & namespace
| Command | Description |
|---|---|
| `kctx` | List/switch contexts (`-s` interactive, `-` last) |
| `kns` | List/switch namespaces (`-s` interactive) |

### Inspect
| Command | Description |
|---|---|
| `kpod` | List/describe pods (`-a` all, `-o` wide, `-s <status>`, `-w` watch) |
| `knode` | Node info: capacity, taints, hosted pods |
| `kall` | Overview of a namespace (pods, svc, ingress, deploy, hpa, pvc, jobs) |
| `kevents` | Events sorted by `lastTimestamp` (`-W` warnings only) |
| `ktop` | Top pods/nodes (`-N` nodes, `-m` sort by memory) |
| `kimg` | List container images in use |

### Interact
| Command | Description |
|---|---|
| `kexec` | Shell into a container or run a custom command (`kexec <pod> -- <cmd>`) |
| `klogs` | Logs (`-f` follow, `--tail N`, `--since 10m`, `-p` previous, `-a` all containers) |
| `kpf` | Port-forward a pod or service (`-s` for service) |
| `kdebug` | Debug a pod with an ephemeral container (`nicolaka/netshoot` by default) |
| `kcopy` | Copy busybox into a container (legacy — prefer `kdebug`) |
| `ksecret` | List/decode secrets without manual `base64 -d` |

### Operate
| Command | Description |
|---|---|
| `krestart` | `rollout restart` deployment/statefulset/daemonset (`-w` watches the rollout) |
| `kscale` | Scale a deployment quickly |
| `kclean` | Delete Evicted/Failed/Completed pods (`--dry-run`, `-y`) |
| `kdiff` | Server-side diff against a manifest file before `kubectl apply` |

All commands accept `-n <namespace>` and `-h/--help`. When `fzf` is installed it is used as the interactive picker; otherwise the built-in `select` is used.

## How to use
List all the available tools:
```sh
ktools
```

For usage of each tool:
```sh
[tool_name] -h
```

## Installation

### Install via Homebrew tap
```sh
brew tap haooliveira84/tap
brew install kubernetes-tools
```

Shell completion (bash, zsh, fish) is installed automatically into Homebrew's
standard completion paths — no extra step required. If completions don't show
up, make sure your shell loads `brew shellenv` and (for bash) has the
`bash-completion` package enabled.

### Manual installation
```sh
git clone https://github.com/haooliveira84/kubernetes-tools ~/kubernetes-tools
# add to your .bashrc / .zshrc / config.fish
export PATH="$HOME/kubernetes-tools/bin:$PATH"
ktools --init
```

### Pre-built tarball (no git required)
Each release attaches a curated tarball + zip and a `sha256sums.txt`:

```sh
VERSION=2.2.0
curl -fsSL -o ktools.tar.gz \
  "https://github.com/haooliveira84/kubernetes-tools/releases/download/v${VERSION}/kubernetes-tools-${VERSION}.tar.gz"

# Verify checksum (optional but recommended)
curl -fsSL "https://github.com/haooliveira84/kubernetes-tools/releases/download/v${VERSION}/sha256sums.txt" \
  | grep "kubernetes-tools-${VERSION}.tar.gz" | sha256sum -c -

tar -xzf ktools.tar.gz -C ~
export PATH="$HOME/kubernetes-tools-${VERSION}/bin:$PATH"
ktools --init
```

#### Bash completion
```sh
source $HOME/kubernetes-tools/completion/__completion
```

#### Zsh completion
```sh
autoload -U compaudit compinit bashcompinit
compaudit && compinit && bashcompinit
source $HOME/kubernetes-tools/completion/__completion
```

#### Fish completion
```fish
cp $HOME/kubernetes-tools/completion/kubernetes-tools.fish ~/.config/fish/completions/
```

## Recommended companions
- [`fzf`](https://github.com/junegunn/fzf) — fuzzy picker (auto-detected by interactive commands)
- [`colordiff`](https://www.colordiff.org/) — coloured output for `kdiff`
- `metrics-server` — required by `ktop`

## Releasing (maintainers)

Tagged commits trigger an automated release pipeline that:
1. Creates a GitHub Release with auto-generated notes.
2. Computes the tarball SHA-256.
3. Opens a pull request bumping `Formula/kubernetes-tools.rb`.

To cut a release locally:
```sh
./scripts/release.sh 2.2.0
```

The script bumps the version in `bin/__common`, creates an annotated tag and pushes it. The rest happens in GitHub Actions.

## License
MIT — see [LICENSE](LICENSE).

## Release Notes

### v2.3.0
- Homebrew install now wires bash/zsh/fish completions into Homebrew's standard
  completion paths — `ktools --init` is no longer required for brew users.
- Added native zsh completion (`_ktools`) that loads via `bashcompinit`.
- Fixed `kpf` completion (was completing services; now completes pods, and
  switches to services when `-s` is the previous argument).
- Added pod completion for `kevents`.

### v2.2.0
- New commands: `kevents`, `kpf`, `krestart`, `kdebug`, `ksecret`, `knode`, `kall`, `kclean`, `ktop`, `kscale`, `kdiff`, `kimg`.
- Fixed `-n NAMESPACE` flag handling in `kpod`, `kexec`, `klogs`, `kcopy`.
- `klogs` now supports `-f`, `--tail`, `--since`, `--previous`, `--all-containers`, `--timestamps`.
- `kexec` accepts custom commands (`kexec <pod> -- <cmd>`).
- `kcopy` verifies busybox checksum and retries on failure.
- `kctx` adds `-s` interactive and `-` switch-to-previous.
- All interactive pickers use `fzf` when available, fall back to `select`.

### v2.1.0 - 26/10/2018
- Added `klogs`.
- Added fish-shell completions.

### v2.0.1 - 23/10/2018
- Updated `kcp` from binary copy to download.
- Fixed pod name auto completion.

### v2.0.0 - 15/10/2018
- Changed to developer workflow.
- Updated `kctx`, `kns`, `kpod`, `kcopy`.
- Removed `kbak`, `kds`, `klogs`.

### v1.2.0 - 08/08/2018
- Updated `kexec`, `kns`, `kpod`, `kctx`, `kds`.
- Added `kcp`.

### v1.0.0 - 07/08/2017
- Initial release.
