#ifndef LUAMODULES
#define LUAMODULES

#include "lua.h"
#include "lauxlib.h"
#include <stdint.h>

extern int luaopen_lcurl(lua_State *L);
extern int luaopen_lcurl_safe(lua_State *L);

#endif