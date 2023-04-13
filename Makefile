NDK_ROOT?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653
ANDROID_TOOLCHAIN?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64
ANDROID_SYSROOT?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
ANDROID_INCLUDE?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include
ANDROID_TARGET?=aarch64-linux-android
ARM_ANDROID_TARGET=arm-linux-androideabi
ANDROID_API?=28


ANDROID_CC=${TOOLCHAIN}/bin/${ANDROID_TARGET}${ANDROID_API}-clang
ANDROID_AR="${TOOLCHAIN}/bin/llvm-ar rcs"
ANDROID_RANLIB=${TOOLCHAIN}/bin/llvm-ranlib
ANDROID_CURL_INCLUDE=$(shell pwd)/modules/libcurl-android/jni/curl/include

IOS_SDK_PATH=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOS_SDK_SIM_PATH=$(shell xcrun --sdk iphonesimulator --show-sdk-path)
IOS_INC=$(IOS_SDK_PATH)/usr/include
IOS_CURL_INC=$(shell pwd)/modules/Build-OpenSSL-cURL/curl/include


LUA_INC=$(shell pwd)/modules/lua
MODULES_INC=$(shell pwd)/modules


lua-macos: build-dir
	@echo make lua-macos
	@cd modules/lua && make clean && make liblua.a CC="zig cc -target aarch64-macos"
	@cp -r modules/lua/liblua.a build/aarch64-macos

lua-ios: build-dir
	@echo make lua-ios
	@echo system does not exist in ios
	@gsed -i 's#^  stat = system(cmd);#//stat = system(cmd);#g' modules/lua/loslib.c
	@cd modules/lua && make clean && make liblua.a CC="zig cc -isysroot $(IOS_SDK_PATH) -I$(IOS_SDK_PATH)/usr/include -target aarch64-ios-simulator"
	@cp -r modules/lua/liblua.a build/aarch64-ios-simulator
	@cd modules/lua && make clean && make liblua.a CC="zig cc -isysroot $(IOS_SDK_PATH) -I$(IOS_SDK_PATH)/usr/include -target aarch64-ios"
	@cp -r modules/lua/liblua.a build/aarch64-ios
	@cd modules/lua && git restore loslib.c

lua-android: build-dir
	@echo make lua-android
	@cp -r modules/lua.android.makefile modules/lua/makefile
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET) CC=$(ANDROID_CC) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a -I$(ANDROID_CURL_INCLUDE)
	@cp -r modules/lua/liblua.a build/arm64-v8a
	@cd modules/lua && make clean && TARGET=$(ARM_ANDROID_TARGET) CC=$(ANDROID_CC) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a -I$(ANDROID_CURL_INCLUDE)
	@cp -r modules/lua/liblua.a build/armeabi-v7a
	@cd modules/lua && git restore makefile

lcurl-android: build-dir
	@echo make lcurl.a
	@cp -r modules/Lua-cURLv3.android.makefile modules/Lua-cURLv3/Makefile
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a AR=$(ANDROID_AR) CC=$(ANDROID_CC) TARGET=$(ANDROID_TARGET) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/arm64-v8a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a AR=$(ANDROID_AR) CC=$(ANDROID_CC) TARGET=$(ARM_ANDROID_TARGET) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/armeabi-v7a
	@cd modules/Lua-cURLv3 && git restore Makefile

libstart-android: build-dir
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/aarch64-linux-android -target aarch64-linux-android 
	@cp -r libstart.a build/arm64-v8a
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/arm-linux-androideabi -target arm-linux-android
	@cp -r libstart.a build/armeabi-v7a


libstart-ios: build-dir
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios
	@cp -r libstart.a build/aarch64-ios
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios-simulator
	@cp -r libstart.a build/aarch64-ios-simulator

lcurl-ios: build-dir
	@echo make lcurl.a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="xcrun --sdk iphoneos clang -isysroot $$(xcrun --sdk iphoneos --show-sdk-path) -I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="xcrun --sdk iphonesimulator clang -isysroot $$(xcrun --sdk iphonesimulator --show-sdk-path) -I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios-simulator

