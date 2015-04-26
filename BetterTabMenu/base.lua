if not _G.BTM then
	_G.BTM = {}

	BTM.modules = {}

	BTM.log_path = LogsPath.."BTM.txt"
	BTM.log_timestamp = true

	function BTM:print(msg)
		local timestamp = os.date("%X").." - "

		msg = "[BTM] "..(self.log_timestamp and timestamp or "")..tostring(msg)

		log(msg)

		local file = io.open(self.log_path, "a+")
		if file then
			file:write(msg.."\n")
		end

		file:close()
	end

	function BTM:get_module(module_name)
		return self.modules[module_name]
	end

	function BTM:require_file(name)
		local path = ModPath.."btm/"..name..".lua"

		if io.file_is_readable(path) then
			BTM.modules[name] = BTM.modules[name] or setmetatable({}, {})

			_G.MODULE = BTM.modules[name]
			dofile(path)
			MODULE:init()
			MODULE = nil
			collectgarbage()

			BTM:print("Loaded module "..name..".lua")
		else
			BTM:print("Attempt to require an invalid mapped file: "..path.."!")
		end
	end
end

BTM.requiredscript_map = {
	["lib/managers/hud/hudstatsscreen"] = "main"
}

if PersistScriptPath then
	for k,v in pairs(BTM.modules) do
		if v.update then
			v:update()
		end
	end
elseif RequiredScript then
		lower_reqscript = RequiredScript:lower()

		if BTM.requiredscript_map[lower_reqscript] then
			local name = BTM.requiredscript_map[lower_reqscript]
			BTM:require_file(name)
		else
			BTM:print("Attempt to require a non-mapped file! Hook: "..RequiredScript)
		end
end