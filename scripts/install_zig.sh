#!/usr/bin/env bash
set -euo pipefail
ZIG_VERSION=${ZIG_VERSION:-0.12.1}
ZIG_DIR="zig-linux-x86_64-$ZIG_VERSION"
if [ ! -x "$ZIG_DIR/zig" ]; then
    url="https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz"
    echo "Downloading Zig $ZIG_VERSION from $url" >&2
    curl -L "$url" -o zig.tar.xz
    tar xf zig.tar.xz
    rm zig.tar.xz
fi
ln -sf "$ZIG_DIR/zig" zig
./zig version
