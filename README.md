# lua-multiplatform

An attempt to use Zig toolchain to build a staticaly link library to run Lua code in iOS and Android.

##### prereq
```
brew install zig
```

##### static libs

```
rm -rf lua_modules/curl/lcurl.a 

make -C lua-5.4.4/ generic CC="zig cc"
file lua-5.4.4/src/liblua.a


make lcurl.a -C lua_modules/curl/ generic CC="zig cc -L/opt/homebrew/opt/curl/lib -I/opt/homebrew/opt/curl/include"
file lua_modules/curl/lcurl.a

make lcurl.a -C lua_modules/curl/ generic CC="xcrun -sdk iphoneos clang -arch armv7 --search-prefix "$(brew --prefix curl)""
```

##### scratch
```bash


make -C lua-5.4.4/ generic CC="zig cc"

ls start.zig | entr -r sh -c "zig build-lib start.zig -femit-h -fcompiler-rt -freference-trace -Ilua-5.4.4/src -Ilua_modules/curl/src"
# build lcurl.a for ios

export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"

# ios
zig build-lib main.zig -femit-h -freference-trace -fcompiler-rt -target aarch64-ios
# mac
zig build-lib main.zig -femit-h -fcompiler-rt -Ilua-5.4.4/src -Ilua_modules/curl/src


zig build -target aarch64-ios

zig build-lib start.zig -femit-h -freference-trace -fcompiler-rt -target aarch64-ios
zig build-lib start.zig -femit-h -freference-trace -fcompiler-rt -Ilua-5.4.4/src  -Ilua_modules/curl/src --sysroot $(xcrun --sdk iphoneos --show-sdk-path) -Dtarget=aarch64-ios

# build start for ios
zig build-lib start.zig -femit-h -I$(xcrun --sdk iphoneos --show-sdk-path)/usr/include -Ilua-5.4.4/src -Ilua_modules -target aarch64-ios


# build start for android
zig build-lib start.zig -femit-h  -Ilua-5.4.4/src -Ilua_modules --sysroot /Users/momo/Library/Android/sdk/ndk/25.2.9519653//toolchains/llvm/prebuilt/darwin-x86_64/sysroot -I/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include -target aarch64-linux-android -I/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/aarch64-linux-android
```


- In Xcode. Build Settings > Search Paths > Library Search Paths, add this readme dir path and make it recursive 
- In Xcode. Link libs in Build Phases > Link Binaries With Libraries


Issues:
- https://github.com/ziglang/zig/issues/5596
- https://github.com/ziglang/zig/issues/7094#issuecomment-737590796 [cannot link luacurl with zig cc]

References:
- https://github.com/android/ndk-samples/tree/master/hello-libs/app/src/main/cpp [linking with android]