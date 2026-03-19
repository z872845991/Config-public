--- @sync entry
local function entry()
	-- 同步上下文中收集选中的文件路径
	local selected = {}
	for _, u in pairs(cx.active.selected) do
		table.insert(selected, tostring(u))
	end
	if #selected == 0 then
		local hovered = cx.active.current.hovered
		if not hovered then
			ya.notify({ title = "Open with", content = "No file selected", level = "warn", timeout = 3 })
			return
		end
		table.insert(selected, tostring(hovered.url))
	end

	-- 切换到异步上下文调用 ya.input
	local paths = selected
	ya.async(function()
		local value, event = ya.input({
			title = "Open with:",
			pos = { "top-center", y = 3, w = 45 },
		})

		if event ~= 1 or not value or value == "" then
			return
		end

		local quoted = {}
		for _, path in ipairs(paths) do
			table.insert(quoted, "'" .. path:gsub("'", "'\\''") .. "'")
		end
		local cmd = value .. " " .. table.concat(quoted, " ")

		ya.emit("shell", { cmd, block = true, confirm = true })
	end)
end

return { entry = entry }
