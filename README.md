# lua-multiplatform

An attempt to use Zig toolchain to build a staticaly link library to run Lua code in iOS and Android.

##### prereq
```
brew install zig
```

##### liblua

```
make -C lua-5.4.4/ generic CC="zig cc"
file lua-5.4.4/src/liblua.a
```

##### scratch
```bash


make -C lua-5.4.4/ generic CC="zig cc"

./lua-5.4.4/src/luac \
	-o main.lua.bytecode main.lua && \
	zig build-lib main.zig  \
	-fcompiler-rt \
	-femit-h \
	-freference-trace \
	-Dtarget=aarch64-ios-simulator \
	-freference-trace \
	-Llua-5.4.4/src \
	-Ilua-5.4.4/src \
	-llua-5.4.4/src/ \
	-fcompiler-rt

```


- In Xcode. Build Settings > Search Paths > Library Search Paths, add this readme dir path and make it recursive 
