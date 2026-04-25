ROOT_DIR=$(pwd)

function compile() {
    export ARCH=arm64
    export SUBARCH=arm64
    export PATH="${ROOT_DIR}/gcc64/bin:${ROOT_DIR}/gcc32/bin:${PATH}"

    # Fix dtc yylloc — GCC 10+ issue
    sed -i 's/YYLTYPE yylloc/extern YYLTYPE yylloc/' \
        scripts/dtc/dtc-lexer.lex.c_shipped

    # Fix sign-file OpenSSL 3.0 issue
    sed -i 's/ERR_get_error_line/ERR_get_error/g' \
        scripts/sign-file.c
    sed -i '/ENGINE_load_builtin_engines/d' \
        scripts/sign-file.c
    sed -i '/ENGINE_by_id/d' \
        scripts/sign-file.c
    sed -i '/ENGINE_init/d' \
        scripts/sign-file.c
    sed -i '/ENGINE_ctrl_cmd_string/d' \
        scripts/sign-file.c
    sed -i '/ENGINE_load_private_key/d' \
        scripts/sign-file.c

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
