ROOT_DIR=$(pwd)

function compile() {
    export ARCH=arm64
    export SUBARCH=arm64
    export PATH="${ROOT_DIR}/gcc64/bin:${ROOT_DIR}/gcc32/bin:${PATH}"
    export CROSS_COMPILE=aarch64-linux-android-
    export CROSS_COMPILE_ARM32=arm-linux-androideabi-

    # Fix dtc yylloc issue
    sed -i 's/YYLTYPE yylloc/extern YYLTYPE yylloc/' \
        scripts/dtc/dtc-lexer.lex.c_shipped

    make O=out onc_defconfig

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
