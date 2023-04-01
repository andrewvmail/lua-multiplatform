const std = @import("std");
pub const LUA_BYTECODE = @embedFile("main.lua.bytecode");

const lua = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
    @cInclude("luamodules.h");
});

pub export fn momo() void {
    // std.io.getStdOut().writeAll(
    //     bundlepath,
    // ) catch unreachable;
    std.io.getStdOut().writeAll(
        "momo()",
    ) catch unreachable;
    std.io.getStdOut().writeAll(
        "Hello World!",
    ) catch unreachable;
    var s = lua.luaL_newstate();

    _ = lua.luaL_openlibs(s);

    lua.luaL_requiref(s, "lcurl", lua.luaopen_lcurl, 1);
    lua.lua_pop(s, 1);
    lua.luaL_requiref(s, "lcurl", lua.luaopen_lcurl_safe, 1);
    lua.lua_pop(s, 1);

    _ = lua.luaL_loadstring(s, "print(_G.lcurl)");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);
    _ = lua.luaL_loadstring(s, "print(_G.lcurl)");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);
    _ = lua.luaL_loadstring(s, "print(_G.lcurl)");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    _ = lua.luaL_loadstring(s, "print('XXXXXXXXX')");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    _ = lua.luaL_loadstring(s, "print('XXXXXXXXX')");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);
    _ = lua.luaL_loadstring(s, "print(package.path)");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    _ = lua.luaL_loadstring(s, "print(package.cpath)");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    _ = lua.luaL_loadstring(s, "print( os.execute'pwd' )");
    _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    // _ = lua.luaL_loadstring(s, "require( 'main.lua' )");
    // _ = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);

    std.io.getStdOut().writeAll(
        "after pcall",
    ) catch unreachable;

    const load_status = lua.luaL_loadbufferx(s, LUA_BYTECODE, LUA_BYTECODE.len, "main.lua", "bt");
    if (load_status != 0) {
        std.log.info("Couldn't load lua bytecode: {s}", .{lua.lua_tolstring(s, -1, null)});
        return;
    }
    const call_status = lua.lua_pcallk(s, 0, lua.LUA_MULTRET, 0, 0, null);
    if (call_status != 0) {
        std.log.info("{s}", .{lua.lua_tolstring(s, -1, null)});
        return;
    }
}

pub export fn myFunction(param: u32) u32 {
    return param * 2 + 10;
}
