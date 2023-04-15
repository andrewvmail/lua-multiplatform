print "[ main.lua ] start"
print ("[ main.lua ] user_data: " .. _G.USER_DATA_PATH )
print ("[ main.lua ] app_resource: " .. _G.APP_RESOURCE_PATH)

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local curl = require "lcurl"

print("[ main.lua ] after require curl")

-- local c_struct_ca_info = curl.easy_option_by_name("cainfo")

-- dump(c_struct_ca_info)
-- dump(easy)

-- curl.ieasy_options(curl.easy_option_by_name("cainfo"))


print(dump(curl.version_info().version))
print(dump(curl.version_info().host))
print(dump(curl.version_info().features))
print(dump(curl.OPT_CAINFO))
print(dump(curl.OPT_CAPATH))


curl.easy{
    url = 'https://httpbin.org/get',
    httpheader = {
      "X-Test-Header1: Header-Data1",
      "X-Test-Header2: Header-Data2",
    },
    writefunction = print, -- use io.stderr:write()
    [curl.OPT_VERBOSE] = true,
    [curl.OPT_CAINFO] = _G.APP_RESOURCE_PATH .. "/cacert.pem"
  }:perform():close()

print(_G.USER_DATA_PATH .. "/test.txt", "w")
file = io.open(_G.USER_DATA_PATH .. "/test.txt", "w")
file:write("Hello World")
file:close()


local sqlite3 = require("lsqlite3")

-- local db = sqlite3.open_memory()
print(_G.USER_DATA_PATH .. "/test.db")
-- local db = sqlite3.open(_G.RESOURCE_PATH .. "/test.db", sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE)

local db = sqlite3.open(_G.USER_DATA_PATH .. "/test.db")

db:exec("PRAGMA key = 'test';")
db:exec("PRAGMA cipher_plaintext_header_size = 32;")
db:exec("PRAGMA cipher_salt = \"x'01010101010101010101010101010101'\";")

db:exec[[
  CREATE TABLE test (id INTEGER PRIMARY KEY, content);

  INSERT INTO test VALUES (NULL, 'Hello World');
  INSERT INTO test VALUES (NULL, 'Hello Lua');
  INSERT INTO test VALUES (NULL, 'Hello Sqlite3')
]]

for row in db:nrows("SELECT * FROM test") do
  print(row.id, row.content)
end

local res1 = db:exec("PRAGMA cipher_version", print)
print("res1", res1)
-- local res2 = db:exec("PRAGMA table_info(test)", print)



print "[ main.lua ] end -- "
