#!/usr/bin/env bash
# Composite a GDM login background sized to whatever monitors are currently
# connected. See hosts/common/optional/gdm-appearance.nix for the reasoning.
#
# Inputs (set by the systemd unit): MAGICK, WALLPAPER, OUTPUT_ORDER.
set -euo pipefail

# generate-config is Debian's own script and needs host tooling: setsid and
# setpriv (util-linux), plus dconf and pkill. system-manager gives units a
# Nix-only PATH, so without this it exits 127 on setsid. Everything else this
# script calls is either an absolute store path or present on the host.
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

: "${MAGICK:?MAGICK not set}"
: "${WALLPAPER:?WALLPAPER not set}"
OUTPUT_ORDER="${OUTPUT_ORDER:-}"

STATE_DIR=/var/lib/gdm-appearance
TARGET="$STATE_DIR/background.png"

install -d -m 0755 "$STATE_DIR"

# ── Detect connected outputs ─────────────────────────────────────────────────
# sysfs is readable this early in boot, before any compositor exists. The first
# line of `modes` is the preferred mode, which is what mutter picks by default.
declare -A WIDTH HEIGHT
detected=()

for dir in /sys/class/drm/card*-*/; do
  [ -r "$dir/status" ] || continue
  # Writeback connectors report "unknown"; only take real displays.
  [ "$(cat "$dir/status")" = connected ] || continue

  mode=$(head -1 "$dir/modes" 2>/dev/null || true)
  [ -n "$mode" ] || continue

  width=${mode%%x*}
  height=${mode#*x}
  width=${width//[!0-9]/}
  height=${height//[!0-9]/}
  [ -n "$width" ] && [ -n "$height" ] || continue

  name=$(basename "$dir")
  name=${name#*-} # card1-DP-2 -> DP-2

  WIDTH[$name]=$width
  HEIGHT[$name]=$height
  detected+=("$name")
done

if [ ${#detected[@]} -eq 0 ]; then
  echo "warn: no connected outputs found; leaving the existing background alone"
  exit 0
fi

# ── Order them left to right ─────────────────────────────────────────────────
# Declared connectors first in the given order, then anything else
# alphabetically, so an undeclared or newly plugged screen still gets a region
# rather than being dropped off the canvas.
ordered=()
for name in $OUTPUT_ORDER; do
  if [ -n "${WIDTH[$name]:-}" ]; then
    ordered+=("$name")
  fi
done

while read -r name; do
  known=0
  for seen in ${ordered[@]+"${ordered[@]}"}; do
    if [ "$seen" = "$name" ]; then
      known=1
      break
    fi
  done
  if [ "$known" -eq 0 ]; then
    ordered+=("$name")
  fi
done < <(printf '%s\n' "${detected[@]}" | sort)

stage_width=0
stage_height=0
for name in "${ordered[@]}"; do
  stage_width=$((stage_width + WIDTH[$name]))
  if [ "${HEIGHT[$name]}" -gt "$stage_height" ]; then
    stage_height=${HEIGHT[$name]}
  fi
done

# ── Composite ────────────────────────────────────────────────────────────────
# Each region is scaled to cover its own monitor and centre-cropped, then
# placed at that monitor's offset.
#
# `-gravity NorthWest` before each -geometry is load-bearing: ImageMagick's
# gravity is global rather than scoped to the \( \) group, so the `center` used
# for cropping otherwise makes offsets relative to the canvas centre and
# silently misplaces every region.
args=(-size "${stage_width}x${stage_height}" xc:black)
offset=0
for name in "${ordered[@]}"; do
  width=${WIDTH[$name]}
  height=${HEIGHT[$name]}
  args+=(\( "$WALLPAPER" -resize "${width}x${height}^" -gravity center -extent "${width}x${height}" \)
    -gravity NorthWest -geometry "+${offset}+0" -composite)
  offset=$((offset + width))
done

# Write to a temporary file and rename, so a failure here leaves the previous
# background in place instead of a half-written or missing one.
tmp=$(mktemp "$STATE_DIR/.background.XXXXXX")
trap 'rm -f "$tmp"' EXIT

"$MAGICK" "${args[@]}" -depth 8 "png:$tmp"
chmod 0644 "$tmp"
mv -f "$tmp" "$TARGET"
trap - EXIT

echo "✓ ${stage_width}x${stage_height} background for: ${ordered[*]}"

/usr/share/gdm/generate-config
echo "✓ recompiled /var/lib/gdm3/greeter-dconf-defaults"
