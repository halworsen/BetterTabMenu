function MODULE:init()
	Hooks:PreHook(HUDStatsScreen, "_animate_show_stats_left_panel", "BTMShowNewTabMenu", function()
		self:show()
	end)
	Hooks:PostHook(HUDStatsScreen, "_animate_hide_stats_left_panel", "BTMHideNewTabMenu", function()
		self:hide()
	end)

	-- make colors easier
	Color.pro = tweak_data.screen_colors.pro_color
	Color.friend = tweak_data.screen_colors.friend_color
	Color.risk = tweak_data.screen_colors.risk
	Color.s_blue = tweak_data.screen_color_blue

	self:update_vars()
	self:perform_modifications()
end

function MODULE:update()
	if not self.resolution_callback_added and managers.viewport then
		self.resolution_callback_added = true
		managers.viewport:add_resolution_changed_func(function() self:init() end)
	end
	
	if not Utils:IsInGameState() then return end
	if not managers.hud._hud_statsscreen or not managers.hud._hud_statsscreen._full_hud_panel then return end
	
	-- original elements have a tendency of returning to their original sizes
	self:hide_existing_elements()
end

function MODULE:perform_modifications()
	self.elements = {}

	-- Right panel
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Content container
	self.elements.container = managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):panel({
		name = "btm_right_panel_container",
		w = managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):w(),
		h = managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):h()
	})

	local x, y = managers.gui_data:corner_safe_to_full(0, 0)

	-- Job title
	self.elements.job_title = self.elements.container:text({
		name = "btm_job_title",
		text = self.job_name,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = y
	})

	local text_x, text_y, text_w, text_h = self.elements.job_title:text_rect()

	-- "PRO JOB"
	self.elements.pro_title = self.elements.container:text({
		name = "btm_pro_title",
		-- by setting text based on whether you're playing a pro job or not (as opposed to setting visibility) MODULE:show() doesn't need special exceptions
		text = (self.pro_job and "BLO JOB" or ""),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.pro,
		x = x + text_w + 10,
		y = text_y
	})

	-- Day title
	self.elements.day_title = self.elements.container:text({
		name = "btm_day_title",
		text = (self.day_name ~= self.job_name and self.day_name or ""),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	if self.elements.day_title:text() ~= "" then
		text_x, text_y, text_w, text_h = self.elements.day_title:text_rect()
	end

	-- Day counter
	self.elements.day_counter = self.elements.container:text({
		name = "btm_day_counter",
		text = ("DAY "..self.current_stage.." OF "..self.stages),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	text_x, text_y, text_w, text_h = self.elements.day_counter:text_rect()

	-- Ghost icon
	self.elements.ghost_icon = self.elements.container:text({
		name = "btm_ghost_icon",
		text = utf8.char(57363),
		font = tweak_data.hud_stats.objectives_font,
		font_size = 19,
		color = self.stealth_broken and Color.pro or Color.s_blue,
		x = x + text_w + 5,
		y = 0
	})
	ghost_x, ghost_y, ghost_w, ghost_h = self.elements.ghost_icon:text_rect()
	self.elements.ghost_icon:set_y((text_y + text_h/2) - ghost_h/2)

	-- "DIFFICULTY: "
	self.elements.difficulty_text = self.elements.container:text({
		name = "btm_difficulty_text",
		text = "DIFFICULTY: ",
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h*2
	})

	text_x, text_y, text_w, text_h = self.elements.difficulty_text:text_rect()

	-- Difficulty skulls
	self.elements.skulls = {}
	local texture_skull, texture_skull_rect = tweak_data.hud_icons:get_icon_data("risk_swat")
	local texture_dw_skull, texture_dw_skull_rect = tweak_data.hud_icons:get_icon_data("risk_pd")

	local normal_skull_data = {
		texture = texture_skull,
		texture_rect = texture_skull_rect,
		w = 24,
		h = 24,
		color = Color.risk,
		alpha = 0.5
	}
	local dw_skull_data = {
		texture = texture_dw_skull,
		texture_rect = texture_dw_skull_rect,
		w = 24,
		h = 24,
		color = Color.risk,
		alpha = 0.5
	}

	for i = 1,4 do
		self.elements.skulls[i] = self.elements.container:bitmap((i == 4 and dw_skull_data or normal_skull_data))	

		self.elements.skulls[i]:set_name("difficulty_skull_"..i)
		self.elements.skulls[i]:set_x(text_w + 15 + 20*i)
		self.elements.skulls[i]:set_y(text_y + text_h / 2 - self.elements.skulls[i]:h()/2)

		if i <= self.difficulty then
			self.elements.skulls[i]:set_alpha(1)
		end
	end

	-- Payday
	self.elements.payday_text = self.elements.container:text({
		name = "btm_payday_text",
		text = ("PAYDAY: "..self.payday),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h*2
	})

	text_x, text_y, text_w, text_h = self.elements.payday_text:text_rect()

	-- Offshore account
	self.elements.offshore_text = self.elements.container:text({
		name = "btm_offshore_text",
		text = ("OFFSHORE ACCOUNT: "..self.offshore_cash),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	text_x, text_y, text_w, text_h = self.elements.offshore_text:text_rect()

	-- "CLEANER COSTS: "
	self.elements.cleaner_costs_text = self.elements.container:text({
		name = "btm_cleaner_costs_text",
		text = "CLEANER COSTS: ",
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	text_x, text_y, text_w, text_h = self.elements.cleaner_costs_text:text_rect()

	-- Actual cleaner costs string
	self.elements.cleaner_costs_amount = self.elements.container:text({
		name = "btm_cleaner_costs_amount",
		text = self.cleaner_costs,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.friend,
		x = x + text_w,
		y = text_y
	})

	-- "SPENDING CASH: "
	self.elements.spending_cash_text = self.elements.container:text({
		name = "btm_spending_cash_text",
		text = "SPENDING CASH: ",
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	text_x, text_y, text_w, text_h = self.elements.spending_cash_text:text_rect()

	-- Actual spending cash string
	self.elements.spending_cash_amount = self.elements.container:text({
		name = "btm_spending_cash_amount",
		text = self.spending_cash,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.friend,
		x = x + text_w,
		y = text_y
	})

	-- "PROFIT: "
	self.elements.profit_text = self.elements.container:text({
		name = "btm_profit_text",
		text = "PROFIT: ",
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.white,
		x = x,
		y = text_y + text_h
	})

	text_x, text_y, text_w, text_h = self.elements.profit_text:text_rect()

	-- Actual profit string
	self.elements.profit_amount = self.elements.container:text({
		name = "btm_profit_amount",
		text = self.profit,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size,
		color = Color.friend,
		x = x + text_w,
		y = text_y
	})

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	self:show()

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	BTM:print("Stats screen modifications performed succesfully.")
end

-- called before the stats/tab screen appears
function MODULE:show()
	self:update_vars()

	-- ghost icon color
	if managers.groupai:state():is_police_called() then
		self.elements.ghost_icon:set_color(Color.pro)
	end

	-- cleaner costs color
	if self.real_cleaner_costs > 0 then
		self.elements.cleaner_costs_amount:set_color(Color.pro)
	end

	-- spending cash color
	if self.real_spending_cash < 0 then
		self.elements.spending_cash_amount:set_color(Color.pro)
	elseif self.real_spending_cash >= 0 then
		self.elements.spending_cash_amount:set_color(Color.friend)
	end

	-- profit color
	if self.real_profit < 0 then
		self.elements.profit_amount:set_color(Color.pro)
	elseif self.real_profit >= 0 then
		self.elements.profit_amount:set_color(Color.friend)
	end

	-- update payday info
	self.elements.payday_text:set_text("PAYDAY: "..self.payday)
	self.elements.offshore_text:set_text("OFFSHORE ACCOUNT: "..self.offshore_cash)
	self.elements.cleaner_costs_amount:set_text(self.cleaner_costs)
	self.elements.spending_cash_amount:set_text(self.spending_cash)
	self.elements.profit_amount:set_text(self.profit)

	for k,v in pairs(self.elements) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				if not v2:visible() then
					v2:set_visible(true)
				end
			end
		else
			if not v:visible() then
				v:set_visible(true)
			end
		end
	end
end

-- called after the stats/tab screen disappears
function MODULE:hide()
	for k,v in pairs(self.elements) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				if v2:visible() then
					v2:set_visible(false)
				end
			end
		else
			if v:visible() then
				v:set_visible(false)
			end
		end
	end
end

function MODULE:update_vars()
	local stage_value, job_value, bag_value, vehicle_value, small_value, crew_value, total_payout = managers.money:get_real_job_money_values(managers.network:game():amount_of_alive_players(), true)
	--local total_payout = managers.money:get_potential_payout_from_current_stage()

	local spending_cash = total_payout * 0.2
	local cleaner_costs = managers.money:get_civilian_deduction() * managers.statistics:session_total_civilian_kills()

	self.payday = managers.experience:cash_string(total_payout)
	self.offshore_cash = managers.experience:cash_string(total_payout * 0.8)

	self.real_cleaner_costs = cleaner_costs
	self.cleaner_costs = utf8.to_upper(managers.experience:cash_string(cleaner_costs).." ("..managers.statistics:session_total_civilian_kills().." killed)")

	self.real_spending_cash = spending_cash
	self.spending_cash = managers.experience:cash_string(spending_cash)

	self.real_profit = spending_cash - cleaner_costs
	self.profit = managers.experience:cash_string(self.real_profit)

	-- job/heist related
	local job_data = managers.job:current_job_data()

	self.job_name = utf8.to_upper(managers.localization:text(job_data.name_id))
	self.day_name = utf8.to_upper(managers.localization:text(managers.job:current_level_data().name_id))
	self.current_stage = managers.job:current_stage()
	self.stages = #job_data.chain
	self.pro_job = string.match(managers.job:current_job_id(), "prof")

	-- difficulty
	local difficulty_map = {
		[0] = "normal",
		[1] = "hard",
		[2] = "very hard",
		[3] = "overkill",
		[4] = "death wish"
	}

	self.difficulty = managers.job:current_difficulty_stars()
	self.difficulty_str = difficulty_map[job_difficulty]
	self.difficulty_color = job_difficulty ~= 0 and Color.risk or Color.white

	--[[
	self.hit_accuracy = managers.statistics:session_hit_accuracy().."%" or "0"
	self.special_kills = managers.statistics:session_total_specials_kills() or "0"
	self.downed_count = managers.statistics:total_downed() or "0"
	self.shots_fired = managers.statistics:session_total_shots() or "0"
	self.favorite_weapon = managers.statistics:session_favourite_weapon()
	--]]
end

function MODULE:hide_existing_elements()
	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("days_title"):set_w(0)
	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("days_title"):set_h(0)

	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("ghost_icon"):set_w(0)
	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("ghost_icon"):set_h(0)

	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("day_wrapper_panel"):set_w(0)
	managers.hud._hud_statsscreen._full_hud_panel:child("right_panel"):child("day_wrapper_panel"):set_h(0)
end
