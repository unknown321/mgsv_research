-- animation player
local animation_changer = {}
local helpers = require('helpers')
local debug = false

local ani_index = 1 		--start index
local ani_inner_index = 2	--current animation step, 1 is the animation name
local ani_hold_forever = true	-- animation has to be stopped or you won't be able to move
local ani_repeat = false	-- works only for regular animations (ie, mission victory), 
							-- mgo animations doesn't have an end, so they won't repeat

--27 mgo+1 fob animation
local motions_table = {
	{"Salute",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_slt_start_l.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_slt_idl_l.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_slt_ed_l.gani"
	},

	{"VenomSnake",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_fst_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_fst_idl_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snambud/snambud_s_fst_ed.gani"
	},

	{"Ocelot",
	"/Assets/mgo/motion/SI_game/fani/bodies/ocep/ocepbud/ocepbud_s_slt_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/ocep/ocepbud/ocepbud_s_slt_idl_l.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/ocep/ocepbud/ocepbud_s_slt_ed.gani"
	},

	{"QuietThumbsUpGood",
	"/Assets/mgo/motion/SI_game/fani/bodies/quip/quipnon/quipnon_s_good_st_l.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/quip/quipnon/quipnon_s_good_idl_l.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/quip/quipnon/quipnon_s_good_ed_l.gani"
	},


	{"MaruSign",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_6_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_6_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"BatsuSign",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_7_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_7_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"DVolunteer",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_9_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_9_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"DBow",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_8_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_8_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"Push",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_23_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_23_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"Disappointed",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_16_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_16_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"StandAttention",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_21_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_21_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"GratitudeBow",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_22_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_22_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"Karate",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_20_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_20_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"KungFu",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_18_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_18_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"BodyBuilderFrontChest",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_1_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_1_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"BodyBuilderSideChest",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_2_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_2_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"RollDanceUp",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_3_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_3_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"RollDanceSide",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_4_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_4_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},


	{"RollDanceDown",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_5_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_5_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"UDanceUp",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_25_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_25_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"UDanceSide",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_26_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_26_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"LDanceUp",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_28_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_28_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"LDanceSide",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_29_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_29_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"GutsPose",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_17_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_17_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"SuperSUp",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_10_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_10_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"SuperSSide",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_11_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_11_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"
	},

	{"Pointing",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_19_st.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_19_lp.gani",
	"/Assets/mgo/motion/SI_game/fani/bodies/snam/snamidl/snamidl_s_ed.gani"},

	{"missionClearMotionFob",
	"/Assets/tpp/motion/SI_game/fani/bodies/snap/snapnon/snapnon_s_win_idl.gani"}
}

function animation_changer.play_animation(index, subindex, hold, arepeat)
	index, subindex = animation_changer.check_bounds(index, subindex)
	Player.RequestToPlayDirectMotion {	
		motions_table[index][1],
		{
			motions_table[index][subindex],
			hold,
			"",
			"",
			"",
			arepeat
		},{}
	}
end

function animation_changer.check_bounds(index, subindex)
	-- I don't remember why do I have to return index and subindex instead of
	-- ani_index and ani_inner_index, but it works so don't touch it.
	if index > helpers.tablelength(motions_table) then
		ani_index = 1
		index = 1
	end
	if subindex > helpers.tablelength(motions_table[ani_index]) then
		ani_inner_index = 2
		subindex = 2
	end
	return index, subindex
end

function animation_changer.stop_animation()
	if debug==true then
		helpers.log('[ANICHANGER] anistop',true)
	end
	Player.RequestToStopDirectMotion()
end


function animation_changer.play_next_animation_step()
	-- animation_changer.stop_animation()
	ani_inner_index = ani_inner_index + 1
	animation_changer.play_animation(ani_index, ani_inner_index, ani_hold_forever, ani_repeat)
	if debug==true then
		local animation_name = motions_table[ani_index][1]
		helpers.log(string.format("[ANICHANGER] playing %s %s %s",tostring(ani_index), tostring(ani_inner_index), animation_name),true)
	end
end

function animation_changer.play_next_animation()
	-- animation_changer.stop_animation()
	ani_index = ani_index + 1
	animation_changer.play_animation(ani_index, ani_inner_index, ani_hold_forever, ani_repeat)
	if debug==true then
		local animation_name = motions_table[ani_index][1]
		helpers.log(string.format("[ANICHANGER] playing %s %s %s",tostring(ani_index), tostring(ani_inner_index), animation_name),true)
	end
end

function animation_changer.play_current_animation()
	-- animation_changer.stop_animation()
	if debug==true then
		local animation_name = motions_table[ani_index][1]
		helpers.log(string.format("[ANICHANGER] playing %s %s %s",tostring(ani_index), tostring(ani_inner_index), animation_name),true)
	end
	animation_changer.play_animation(ani_index, ani_inner_index, ani_hold_forever, ani_repeat)
end


return animation_changer

