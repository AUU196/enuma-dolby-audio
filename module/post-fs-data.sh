#!/system/bin/sh
# Magisk mounts module files into /vendor with a generic system_file label,
# which the 32-bit audio HAL (hal_audio_default) is not allowed to read.
# The mount point is read-only, but the module's own copies on /data are not:
# relabel the source files, and the mounted view inherits the new context.

MODDIR=${0%/*}
V="$MODDIR/system/vendor"

[ -d "$V" ] || exit 0

for f in $(find "$V" -type f 2>/dev/null); do
  case "$f" in
    */lib/*) chcon u:object_r:vendor_file:s0 "$f" 2>/dev/null ;;
    */etc/*) chcon u:object_r:vendor_configs_file:s0 "$f" 2>/dev/null ;;
    */bin/*) chcon u:object_r:vendor_file:s0 "$f" 2>/dev/null ;;
  esac
done

# libs need exec (map) as well, keep them readable/executable
chmod 644 "$V"/lib/soundfx/*.so 2>/dev/null

log -t DolbyMi5 "vendor source labels fixed"
