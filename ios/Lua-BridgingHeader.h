#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


int start(char *b, char *r);
int run_ios(lua_State *s, char *b, char *r);
int do_string(lua_State *s, char *b);
int lua_do_string(char *b);
int lua_do_file(char *b);
