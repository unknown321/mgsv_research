local helpers = {}

function helpers.split(str,sep)
  local sep, fields = sep or ";", {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function helpers.get_game_path()
  -- returns path with a slash on the end
  local paths = helpers.split(package.path,';')
  local steam_path = string.sub(paths[2],1,-10)
  return steam_path
end

function helpers.tablelength(t)
  local count = 0
  for i in pairs(t) do 
    count = count + 1 
  end
  return count
end

function helpers.log(str, announce, level)
    if announce~=nil then
        TppUiCommand.AnnounceLogView(str)
    end
    local level_text = "[---]"
    if level=='i' then
        level_text = "[INFO]"
    elseif level=='w' then
        level_text = "[WARNING]"
    elseif level=='e' then
        level_text = "[ERROR]"
    elseif level==nil then
        level_text = "[INFO]"
    else
        level_text = "[???]"
    end
    -- a+/w+ mode not working?
    local filename = helpers.get_game_path()
    filename = filename..'log.txt'
    filename = string.gsub(filename,'\\','\\\\')
    local f = io.open(filename,'r')
    local text = f:read("*all")
    f:close()
    local dtime = os.date("[%x %X] ")
    text = text..'\r\n'..level_text..dtime..str
    f = io.open(filename,'w')
    f:write(text)
    f:close()
end

function helpers.get_current_sequence()
    return _G['mvars']['seq_currentSequence']
end

function helpers.get_current_mission()
    return _G['mvars']['mis_missionName']
end

function helpers.get_pack_list()
    return _G['TppPackList']['missionPackList']
end

function helpers.get_index(t, element)
  local answer = 0
  for k,v in pairs(t) do
    if (v == element) then
      answer = k
    end
  end
  return answer
end

return helpers
