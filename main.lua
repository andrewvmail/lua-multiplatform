print "[ main.lua ] start"


local curl = require "lcurl"

print("[ main.lua ] after require curl")

curl.easy{
    url = 'http://httpbin.org/get',
    httpheader = {
      "X-Test-Header1: Header-Data1",
      "X-Test-Header2: Header-Data2",
    },
    writefunction = print -- use io.stderr:write()
  }
  :perform()
:close()


print "[ main.lua ] end"
