



OPKG_DIR="/etc/opkg/"

if ls "$OPKG_DIR" | grep -q "cortexa15hf-neon-vfpv4"; then
    echo "Detected CPU architecture: Cortex-A15hf-neon-vfpv4"
elif ls "$OPKG_DIR" | grep -q "cortexa9hf-neon"; then
    echo "Detected CPU architecture: Cortex-A9hf-neon"
elif ls "$OPKG_DIR" | grep -q "cortexa7hf-vfp"; then
    echo "Detected CPU architecture: Cortex-A7hf-vfp"
elif ls "$OPKG_DIR" | grep -q "armv7ahf-neon"; then
    echo "Detected CPU architecture: ARMv7-Ahf-neon"
else
    echo "Unknown CPU architecture"
fi

