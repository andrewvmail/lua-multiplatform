const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const lua = b.addStaticLibrary("lua", null);
    {
        const cflags = [_][]const u8{};
        const liblua_srcs = [_][]const u8{
            "lua-5.4.4/src/lauxlib.c",
            "lua-5.4.4/src/liolib.c",
            "lua-5.4.4/src/lopcodes.c",
            "lua-5.4.4/src/lstate.c",
            "lua-5.4.4/src/lobject.c",
            "lua-5.4.4/src/lmathlib.c",
            "lua-5.4.4/src/loadlib.c",
            "lua-5.4.4/src/lvm.c",
            "lua-5.4.4/src/lfunc.c",
            "lua-5.4.4/src/lstrlib.c",
            "lua-5.4.4/src/lua.c",
            "lua-5.4.4/src/linit.c",
            "lua-5.4.4/src/lstring.c",
            "lua-5.4.4/src/lundump.c",
            "lua-5.4.4/src/lctype.c",
            "lua-5.4.4/src/luac.c",
            "lua-5.4.4/src/ltable.c",
            "lua-5.4.4/src/ldump.c",
            "lua-5.4.4/src/loslib.c",
            "lua-5.4.4/src/lgc.c",
            "lua-5.4.4/src/lzio.c",
            "lua-5.4.4/src/ldblib.c",
            "lua-5.4.4/src/lutf8lib.c",
            "lua-5.4.4/src/lmem.c",
            "lua-5.4.4/src/lcorolib.c",
            "lua-5.4.4/src/lcode.c",
            "lua-5.4.4/src/ltablib.c",
            "lua-5.4.4/src/lapi.c",
            "lua-5.4.4/src/lbaselib.c",
            "lua-5.4.4/src/ldebug.c",
            "lua-5.4.4/src/lparser.c",
            "lua-5.4.4/src/llex.c",
            "lua-5.4.4/src/ltm.c",
            "lua-5.4.4/src/ldo.c",
        };

        lua.setTarget(target);
        lua.setBuildMode(mode);

        lua.linkFramework("Foundation");
        lua.linkFramework("UIKit");
        lua.addSystemIncludePath("/usr/include");
        lua.addLibraryPath("/usr/lib");
        lua.addFrameworkPath("/System/Library/Frameworks");

        lua.linkLibC();
        lua.addIncludePath("lua-5.4.4/src/");
        inline for (liblua_srcs) |src| {
            lua.addCSourceFile(src, &cflags);
        }

        const lua_step = b.step("liblua", "build liblua");
        lua_step.dependOn(&lua.step);
    }

    const luacurl = b.addStaticLibrary("luacurl", null);
    {
        const cflags = [_][]const u8{};
        const libluacurl_srcs = [_][]const u8{
            "lua_modules/curl/src/lcurlapi.c",
            "lua_modules/curl/src/lcurl.c",
            "lua_modules/curl/src/lcutils.c",
            "lua_modules/curl/src/lcerror.c",
            "lua_modules/curl/src/lcmime.c",
            "lua_modules/curl/src/lchttppost.c",
            "lua_modules/curl/src/lcmulti.c",
            "lua_modules/curl/src/lceasy.c",
            "lua_modules/curl/src/l52util.c",
            "lua_modules/curl/src/lcshare.c",
        };

        luacurl.setTarget(target);
        luacurl.setBuildMode(mode);
        luacurl.linkLibC();
        luacurl.addIncludePath("lua_modules/curl/src/");
        luacurl.addIncludePath("lua-5.4.4/src/");
        luacurl.addIncludePath("c/libcurl/include/curl");
        luacurl.addIncludePath("c/libcurl/src");
        luacurl.addIncludePath("c/libcurl/include");
        luacurl.addIncludePath("c/libcurl/lib");
        luacurl.linkFramework("Foundation");
        luacurl.linkFramework("UIKit");
        luacurl.addSystemIncludePath("/usr/include");
        luacurl.addLibraryPath("/usr/lib");
        luacurl.addFrameworkPath("/System/Library/Frameworks");

        // luacurl.defineCMacro("BUILDING_LIBCURL", null);
        // luacurl.defineCMacro("HAVE_BOOL_T", "1");
        // luacurl.defineCMacro("HAVE_STDBOOL_H", "1");
        // luacurl.defineCMacro("_FILE_OFFSET_BITS", "64");

        inline for (libluacurl_srcs) |src| {
            luacurl.addCSourceFile(src, &cflags);
        }

        const luacurl_step = b.step("libluacurl", "build libluacurl");
        luacurl_step.dependOn(&luacurl.step);
    }

    // // lib for zig
    // const lib = b.addStaticLibrary("gc", "src/gc.zig");
    // {
    //     lib.setBuildMode(mode);

    //     var main_tests = b.addTest("src/gc.zig");
    //     main_tests.setBuildMode(mode);
    //     main_tests.linkLibC();
    //     main_tests.addIncludeDir("vendor/bdwgc/include");
    //     main_tests.linkLibrary(gc);

    //     const test_step = b.step("test", "Run library tests");
    //     test_step.dependOn(&main_tests.step);

    //     b.default_step.dependOn(&lib.step);
    //     b.installArtifact(lib);
    // }

    const exe = b.addExecutable("stub-only", "main.zig");
    {
        exe.setTarget(target);
        exe.linkLibC();
        exe.addIncludePath("lua-5.4.4/src");
        exe.linkLibrary(lua);
        exe.addIncludePath("lua_modules/curl/src");
        exe.addIncludePath("c/libcurl/lib/");
        exe.linkLibrary(luacurl);

        exe.linkFramework("Foundation");
        exe.linkFramework("UIKit");
        exe.addSystemIncludePath("/usr/include");
        exe.addLibraryPath("/usr/lib");
        exe.addFrameworkPath("/System/Library/Frameworks");

        exe.install();

        const install_cmd = b.addInstallArtifact(exe);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run_example", "run example");
        run_step.dependOn(&run_cmd.step);
    }
}
