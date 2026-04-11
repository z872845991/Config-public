local M = {}
local wezterm = require("wezterm")
local transient_left_status_tokens = {}
local last_executed_commands = {}

function M.basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M.merge_tables(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			M.merge_tables(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

function M.merge_lists(t1, t2)
	local result = {}
	for _, v in pairs(t1) do
		table.insert(result, v)
	end
	for _, v in pairs(t2) do
		table.insert(result, v)
	end
	return result
end

function M.exists(tab, element)
	for _, v in pairs(tab) do
		if v == element then
			return true
		elseif type(v) == "table" then
			return M.exists(v, element)
		end
	end
	return false
end

function M.convert_home_dir(path)
	local cwd = path
	local home = os.getenv("HOME")
	cwd = cwd:gsub("^" .. home .. "/", "~/")
	if cwd == "" then
		return path
	end
	return cwd
end

function M.convert_useful_path(dir)
	local cwd = M.convert_home_dir(dir)
	return M.basename(cwd)
end

function M.split_from_url(dir)
	local cwd = ""
	local hostname = ""
	local cwd_uri = dir:sub(8)
	local slash = cwd_uri:find("/")
	if slash then
		hostname = cwd_uri:sub(1, slash - 1)
		-- Remove the domain name portion of the hostname
		local dot = hostname:find("[.]")
		if dot then
			hostname = hostname:sub(1, dot - 1)
		end
		cwd = cwd_uri:sub(slash)
		cwd = M.convert_useful_path(cwd)
	end
	return hostname, cwd
end

function M.show_transient_left_status(window, message, timeout_ms)
	local window_id = window:window_id()
	local token = (transient_left_status_tokens[window_id] or 0) + 1
	transient_left_status_tokens[window_id] = token

	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Text = " " .. message .. " " },
		{ Attribute = { Intensity = "Normal" } },
	}))

	wezterm.time.call_after(timeout_ms / 1000, function()
		if transient_left_status_tokens[window_id] ~= token then
			return
		end
		transient_left_status_tokens[window_id] = nil
		pcall(function()
			window:set_left_status("")
		end)
	end)
end

function M.trim_trailing_whitespace(s)
	if type(s) ~= "string" then
		return s
	end
	return (s:gsub("%s+$", ""))
end

function M.set_last_executed_command(pane_id, command)
	if pane_id == nil or type(command) ~= "string" then
		return
	end
	command = M.trim_trailing_whitespace(command)
	if command == "" then
		return
	end
	last_executed_commands[pane_id] = command
end

function M.get_last_executed_command(pane_id)
	if pane_id == nil then
		return nil
	end
	return last_executed_commands[pane_id]
end

return M
