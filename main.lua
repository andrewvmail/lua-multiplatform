print("[ main.lua ] start")
print("[ main.lua ] user_data: " .. _G.USER_DATA_PATH)
print("[ main.lua ] app_resource: " .. _G.APP_RESOURCE_PATH)

local curl = require('lcurl')
print("[ main.lua ] after require curl")

local version_info = curl.version_info()
print("[ curl ] version: " .. version_info.version)
print("[ curl ] host: " .. version_info.host)
print("[ curl ] ssl: " .. version_info.ssl_version)
print("[ curl ] libz: " .. version_info.libz_version)
local protocols = {}
for k, v in pairs(version_info.protocols) do
  if v then table.insert(protocols, k) end
end
table.sort(protocols)
print("[ curl ] protocols: " .. table.concat(protocols, ', '))

local features = {}
for k, v in pairs(version_info.features) do
  if v then table.insert(features, k) end
end
table.sort(features)
print("[ curl ] features: " .. table.concat(features, ', '))

local response = {}
curl.easy{
  url = 'https://httpbin.org/get',
  writefunction = function(s) table.insert(response, s) end,
  [curl.OPT_CAINFO] = _G.APP_RESOURCE_PATH .. '/cacert.pem'
}:perform():close()
print('[ curl ] response body: ' .. table.concat(response))

local fpath = _G.USER_DATA_PATH .. '/test.txt'
local output_file = assert(io.open(fpath, 'w'))
output_file:write('Hello World')
output_file:close()
print(fpath .. ' written')

local sqlite3 = require('lsqlite3')
print("[ main.lua ] after require sqlite3")

local db_path = _G.USER_DATA_PATH .. '/test.db'
print('[ main.lua ] db_path: ' .. db_path)
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
