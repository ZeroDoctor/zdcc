# ZD CC

copy below into computer/turtle in minecraft, run the file and it should download the other files

```lua

local request = http.get('https://raw.githubusercontent.com/ZeroDoctor/zdcc/main/update.lua')

local file = io.open('/update.lua', 'w')
if file ~= nil then
  file:write(request.readAll())
  file:close()
end

request.close()

```
