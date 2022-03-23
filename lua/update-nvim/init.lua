local M = {}
local env = require("toolshed.env")
local a = require("toolshed.async")
local git = require("toolshed.git")
local dirname = "neovim"
local path = env.get_dependency_path(dirname)
local buildpath = path .. "/build"
local marker = path .. "/.update.nvim"

local build_commands = {
	{ "make", "clean" },
	{ "make", "CMAKE_BUILD_TYPE=Release", "CMAKE_EXTRA_FLAGS=-DCMAKE_INSTALL_PREFIX=" .. env.root },
	{ "make", "install" },
	{ "touch", marker },
}

for _, x in ipairs(build_commands) do
	x.cwd = path
end

local function notify(message, msgtype)
	if message == nil then
		message = ""
	else
		message = tostring(message)
	end
	if not msgtype or type(msgtype) ~= "string" then
		msgtype = "info"
	end
	vim.schedule(function()
		vim.notify(message, msgtype, { title = "update.nvim" })
	end)
end

function M.setup()
	a.run(function()
		a.wait(a.spawn_async({ "ln", "-s", env.bin .. "/nvim", vim.fn.fnamemodify("~", ":p") .. "/.local/bin/nvim" }))
		env.install_dependencies({
			{
				dirname = dirname,
				repo = "https://github.com/neovim/neovim",
				builddeps = {},
				buildcmd = build_commands,
			},
		})
	end)
end

local function rebuild()
	for _, x in ipairs(build_commands) do
		notify("Executing command:\n" .. table.concat(x, " "))
		local ret = a.wait(a.spawn_lines_async(x, print))
		if ret ~= 0 then
			notify("An error occurred while executing command\n" .. table.concat(x, " "), "error")
			return false
		end
	end
	notify("Neovim was updated successfully.\n\nPlease restart")
	return true
end

function M.update()
	return a.run(function()
		notify("Checking for updates")
		local updates = assert(a.wait(git.update_async(path)))
		if #updates ~= 0 then
			env.deleteFileOrDir(marker)
		end
		if env.file_exists(marker) then
			notify("Neovim is already up to date!")
			return false
		end
		return rebuild()
	end)
end
return M
