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
	@cp -r modules/lua.makefile modules/lua/makefile
	@cd modules/lua && make clean && TARGET=$(ANDROID_TARGET) CC=$(ANDROID_CC) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a -I$(ANDROID_CURL_INCLUDE)
	@cp -r modules/lua/liblua.a build/arm64-v8a
	@cd modules/lua && make clean && TARGET=$(ARM_ANDROID_TARGET) CC=$(ANDROID_CC) AR=$(ANDROID_AR) RANLIB=$(ANDROID_RANLIB) make liblua.a -I$(ANDROID_CURL_INCLUDE)
	@cp -r modules/lua/liblua.a build/armeabi-v7a
	@cd modules/lua && git restore makefile

lcurl-android: build-dir
	@echo make lcurl.a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a AR=$(ANDROID_AR) CC=$(ANDROID_CC) TARGET=$(ANDROID_TARGET) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/arm64-v8a
	@cd modules/Lua-cURLv3 && make clean && make lcurl.a AR=$(ANDROID_AR) CC=$(ANDROID_CC) TARGET=$(ARM_ANDROID_TARGET) RANLIB=$(ANDROID_RANLIB)
	@cp -r modules/Lua-cURLv3/lcurl.a build/armeabi-v7a

libstart-android: build-dir
	@rm libstart.a && zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/aarch64-linux-android -target aarch64-linux-android 
	@cp -r libstart.a build/arm64-v8a
	@rm libstart.a && zig build-lib start.zig -I$(MODULES_INC) -I$(LUA_INC) --sysroot $(ANDROID_SYSROOT) -I$(ANDROID_INCLUDE) -I$(ANDROID_INCLUDE)/arm-linux-androideabi -target arm-linux-android
	@cp -r libstart.a build/armeabi-v7a

deps:
	@submodule update --init --recursive
	@cd modules/Build-OpenSSL-cURL && ./build.sh
	@cd modules/libcurl-android && ./build_for_android.sh

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
