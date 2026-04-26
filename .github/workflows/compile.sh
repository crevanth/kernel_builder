#!/bin/bash
ROOT_DIR=$(pwd)

function compile() {
    export ARCH=arm64
    export SUBARCH=arm64
    export PATH="${ROOT_DIR}/gcc64/bin:${ROOT_DIR}/gcc32/bin:${PATH}"

    # Fix dtc yylloc — GCC 10+ host compiler issue
    sed -i 's/YYLTYPE yylloc/extern YYLTYPE yylloc/' \
        scripts/dtc/dtc-lexer.lex.c_shipped

    # Bypass legacy Python 2 gcc-wrapper
    cat << 'EOF' > scripts/gcc-wrapper.py
#!/usr/bin/env python3
import sys
import subprocess
sys.exit(subprocess.call(sys.argv[1:]))
EOF
    chmod +x scripts/gcc-wrapper.py

    make O=out vendor/onclite-perf_defconfig

    echo "=== Config check ==="
    grep "CONFIG_MACH_XIAOMI_ONCLITE" out/.config

    echo "=== Makefile check ==="
    grep -n "onclite" arch/arm64/boot/dts/vendor-legacy/qcom/Makefile

    echo "=== Building ==="
    make -j$(nproc --all) O=out \
        ARCH=arm64 \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- \
        2>&1 | tee build.log

    if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
        echo "✓ Build successful"
        ls -la out/arch/arm64/boot/Image.gz-dtb
    else
        echo "✗ Build failed — last errors:"
        grep -E "error:" build.log | tail -30
    fi
}

compile
