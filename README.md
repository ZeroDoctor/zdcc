# ZD CC

copy below into computer/turtle in minecraft, run the file then run `update` and it should download the other files

```lua

local request = http.get(
    'https://raw.githubusercontent.com/ZeroDoctor/zdcc/main/update.lua'
    {
        ['Cache-Control'] = 'no-cache, no-store',
        ['Pragma'] = 'no-cache'
    }
)

local file = io.open('/update.lua', 'w')
if file ~= nil then
  file:write(request.readAll())
  file:close()
end

request.close()

```

if minecraft doesn't let you copy multiline string then copy below:
    
```lua

local request = http.get( 'https://raw.githubusercontent.com/ZeroDoctor/zdcc/main/update.lua', { ['Cache-Control'] = 'no-cache, no-store', ['Pragma'] = 'no-cache' }) local file = io.open('/update.lua', 'w') if file ~= nil then file:write(request.readAll()) file:close() end request.close()

```
