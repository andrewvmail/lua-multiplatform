# lua-multiplatform

An attempt to use Zig toolchain to build a staticaly link library to run Lua code in iOS and Android.

##### prereq
```
brew install zig
```

##### static libs

```

make -C lua-5.4.4/ generic CC="zig cc"
file lua-5.4.4/src/liblua.a

make lcurl.a -C lua_modules/curl/ generic CC="gcc"
file lua_modules/curl/lcurl.a
```

##### scratch
```bash


make -C lua-5.4.4/ generic CC="zig cc"

ls main.zig | entr -r sh -c "./lua-5.4.4/src/luac \
        -o main.lua.bytecode main.lua && \
        zig build-lib main.zig  \
        -fcompiler-rt \
        -femit-h \
        -freference-trace \
        -Dtarget=aarch64-ios-simulator \
        -freference-trace \
        -Llua-5.4.4/src \
        -Ilua-5.4.4/src \
        -llua-5.4.4/src \
        -Llua_modules/curl/src \
        -Ilua_modules/curl/src \
        -llua_modules/curl/src  \
        -Ilua_modules \
        -fcompiler-rt"

```


- In Xcode. Build Settings > Search Paths > Library Search Paths, add this readme dir path and make it recursive 
- In Xcode. Link libs in Build Phases > Link Binaries With Libraries


Issues:
- https://github.com/ziglang/zig/issues/5596
- https://github.com/ziglang/zig/issues/7094#issuecomment-737590796 [cannot link luacurl with zig cc]