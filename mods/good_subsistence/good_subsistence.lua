local good_subsistence = {}
local helpers = require('helpers')

good_subsistence.state = 0

function switch_fulton()
	if good_subsistence.state == 0 then
		vars.playerDisableActionFlag = 	PlayerDisableAction.FULTON
		good_subsistence.state = 1
		helpers.log('[good_subsistence] Fulton disabled', true)
	else
		vars.playerDisableActionFlag = 	0
		good_subsistence.state = 0
		helpers.log('[good_subsistence] Fulton enabled', true)
	end
end