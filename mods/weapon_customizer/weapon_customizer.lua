--chimera shit

local weapon_id = 0
-- 0-7, rifle-handgun-sniper etc
local chimera_category_index = 0 
-- 0-2 - slot number
local chimera_weapon_index = 0 
-- 0-11 - weapon part, muzzle, magazine, barrel etc
local chimera_part_index = 0 


function get_equipped_weapons()
	local debugfile = io.open("C:\\weps.txt",'w')
	-- debugfile:write("userPresetChimeraParts:\n")
	-- for k,v in pairs(vars.userPresetChimeraParts) do
	-- 	if type(v) == 'number' then
	-- 		debugfile:write(string.format('\t%s %s \n',tostring(k),tostring(v)))	
	-- 	else
	-- 		debugfile:write(string.format('\t%s %s \n',tostring(k),type(v)))
	-- 	end
	-- end

	-- debugfile:write("userPresetCustomizedWeapon:\n")
	-- for k,v in pairs(vars.userPresetCustomizedWeapon) do
	-- 	if type(v) == 'number' then
	-- 		debugfile:write(string.format('\t%s %s \n',tostring(k),tostring(v)))	
	-- 	else
	-- 		debugfile:write(string.format('\t%s %s \n',tostring(k),type(v)))
	-- 	end
	-- end
	


	debugfile:write("userPresetCustomizedWeapon_test:\n")
	local index = 0
	while type(vars.userPresetCustomizedWeapon[index]) == 'number' do
		debugfile:write(string.format('\t%s\n',tostring(vars.userPresetCustomizedWeapon[index])))
		index = index + 1
	end	

	debugfile:write("userPresetChimeraParts:\n")
	local index = 0
	while type(vars.userPresetChimeraParts[index]) == 'number' do
		debugfile:write(string.format('\t%s\n',tostring(vars.userPresetChimeraParts[index])))
		index = index + 1
	end	

	TppUiCommand.AnnounceLogView('Done')

		-- TppUiCommand.AnnounceLogView( string.format( "slot: %s",tostring(slot)) )
		-- TppUiCommand.AnnounceLogView(string.format( "weaponid: %s", tostring(vars.weapons[0]) ) )
		-- TppUiCommand.AnnounceLogView(tostring(vars.userPresetCustomizedWeapon[0]))
		-- TppUiCommand.AnnounceLogView(tostring(vars.userPresetCustomizedWeapon[1]))
	-- end
	debugfile:close()
end


function change_equip_id()
	local index = 0
	if (weapon_id ~= 0) then
		index = get_index(weapons, weapon_id)
	end

	if (index == table.getn(weapons)) then
		index = 0
	end

	index = index + 1
	TppUiCommand.AnnounceLogView(string.format('weapon index: %s',tostring(index)))
	weapon_id = weapons[index]
end

function change_chimepa_category_index()
	if chimera_category_index == 7 then
		chimera_category_index = 0
	else
		chimera_category_index = chimera_category_index + 1
	end
	TppUiCommand.AnnounceLogView(string.format('Current category index: %s',tostring(chimera_category_index)))
end

function change_chimepa_weapon_index()
	if chimera_weapon_index == 2 then
		chimera_weapon_index = 0
	else
		chimera_weapon_index = chimera_weapon_index + 1
	end
	TppUiCommand.AnnounceLogView(string.format('Current weapon index: %s',tostring(chimera_weapon_index)))
end

function change_chimepa_part_index()
	if chimera_part_index == 11 then
		chimera_part_index = 0
	else
		chimera_part_index = chimera_part_index + 1
	end
	TppUiCommand.AnnounceLogView(string.format('Current part index: %s',tostring(chimera_part_index)))
end

function change_chimera_part(new_value,part_index,weapon_index,category_index)
	local index_to_change = 12*3*category_index + 12*weapon_index + part_index
	TppUiCommand.AnnounceLogView(
		string.format('part_index %s weapon_index %s category_index %s', 
					tostring(part_index), tostring(weapon_index), tostring(category_index)))
	TppUiCommand.AnnounceLogView(string.format('index %s, value %s', 
			tostring(index_to_change), tostring(vars.userPresetChimeraParts[index_to_change]) ))
	vars.userPresetChimeraParts[index_to_change] = vars.userPresetChimeraParts[index_to_change] + 1
end



change_chimera_part(1,chimera_part_index,chimera_weapon_index,chimera_category_index)