# AGENTS.md

Personal Nix flake managing several machines. `README.md` holds the user-facing
docs (install, keybinding philosophy, troubleshooting) — read it before changing
desktop/keybinding configs; the keybinding hierarchy there is a hard convention.

## Commands

- `just` lists everything. Recipes auto-detect user/host — never hardcode
  `#user@host` unless testing another machine.
- `just home` — home-manager switch; `just home-trace` for `--show-trace`.
- `just system` — system-manager (Ubuntu hosts); `just nixos` — NixOS hosts (pi).
- `just rebuild` — dispatches system vs nixos by `/etc/NIXOS`, then home.
- `just check` (`nix flake check`) and `just fmt` for verification. Agents should
  normally stop at `fmt` + `check`; switching changes the user's live machine, so
  ask before running `just home`/`system`/`rebuild`.
- Evaluate without activating:
  `nix build .#homeConfigurations."drakkir@terra".activationPackage --no-link`

## Formatting

`nix fmt` is `pedantix` (see `flake.nix` `formatter`), configured by
`pedantix.toml`: nixfmt + **sorted attrs, sorted lets, sorted inherits, merged
attrpaths**. Write new attrsets alphabetically or the formatter will rewrite the
diff. Lists are intentionally not sorted (order is often significant).

## Layout / wiring

- `flake.nix` is the only registry: `homeConfigurations."<user>@<host>"`,
  `systemConfigs.<host>` (system-manager, Ubuntu), `nixosConfigurations.<host>`.
  Adding a host means adding a file **and** an entry here.
- `hosts/<host>/` = system level, `home/<user>/<host>.nix` = user level. Both
  pull from `common/core` (always on) vs `common/optional` (opt-in by import).
  Keep that split: don't put host-specific or optional things in `core`.
- `lib/` is merged into `lib` via `nixpkgs.lib.extend`, exposed as `lib.custom`
  (also `lib.hm`, hand-injected from home-manager to avoid missing-`lib.hm`
  errors).
- Modules receive `inputs outputs lib system username configUser hostname
  homeDirectory` via specialArgs/extraSpecialArgs.
- `pkgs/default.nix` custom packages are applied as an overlay (`pkgs.xtrayhide`).
  `overlays/default.nix` is currently empty.

## Dotfiles are out-of-store symlinks

`dotfiles/` is symlinked live into `~/.config` via
`lib.custom.symlink.mkXdgConfigLinks config [ "nvim" ... ]` /
`.link config "path"`. It resolves to `~/.config/nix/dotfiles/...`, so editing
those files takes effect **without a rebuild** — and the repo must stay at
`~/.config/nix`. Add plain config text to `dotfiles/`, not to Nix strings.

## Gotchas

- `work` host: login is `rhagelin@creatorctek.local` with home
  `/home/rhagelin.creatorctek.local`; the justfile strips `@domain` and maps the
  real hostname (`*CTEKLIN*`) to `work`. Add new hostname mappings to
  `config-host` in the justfile.
- `pi` is aarch64 NixOS with home-manager as a NixOS module; everything else is
  x86_64 Ubuntu with system-manager + standalone home-manager. Options available
  under NixOS are often *not* available under system-manager.
- Justfile sets `pipefail` on purpose: recipes pipe into `nom`, which otherwise
  hides rebuild failures. Keep it if you add recipes.
- No CI, no test suite. `nix flake check` is the only automated gate.
