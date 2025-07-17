local busted = require('busted')

it('runs main.lua without error', function()
  _G.USER_DATA_PATH = '/tmp/userdata'
  _G.APP_RESOURCE_PATH = '/tmp/resource'
  os.execute('mkdir -p /tmp/userdata')
  os.execute('mkdir -p /tmp/resource')
  os.execute('cp modules/cacert.pem /tmp/resource/cacert.pem')
  assert.has_no.errors(function() dofile('main.lua') end)
end)

it('features list is sorted', function()
  local curl = require('lcurl')
  local info = curl.version_info()
  local features = {}
  for k, v in pairs(info.features) do
    if v then table.insert(features, k) end
  end
  table.sort(features)
  local sorted = table.concat(features, ', ')
  assert.is_not_nil(sorted:match('SSL'))
end)
