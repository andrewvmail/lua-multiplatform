#include <stdio.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "Lua.h"


lua_State *s;

int start(char *a, char *b) {
	s = luaL_newstate();
	run_ios(s, a, b);
	return 0;
}

int lua_do_string(char *script) {
	int status = luaL_loadstring(s, script);
	if (status != LUA_OK) {
		const char* error_message = lua_tostring(s, -1); // get the error message
		fprintf(stderr, "Error loading script: %s\n", error_message);
		return 1;
	}
	
	lua_call(s, 0, 0);
	return 0;
}

int lua_do_file(char *filename) {
	int status = luaL_dofile(s, filename);
	if (status != LUA_OK) {
		const char* error_message = lua_tostring(s, -1);
		fprintf(stderr, "Error running script: %s\n" ,error_message);
		return 1;
	}
	return 0;
}

