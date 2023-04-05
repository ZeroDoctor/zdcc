# ZD CC

copy below into computer/turtle in minecraft, run the file and it should download the other files

```lua

local request = http.get('https://raw.githubusercontent.com/ZeroDoctor/zdcc/main/download.lua')

local file = io.open('/download.lua', 'w')
if file ~= nil then
  file:write(request.readAll())
  file:close()
end

request.close()

```
