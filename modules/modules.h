#ifndef MODULES
#define MODULES 

#include "lua.h"
#include "lauxlib.h"
#include <stdint.h>

extern int luaopen_lcurl(lua_State *L);
extern int luaopen_lcurl_safe(lua_State *L);
extern int luaopen_lsqlite3(lua_State *L);
extern int luaopen_cjson(lua_State *L);
extern int luaopen_cjson_safe(lua_State *L);
extern int luaopen_luatweetnacl(lua_State *L);

#endif