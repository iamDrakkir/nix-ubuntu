# Nix Configuration Justfile

config-user := `id -un | sed 's/@.*//'`

# Map real hostnames to flake config names
# Add new entries as: *'<real-hostname>') echo '<config-name>' ;;
config-host := `case "$(hostname)" in *'CTEKLIN'*) echo 'work' ;; *) hostname ;; esac`

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

# Full rebuild (both home and system)
[group('build')]
rebuild: system home

[group('maintenance')]
check:
  nix flake check

[group('maintenance')]
fmt:
  nix fmt -- **/*.nix

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
  home-manager generations | head -n 5
