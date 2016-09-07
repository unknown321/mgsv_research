--18e34bb1306b261b|00\Assets\tpp\script\lib\script_loader.lua key=0 version=0 compressed=0
local script_loader={}
local key_modifier = PlayerPad.ZOOM_CHANGE --master key, V
local helpers = require('helpers')
require("json")
local keys = {}
local modules = {}


function script_loader.read_config()
    local config_path = helpers.get_game_path()..'lua\\script_loader.json'
    local f = io.open(config_path, "r")
    local content = f:read("*all")
    f:close()
    local config = json.decode(content)
    return config
end

function script_loader.bind_keys()
    local t = script_loader.read_config()
    helpers.log('Binding keys..', true)
    modules = {}
    for k,v in pairs(t["keys"]) do
        --reload modules
        --this check is really important so different functions from the same 
        --module can use upvalues together. Without it there will be some issues
        if modules[v["module"]]==nil then
            package.loaded[v["module"]] = nil
            modules[v["module"]] = nil
            modules[v["module"]] = require(v["module"])
        end
    --get numcode for pressed key and put it into table along with function
    local bindable_key = loadstring("return "..k)()
    keys[bindable_key] = modules[v["module"]][v["function"]]
    helpers.log('keybinder: '..k..'->'..v["module"]..'.'..v["function"])
    end
    helpers.log('Keys binded', true)
end

function error_handler(err)
    helpers.log("ERROR: "..tostring(err), true, 'e')
end

function script_loader.OnAllocate() end
function script_loader.OnInitialize() end

function script_loader.Update()
    if (bit.band(PlayerVars.scannedButtonsDirect,key_modifier)==key_modifier) then
        if (Time.GetRawElapsedTimeSinceStartUp() - script_loader.hold_pressed > 1) then
            script_loader.hold_pressed = Time.GetRawElapsedTimeSinceStartUp()

            for k,v in pairs(keys) do
                if (bit.band(PlayerVars.scannedButtonsDirect,k)==k)then
                    local t = script_loader.read_config()
                    if t["settings"]["play_sound"] == true then
                        TppMusicManager.PostJingleEvent("SingleShot","sfx_s_title_slct_mission")
                        xpcall(v, error_handler)
                    else
                        xpcall(v, error_handler)
                    end
                end
            end

            --press E
            if (bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.ACTION)==PlayerPad.ACTION)then
                script_loader.bind_keys()
            end

        end
    else
        script_loader.hold_pressed = Time.GetRawElapsedTimeSinceStartUp()
    end
end

function script_loader.OnTerminate() end

return script_loader
