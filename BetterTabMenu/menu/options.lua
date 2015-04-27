_G.BTM_options = _G.BTM_options or {}
BTM_options.path = ModPath
BTM_options.data_path = SavePath.."btm_options.txt"
BTM_options.data = {}

function BTM_options:save()
	local file = io.open(self.data_path, "w+")
	if file then
		file:write(json.encode(self.data))
		file:close()
	end
end

function BTM_options:load()
	local file = io.open(self.data_path)
	if file then
		self.data = json.decode(file:read())
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BTMOptions", function(loc)
	loc:load_localization_file(BTM_options.path.."menu/loc/en.txt")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_BTMOptions", function(menu_manager)
	function MenuCallbackHandler:callback_difficulty_skulls_toggle(item)
		BTM_options.data.use_skulls = item:value() == "on" and true or false
		BTM_options:save()
	end

	BTM_options:load()
	MenuHelper:LoadFromJsonFile(BTM_options.path.."menu/btm_options.txt", BTM_options, BTM_options.data)
end)