libsqlite3-ios: build-dir
	@cd modules/sqlite && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -O2 -Wall -Wextra -c -o libsqlite3.a sqlite3.c
	@cp -r modules/sqlite/libsqlite3.a build/aarch64-ios
	@cd modules/sqlite && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -O2 -Wall -Wextra -c -o libsqlite3.a sqlite3.c
	@cp -r modules/sqlite/libsqlite3.a build/aarch64-ios-simulator

libsqlcipher-ios: build-dir
	@cd modules/sqlcipher && xcrun --sdk iphoneos clang -isysroot $(IOS_SDK_PATH) -I$(IOS_INC) -O2 -Wall -Wextra -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLITE_SOUNDEX -DSQLITE_THREADSAFE -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_STAT3 -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS4_UNICODE61 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS5 -DSQLCIPHER_CRYPTO_CC -DHAVE_USLEEP=1 -DSQLITE_MAX_VARIABLE_NUMBER=99999 -I$(MODULES_INC) -I/opt/homebrew/opt/openssl@3/include -c -o libsqlcipher.a sqlite3.c
	@cp -r modules/sqlcipher/libsqlcipher.a build/aarch64-ios
	@cd modules/sqlcipher && xcrun --sdk iphonesimulator clang -isysroot $(IOS_SDK_SIM_PATH) -I$(IOS_INC) -O2 -Wall -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLITE_SOUNDEX -DSQLITE_THREADSAFE -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_STAT3 -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS4_UNICODE61 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS5 -DSQLCIPHER_CRYPTO_CC -DHAVE_USLEEP=1 -DSQLITE_MAX_VARIABLE_NUMBER=99999 -I$(MODULES_INC) -I/opt/homebrew/opt/openssl@3/include -Wextra -c -o libsqlcipher.a sqlite3.c
	@cp -r modules/sqlcipher/libsqlcipher.a build/aarch64-ios-simulator

lsqlite3-ios: build-dir
	@cd modules/lsqlite3_fsl09y && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lsqlite3.a lsqlite3.c
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/aarch64-ios
	@cd modules/lsqlite3_fsl09y && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lsqlite3.a lsqlite3.c
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/aarch64-ios-simulator

deps:
	@submodule update --init --recursive
	@cd modules/Build-OpenSSL-cURL && ./build.sh
	@cd modules/libcurl-android && ./build_for_android.sh
	@cd modules/sqlite && ./configure && make sqlite3.c
	@cd modules/sqlcipher && LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib" CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include" ./configure  && make sqlite3.c -f Makefile.linux-gcc

curl-cacert:
	@wget https://curl.se/ca/cacert.pem -O modules/cacert.pem

build-dir:
	@mkdir -p build/aarch64-macos 
	@mkdir -p build/aarch64-ios
	@mkdir -p build/aarch64-ios-simulator
	@mkdir -p build/arm64-v8a
	@mkdir -p build/armeabi-v7a	

info:
	@echo "==="
	@echo ANDROID_TOOLCHAIN: $(ANDROID_TOOLCHAIN)
	@echo ANDROID_TARGET: $(ANDROID_TARGET)
	@echo ANDROID_API: $(ANDROID_API)
	@echo ANDROID_CC: $(ANDROID_CC)
	@echo ANDROID_AR: $(ANDROID_AR)
	@echo ANDROID_RANLIB: $(ANDROID_RANLIB)
	@echo ANDROID_CURL_INCLUDE: $(ANDROID_CURL_INCLUDE)
	@echo "==="
	@echo IOS_SDK_PATH: $(IOS_SDK_PATH)
	@echo "==="
	@echo MAKE_FILE_LIST: $(LUA_INC)

clean:
	rm -rf build zig-cache zig-out
	@cd modules/lua && make clean 
