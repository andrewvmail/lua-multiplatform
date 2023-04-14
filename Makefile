# tested on mac
NDK_ROOT?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653
ANDROID_TOOLCHAIN?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64
ANDROID_SYSROOT?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
ANDROID_INCLUDE?=/Users/momo/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include
ANDROID_TARGET_AARCH64=aarch64-linux-android
ANDROID_TARGET_ARM=armv7a-linux-androideabi
ANDROID_API?=28


ANDROID_CC_AARCH64=${TOOLCHAIN}/bin/${ANDROID_TARGET_AARCH64}${ANDROID_API}-clang
ANDROID_CC_ARM=${TOOLCHAIN}/bin/${ANDROID_TARGET_ARM}${ANDROID_API}-clang
ANDROID_AR="${TOOLCHAIN}/bin/llvm-ar rcs"
ANDROID_RANLIB=${TOOLCHAIN}/bin/llvm-ranlib
ANDROID_CURL_INCLUDE=$(shell pwd)/modules/libcurl-android/jni/curl/include
ANDROID_OPENSSL_INCLUDE=$(shell pwd)/modules/libcurl-android/jni/openssl/include



IOS_SDK_PATH=$(shell xcrun --sdk iphoneos --show-sdk-path)
IOS_SIM_SDK_PATH=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

IOS_INC=$(IOS_SDK_PATH)/usr/include
IOS_SIM_INC=$(IOS_SIM_SDK_PATH)/usr/include

IOS_CC=xcrun --sdk iphoneos clang -isysroot $(IOS_SDK_PATH) -I$(IOS_INC)
IOS_SIM_CC=xcrun --sdk iphonesimulator clang -isysroot $(IOS_SIM_SDK_PATH) -I$(IOS_SIM_INC)

IOS_CURL_INC=$(shell pwd)/modules/Build-OpenSSL-cURL/curl/include
IOS_SSL_INC="/opt/homebrew/opt/openssl@3/include"


SQLCIPHER_CFLAGS=-O2 -Wall -Wextra -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLITE_SOUNDEX -DSQLITE_THREADSAFE -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_STAT3 -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS4_UNICODE61 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS5 -DHAVE_USLEEP=1 -DSQLITE_MAX_VARIABLE_NUMBER=99999
SQLCIPHER_CFLAGS_IOS_ONLY=-DSQLCIPHER_CRYPTO_CC


LUA_INC=$(shell pwd)/modules/lua
MODULES_INC=$(shell pwd)/modules
TEST=xcrun 

.PHONY: lua-ios lua-android lcurl-ios lcurl-android sqlite-ios sqlite-android sqlcipher-ios lsqlite3-ios lsqlite3-android sqlcipher-android libstart-ios libstart-android deps curl-cacert build-dir info
 
lua-ios: build-dir
	@gsed -i 's#^  stat = system(cmd);#//stat = system(cmd);#g' modules/lua/loslib.c
	@gsed -i 's#-march=native##g' modules/lua/makefile
	@cd modules/lua && make clean && make liblua.a CC="$(IOS_CC)"
	@cp -r modules/lua/liblua.a build/aarch64-ios-simulator
	@cd modules/lua && make clean && make liblua.a CC="$(IOS_SIM_CC)"
	@cp -r modules/lua/liblua.a build/aarch64-ios
	@cd modules/lua && git restore loslib.c && git restore makefile

lua-android: build-dir
	@cp -r modules/lua.android.makefile modules/lua/makefile
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET_AARCH64) CC=$(ANDROID_CC_AARCH64) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a
	@cp -r modules/lua/liblua.a build/arm64-v8a
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET_ARM) CC=$(ANDROID_CC_ARM) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a
	@cp -r modules/lua/liblua.a build/armeabi-v7a
	@cd modules/lua && git restore makefile

lcurl-ios: build-dir
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="$(IOS_CC)" CFLAGS="-I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="$(IOS_SIM_CC)" CFLAGS="-I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios-simulator

lcurl-android: build-dir
	@cp -r modules/Lua-cURLv3.android.makefile modules/Lua-cURLv3/Makefile
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC=$(ANDROID_CC_AARCH64) AR=$(ANDROID_AR) TARGET=$(ANDROID_TARGET_AARCH64) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/arm64-v8a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC=$(ANDROID_CC_ARM) AR=$(ANDROID_AR) TARGET=$(ANDROID_TARGET_ARM) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/armeabi-v7a
	@cd modules/Lua-cURLv3 && git restore Makefile

