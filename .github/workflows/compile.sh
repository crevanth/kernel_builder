ROOT_DIR=$(pwd)

function compile() {
    export ARCH=arm64
    export SUBARCH=arm64
    export PATH="${ROOT_DIR}/gcc64/bin:${ROOT_DIR}/gcc32/bin:${PATH}"

    # Fix dtc yylloc — GCC 10+ host compiler issue
    sed -i 's/YYLTYPE yylloc/extern YYLTYPE yylloc/' \
        scripts/dtc/dtc-lexer.lex.c_shipped
        
    # Fix gcc-wrapper.py Python 3 compatibility
    sed -i 's/print >> sys.stderr, line,/sys.stderr.write(line)/g' \
        scripts/gcc-wrapper.py
        
    make O=out onc_defconfig

    # Verify config after generation
    echo "=== Config check ==="
    grep "CONFIG_ARCH_MSM8953" out/.config
    grep "CONFIG_ARCH_SDM632" out/.config

    # Verify onclite in Makefile
    echo "=== Makefile check ==="
    grep -n "onclite" arch/arm64/boot/dts/qcom/Makefile

    # Verify onclite folder
    echo "=== onclite folder ==="
    ls arch/arm64/boot/dts/qcom/onclite/

    # Build DTBs separately first with verbose
    echo "=== Building DTBs ==="
    make -j$(nproc --all) O=out \
        ARCH=arm64 \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- \
        dtbs V=1 2>&1 | grep -E "onclite|DTC|dtb|error" | head -50

    # Full build
    echo "=== Full build ==="
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
