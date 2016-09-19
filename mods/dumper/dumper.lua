local dumper = {}
local persistence = require("persistence")
local helpers = require("helpers")

local ignore = {['package']=true,['dumper']=true,['_G']=true,['persistence']=true,['helpers']=true,['script_loader']=true,['json']=true,['os']=true,['file']=true,['string']=true,['table']=true,['io']=true,['debug']=true}

function dumper.dump()
    local env = _G
    for k,v in pairs(env['package']['loaded']) do
        local filename = "D:\\dumpstuff\\"..k..'.txt'
        if not ignore[k] then
            persistence.store(filename,v)
        end
--        helpers.log(tostring(k)..' : '..tostring(v))
    end
    for k,v in pairs(_G) do
        if not env['package']['loaded'][k] then
            if type(v) == 'table' then
                 persistence.store("D:\\dumpstuff\\_G\\tables\\"..k..".txt",v)
             elseif type(v) == 'function' then
                persistence.store("D:\\dumpstuff\\_G\\functions\\"..k..".txt",v)
            else
                persistence.store("D:\\dumpstuff\\_G\\"..k..".txt",v)
            end
        end
    end

end

return dumper
