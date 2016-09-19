local good_subsistence = {}
local helpers = require('helpers')
local debug = false

good_subsistence.state = 0

function switch_fulton()
	if good_subsistence.state == 0 then
		vars.playerDisableActionFlag = 	PlayerDisableAction.FULTON
		good_subsistence.state = 1
		if debug then
			helpers.log('[good_subsistence] Fulton disabled', true)
		end
	else
		vars.playerDisableActionFlag = 	0
		good_subsistence.state = 0
		if debug then
			helpers.log('[good_subsistence] Fulton disabled', true)
		end
	end
end

function drop_weapon()
	Player.UnsetEquip{ slotType = vars.currentInventorySlot, dropPrevEquip = true, }
	if debug then
		helpers.log('[good_subsistence] Dropped current weapon', true)
	end
end