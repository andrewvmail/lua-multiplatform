print("[ main.lua ] start")
print("[ main.lua ] user_data: " .. _G.USER_DATA_PATH)
print("[ main.lua ] app_resource: " .. _G.APP_RESOURCE_PATH)

local curl = require('lcurl')
print("[ main.lua ] after require curl")

local vi = curl.version_info()
print("[ curl ] version: " .. vi.version)
print("[ curl ] host: " .. vi.host)
print("[ curl ] ssl: " .. vi.ssl_version)
print("[ curl ] libz: " .. vi.libz_version)
local protocols = {}
for k, v in pairs(vi.protocols) do
  if v then table.insert(protocols, k) end
end
table.sort(protocols)
print("[ curl ] protocols: " .. table.concat(protocols, ', '))

local feat = {}
for k, v in pairs(vi.features) do
  if v then table.insert(feat, k) end
end
print("[ curl ] features: " .. table.concat(feat, ', '))

local response = {}
curl.easy{
  url = 'https://httpbin.org/get',
  writefunction = function(s) table.insert(response, s) end,
  [curl.OPT_CAINFO] = _G.APP_RESOURCE_PATH .. '/cacert.pem'
}:perform():close()
print('[ curl ] response body:', table.concat(response))

local fpath = _G.USER_DATA_PATH .. '/test.txt'
local f = assert(io.open(fpath, 'w'))
f:write('Hello World')
f:close()
print(fpath .. ' written')

local sqlite3 = require('lsqlite3')
print("[ main.lua ] after require sqlite3")

local db_path = _G.USER_DATA_PATH .. '/test.db'
print(db_path)
local db = sqlite3.open(db_path)
db:exec("PRAGMA key = 'test';")
db:exec[[
  CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, content);
  INSERT INTO test (content) VALUES ('Hello World');
  INSERT INTO test (content) VALUES ('Hello Lua');
  INSERT INTO test (content) VALUES ('Hello Sqlite3');
]]
for row in db:nrows('SELECT * FROM test') do
  print(row.id, row.content)
end
db:exec('PRAGMA cipher_version', print)

print('[ main.lua ] end')