sqlite-ios: build-dir
	@cd modules/sqlite && $(IOS_CC) -O2 -Wall -Wextra -c sqlite3.c -o libsqlite3.a
	@cp -r modules/sqlite/libsqlite3.a build/aarch64-ios
	@cd modules/sqlite && $(IOS_SIM_CC) -O2 -Wall -Wextra -c sqlite3.c -o libsqlite3.a 
	@cp -r modules/sqlite/libsqlite3.a build/aarch64-ios-simulator

sqlite-android: build-dir
	@cd modules/sqlite && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -target $(ANDROID_TARGET_AARCH64) -g -O2 -DSQLITE_OS_UNIX=1 -DHAVE_READLINE=0 -fPIC -c sqlite3.c -o libsqlite3.a 
	@cp -r modules/sqlite/libsqlite3.a build/arm64-v8a
	@cd modules/sqlite && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -target $(ANDROID_TARGET_ARM) -g -O2 -DSQLITE_OS_UNIX=1 -DHAVE_READLINE=0 -fPIC -c sqlite3.c -o libsqlite3.a 
	@cp -r modules/sqlite/libsqlite3.a build/armeabi-v7a

sqlcipher-ios: build-dir
	@cd modules/sqlcipher && $(IOS_CC) $(SQLCIPHER_CFLAGS) $(SQLCIPHER_CFLAGS_IOS_ONLY) -I$(IOS_SSL_INC) -c sqlite3.c -o sqlcipher.a
	@cp -r modules/sqlcipher/libsqlcipher.a build/aarch64-ios
	@cd modules/sqlcipher && $(IOS_SIM_CC) $(SQLCIPHER_CFLAGS) $(SQLCIPHER_CFLAGS_IOS_ONLY) -I$(IOS_SSL_INC) -c sqlite3.c -o sqlcipher.a
	@cp -r modules/sqlcipher/libsqlcipher.a build/aarch64-ios-simulator

lsqlite3-ios: build-dir
	@cd modules/lsqlite3_fsl09y && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lsqlite3.a lsqlite3.c
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/aarch64-ios
	@cd modules/lsqlite3_fsl09y && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lsqlite3.a lsqlite3.c
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/aarch64-ios-simulator

lsqlite3-android: build-dir
	@cd modules/lsqlite3_fsl09y && $(ANDROID_CC_AARCH64) -g -O2 -DSQLITE_OS_UNIX=1 -DHAVE_READLINE=0 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c lsqlite3.c -o lsqlite3.a 
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/arm64-v8a
	@cd modules/lsqlite3_fsl09y && $(ANDROID_CC_AARCH64) -g -O2 -DSQLITE_OS_UNIX=1 -DHAVE_READLINE=0 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c lsqlite3.c -o lsqlite3.a 
	@cp -r modules/lsqlite3_fsl09y/lsqlite3.a build/armeabi-v7a

sqlcipher-android: build-dir
	@cd modules/sqlcipher && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 $(SQLCIPHER_CFLAGS) -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -I$(ANDROID_OPENSSL_INCLUDE) -c sqlite3.c -o sqlcipher.a 
	@cp -r modules/sqlcipher/sqlcipher.a build/arm64-v8a
	@cd modules/sqlcipher && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 $(SQLCIPHER_CFLAGS) -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -I$(ANDROID_OPENSSL_INCLUDE) -c sqlite3.c -o sqlcipher.a 
	@cp -r modules/sqlcipher/sqlcipher.a build/armeabi-v7a

libstart-ios: build-dir
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios
	@cp -r libstart.a build/aarch64-ios
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios-simulator
	@cp -r libstart.a build/aarch64-ios-simulator

libstart-android: build-dir
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/aarch64-linux-android -target aarch64-linux-android 
	@cp -r libstart.a build/arm64-v8a
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/arm-linux-androideabi -target arm-linux-android
	@cp -r libstart.a build/armeabi-v7a

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
	@echo ANDROID_CC_AARCH64: $(ANDROID_CC_AARCH64)
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
