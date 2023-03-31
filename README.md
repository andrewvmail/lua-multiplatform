# lua-multiplatform

An attempt to use Zig toolchain to build a staticaly link library to run Lua code in iOS and Android.

##### prereq
```
brew install zig
```

##### liblua

```
make -C lua-5.4.4/ generic CC="zig cc"
find lua-5.4.4/src/liblua.a
```

##### scratch
```bash


make -C lua-5.4.4/ generic CC="zig cc"

./lua-5.3.4/src/luac main.lua && \zig build-lib momo.zig  -fcompiler-rt -femit-h -freference-trace -Dtarget=aarch64-ios-simulator -freference-trace -Llua-5.3.4/src -Ilua-5.3.4/src -static --name momo -llua-5.3.4/src/ -fcompiler-rt


```