# Nix Configuration Justfile

# Recipes pipe into `nom`, which would otherwise mask failures: without
# pipefail the shell reports nom's exit status, so a failed rebuild looks
# identical to a successful one. `sh` is bash here, so `|&` is available.
set shell := ["bash", "-cu", "-o", "pipefail"]

config-user := `id -un | sed 's/@.*//'`

# Map real hostnames to flake config names
# Add new entries as: *'<real-hostname>') echo '<config-name>' ;;
config-host := `case "$(hostname)" in *'CTEKLIN'*) echo 'work' ;; *) hostname ;; esac`

# Detect if this is a NixOS host
is-nixos := `[ -f /etc/NIXOS ] && echo 'true' || echo 'false'`

default:
  @just --list

[group('build')]
home *ARGS:
  home-manager switch --flake ~/.config/nix#{{config-user}}@{{config-host}} {{ARGS}} |& nom

[group('build')]
home-trace *ARGS:
  home-manager switch --flake ~/.config/nix#{{config-user}}@{{config-host}} --show-trace {{ARGS}} |& nom

# Rebuild system-manager configuration
[group('build')]
system:
  system-manager switch --sudo --flake ~/.config/nix#{{config-host}}

# Rebuild NixOS configuration (for NixOS hosts like pi)
[group('build')]
nixos:
  sudo nixos-rebuild switch --flake ~/.config/nix#{{config-host}}

# Full rebuild — uses NixOS rebuild on NixOS, otherwise home + system-manager
[group('build')]
rebuild:
  @if [ "{{is-nixos}}" = "true" ]; then just nixos; else just system; fi
  just home

[group('maintenance')]
check:
  nix flake check

[group('maintenance')]
fmt:
  # Explicit file list: `**/*.nix` only expands one level deep without bash's
  # globstar (it silently formatted 3 of 55 files), and bare `nix fmt` hands
  # pedantix the directory, which makes it choke on empty input.
  nix fmt -- $(git ls-files '*.nix')

[group('maintenance')]
update:
  nix flake update

[group('maintenance')]
update-rebuild: update rebuild

[group('info')]
info:
  @echo "User: {{env_var('USER')}}"
  @echo "Hostname: {{`hostname`}}"
  @echo "Config Host: {{config-host}}"
  @echo "Config User: {{config-user}}"
  @echo "Config: ~/.config/nix#{{config-user}}@{{config-host}}"

[group('cleanup')]
clean-home:
  home-manager expire-generations "-7 days"

[group('cleanup')]
clean-store:
  nix-collect-garbage --delete-older-than 7d

[group('cleanup')]
clean-all: clean-home clean-store
  @echo "Cleaned old generations"

[group('info')]
show-generation:
  # `|| true` guards against SIGPIPE: with pipefail, head closing the pipe
  # early would otherwise fail the recipe.
  home-manager generations | head -n 5 || true
