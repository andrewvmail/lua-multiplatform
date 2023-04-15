const std = @import("std");
const builtin = @import("builtin");

pub const LUA_BYTECODE = @embedFile("main.lua.bytecode");

const c = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
    @cInclude("modules.h");
    if (builtin.os.tag == .linux) {
        @cInclude("android/log.h");
    }
});

fn load_main(s: *c.lua_State) void {
    _ = c.luaL_openlibs(s);
    c.luaL_requiref(s, "lcurl", c.luaopen_lcurl, 1);
    c.lua_pop(s, 1);
    c.luaL_requiref(s, "lcurl", c.luaopen_lcurl_safe, 1);
    c.lua_pop(s, 1);
    c.luaL_requiref(s, "lsqlite3", c.luaopen_lsqlite3, 1);
    c.lua_pop(s, 1);

    const load_status = c.luaL_loadbufferx(s, LUA_BYTECODE, LUA_BYTECODE.len, "main.lua", "bt");
    if (load_status != 0) {
        std.log.info("Couldn't load lua bytecode: {s}", .{c.lua_tolstring(s, -1, null)});
        if (builtin.os.tag == .linux) {
            _ = c.__android_log_print(c.ANDROID_LOG_ERROR, "[]", "[ androidPrint ] Couldn't load lua bytecode: %s", c.lua_tolstring(s, -1, null));
        }
        return;
    }
    const call_status = c.lua_pcallk(s, 0, c.LUA_MULTRET, 0, 0, null);
    if (call_status != 0) {
        std.log.info("{s}", .{c.lua_tolstring(s, -1, null)});
        if (builtin.os.tag == .linux) {
            _ = c.__android_log_print(c.ANDROID_LOG_ERROR, "[]", "[ androidPrint ] call_status: %s", c.lua_tolstring(s, -1, null));
        }
        return;
    }
}

pub export fn run_android(s: *c.lua_State) void {
    load_main(s);
}

pub export fn run_ios(s: *c.lua_State, user_data_path: [*c]const u8, app_resource_path: [*c]const u8) void {
    const user_data_path_ptr: [*:0]const u8 = user_data_path;
    const app_resource_path_ptr: [*:0]const u8 = app_resource_path;

    std.log.info("{s}", .{user_data_path_ptr});
    std.log.info("{s}", .{app_resource_path_ptr});

    // set global
    _ = c.lua_pushstring(s, user_data_path);
    _ = c.lua_setglobal(s, "USER_DATA_PATH");
    _ = c.lua_pushstring(s, app_resource_path);
    _ = c.lua_setglobal(s, "APP_RESOURCE_PATH");

    load_main(s);
}
