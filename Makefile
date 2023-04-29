# tested on mac

NDK_VERSION?=25.2.9519653
NDK_ROOT?=/Users/$(USER)/Library/Android/sdk/ndk/$(NDK_VERSION)
ANDROID_TOOLCHAIN?=$(NDK_ROOT)/toolchains/llvm/prebuilt/darwin-x86_64
ANDROID_SYSROOT?=$(ANDROID_TOOLCHAIN)/sysroot
ANDROID_INCLUDE?=$(ANDROID_SYSROOT)/usr/include
ANDROID_TARGET_AARCH64=aarch64-linux-android
ANDROID_TARGET_ARM=armv7a-linux-androideabi
ANDROID_API?=28

ANDROID_CC_AARCH64=${ANDROID_TOOLCHAIN}/bin/${ANDROID_TARGET_AARCH64}${ANDROID_API}-clang
ANDROID_CC_ARM=${ANDROID_TOOLCHAIN}/bin/${ANDROID_TARGET_ARM}${ANDROID_API}-clang
ANDROID_AR=${ANDROID_TOOLCHAIN}/bin/llvm-ar
ANDROID_RANLIB=${ANDROID_TOOLCHAIN}/bin/llvm-ranlib
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

.PHONY: lua-ios lua-android lcurl-ios lcurl-android sqlite-ios sqlite-android sqlcipher-ios lsqlite3-ios lsqlite3-android sqlcipher-android libstart-ios libstart-android deps curl-cacert build-dir info nacl-android nacl-ios


all-ios: lua-ios lcurl-ios sqlite-ios sqlcipher-ios lsqlite3-ios libstart-ios nacl-ios
all-android: lua-android lcurl-android sqlite-android sqlcipher-android lsqlite3-android libstart-android nacl-android cjson-android


lua-ios: build-dir
	@gsed -i 's#^  stat = system(cmd);#//stat = system(cmd);#g' modules/lua/loslib.c
	@gsed -i 's#-march=native##g' modules/lua/makefile
	@cd modules/lua && make clean && make liblua.a CC="$(IOS_CC)"
	@cp -r modules/lua/liblua.a build/aarch64-ios
	@cd modules/lua && make clean && make liblua.a CC="$(IOS_SIM_CC)"
	@cp -r modules/lua/liblua.a build/aarch64-ios-simulator
	@cd modules/lua && git restore loslib.c && git restore makefile

lua-android: build-dir
	@cp -r modules/lua.android.makefile modules/lua/makefile
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET_AARCH64) CC=$(ANDROID_CC_AARCH64) AR="$(ANDROID_AR) rcs" RANLIB=$(ANDROID_RANLIB) make liblua.a
	@cp -r modules/lua/liblua.a build/arm64-v8a
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET_ARM) CC=$(ANDROID_CC_ARM) AR="$(ANDROID_AR) rcs" RANLIB=$(ANDROID_RANLIB) make liblua.a
	@cp -r modules/lua/liblua.a build/armeabi-v7a
	@cd modules/lua && git restore makefile

lcurl-ios: build-dir
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="$(IOS_CC)" CFLAGS="-I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC="$(IOS_SIM_CC)" CFLAGS="-I$(MODULES_INC) -I$(LUA_INC) -I$(IOS_CURL_INC)"
	@cp -r modules/Lua-cURLv3/lcurl.a build/aarch64-ios-simulator

lcurl-android: build-dir
	@cp -r modules/Lua-cURLv3.android.makefile modules/Lua-cURLv3/Makefile
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC=$(ANDROID_CC_AARCH64) AR="$(ANDROID_AR) rcs" TARGET=$(ANDROID_TARGET_AARCH64) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/arm64-v8a && $(ANDROID_RANLIB) build/arm64-v8a/lcurl.a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a CC=$(ANDROID_CC_ARM) AR="$(ANDROID_AR) rcs" TARGET=$(ANDROID_TARGET_ARM) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/armeabi-v7a && $(ANDROID_RANLIB) build/arm64-v8a/lcurl.a
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
	@cp -r modules/sqlcipher/sqlcipher.a build/aarch64-ios
	@cd modules/sqlcipher && $(IOS_SIM_CC) $(SQLCIPHER_CFLAGS) $(SQLCIPHER_CFLAGS_IOS_ONLY) -I$(IOS_SSL_INC) -c sqlite3.c -o sqlcipher.a
	@cp -r modules/sqlcipher/sqlcipher.a build/aarch64-ios-simulator

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

cjson-ios:
	@cd modules/lua-cjson && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o strbuf.a strbuf.c
	@cd modules/lua-cjson && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lua_cjson.a lua_cjson.c
	@cd modules/lua-cjson && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o fpconv.a fpconv.c
	@cd modules/lua-cjson && libtool -static -o lcjson.a strbuf.a lua_cjson.a fpconv.a
	@cp -r modules/lua-cjson/lcjson.a build/aarch64-ios
	@cd modules/lua-cjson && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o strbuf.a strbuf.c
	@cd modules/lua-cjson && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o lua_cjson.a lua_cjson.c
	@cd modules/lua-cjson && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o fpconv.a fpconv.c
	@cd modules/lua-cjson && libtool -static -o lcjson.a strbuf.a lua_cjson.a fpconv.a
	@cp -r modules/lua-cjson/lcjson.a build/aarch64-ios-simulator
	

