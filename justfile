# Nix Configuration Justfile

default:
  @just --list

[group('build')]
home:
  home-manager switch --flake ~/.config/nix#{{env_var('USER')}}@{{`hostname`}}

[group('build')]
home-trace:
  home-manager switch --flake ~/.config/nix#{{env_var('USER')}}@{{`hostname`}} --show-trace

# Rebuild system-manager configuration
[group('build')]
system:
  cd ~/.config/nix && sudo env "PATH=$PATH" system-manager switch --flake .#{{`hostname`}}

# Full rebuild (both home and system)
[group('build')]
rebuild: home system

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
  @echo "Config: ~/.config/nix#{{env_var('USER')}}@{{`hostname`}}"

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