cjson-android:
	@cd modules/lua-cjson && make clean && rm -rf lcjson.a
	@cd modules/lua-cjson && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c strbuf.c
	@cd modules/lua-cjson && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c lua_cjson.c
	@cd modules/lua-cjson && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c fpconv.c
	@cd modules/lua-cjson && $(ANDROID_AR) rs lcjson.a *.o && $(ANDROID_RANLIB) lcjson.a
	@cp -r modules/lua-cjson/lcjson.a build/arm64-v8a
	@cd modules/lua-cjson && make clean
	@cd modules/lua-cjson && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c strbuf.c
	@cd modules/lua-cjson && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c lua_cjson.c
	@cd modules/lua-cjson && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c fpconv.c
	@cd modules/lua-cjson && $(ANDROID_AR) rs lcjson.a *.o && $(ANDROID_RANLIB) lcjson.a
	@cp -r modules/lua-cjson/lcjson.a build/armeabi-v7a

nacl-ios:
	@cd modules/luatweetnacl && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o randombytes.a randombytes.c
	@cd modules/luatweetnacl && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o tweetnacl.a tweetnacl.c
	@cd modules/luatweetnacl && zig cc -target aarch64-ios --sysroot $(IOS_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o luatweetnacl.a luatweetnacl.c
	@cd modules/luatweetnacl && libtool -static -o lnacl.a randombytes.a tweetnacl.a luatweetnacl.a
	@cp -r modules/luatweetnacl/lnacl.a build/aarch64-ios
	@cd modules/luatweetnacl && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o randombytes.a randombytes.c
	@cd modules/luatweetnacl && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o tweetnacl.a tweetnacl.c
	@cd modules/luatweetnacl && zig cc -target aarch64-ios-simulator --sysroot $(IOS_SIM_SDK_PATH) -I$(LUA_INC) -I$(IOS_INC) -O2 -Wall -Wextra -c -o luatweetnacl.a luatweetnacl.c
	@cd modules/luatweetnacl && libtool -static -o lnacl.a randombytes.a tweetnacl.a luatweetnacl.a
	@cp -r modules/luatweetnacl/lnacl.a build/aarch64-ios-simulator
	
nacl-android:
	@cd modules/luatweetnacl && make clean
	@cd modules/luatweetnacl && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c tweetnacl.c -o tweetnacl.a
	@cd modules/luatweetnacl && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c randombytes.c -o randombytes.a
	@cd modules/luatweetnacl && $(ANDROID_CC_AARCH64) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c luatweetnacl.c -o luatweetnacl.a
	@cd modules/luatweetnacl && $(ANDROID_AR) rs lnacl.a *.a && $(ANDROID_RANLIB) lnacl.a
	@cp -r modules/luatweetnacl/lnacl.a build/arm64-v8a
	@cd modules/luatweetnacl && make clean
	@cd modules/luatweetnacl && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c randombytes.c -o randombytes.a
	@cd modules/luatweetnacl && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c tweetnacl.c -o tweetnacl.a
	@cd modules/luatweetnacl && $(ANDROID_CC_ARM) --sysroot $(ANDROID_SYSROOT) -g -O2 -fPIC -I$(LUA_INC) -I$(ANDROID_INCLUDE) -c luatweetnacl.c -o luatweetnacl.a
	@cd modules/luatweetnacl && $(ANDROID_AR) rs lnacl.a *.a && $(ANDROID_RANLIB) lnacl.a
	@cp -r modules/luatweetnacl/lnacl.a build/armeabi-v7a

libstart-ios: build-dir
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios
	@cp -r libstart.a build/aarch64-ios
	@zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(IOS_SDK_PATH) -I$(IOS_INC) -target aarch64-ios-simulator
	@cp -r libstart.a build/aarch64-ios-simulator

libstart-android: build-dir
	@zig build-lib start.zig -femit-h -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/aarch64-linux-android -target aarch64-linux-android 
	@cp -r libstart.a build/arm64-v8a
# 	@zig build-lib start.zig -femit-h -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/arm-linux-androideabi -target arm-linux-android
# 	@cp -r libstart.a build/armeabi-v7a

deps:
	@submodule update --init --recursive
	@cd modules/Build-OpenSSL-cURL && ./build.sh
	@cd modules/libcurl-android && ./build_for_android.sh
	@cd modules/sqlite && ./configure && make sqlite3.c
	@cd modules/sqlcipher && LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib" CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include" ./configure  && make sqlite3.c -f Makefile.linux-gcc

xcf:
	@cd build/aarch64-ios && libtool -static -o liblm.a lcurl.a liblua.a libstart.a lsqlite3.a sqlcipher.a lcjson.a lnacl.a
	@cd build/aarch64-ios-simulator && libtool -static -o liblm.a lcurl.a liblua.a libstart.a lsqlite3.a sqlcipher.a lcjson.a lnacl.a
	@cd build && mkdir liblm.xcframework && cd liblm.xcframework && mkdir aarch64-ios aarch64-ios-simulator
	@cp modules/Info.plist build/liblm.xcframework
	@cp build/aarch64-ios/liblm.a build/liblm.xcframework/aarch64-ios
	@cp build/aarch64-ios-simulator/liblm.a build/liblm.xcframework/aarch64-ios-simulator
	@cp modules/lua/*.h build/liblm.xcframework/aarch64-ios-simulator/Headers
	@cp modules/lua/*.h build/liblm.xcframework/aarch64-ios/Headers

headers: build-dir
	@cp modules/modules.h build/headers
	@cp -r modules/lua/*.h build/headers/lua

curl-cacert:
	@wget https://curl.se/ca/cacert.pem -O modules/cacert.pem

build-dir:
	@mkdir -p build/aarch64-macos 
	@mkdir -p build/aarch64-ios
	@mkdir -p build/aarch64-ios-simulator
	@mkdir -p build/arm64-v8a
	@mkdir -p build/armeabi-v7a
	@mkdir -p build/headers/lua

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
