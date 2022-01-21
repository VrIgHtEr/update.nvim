local M = {}
local env = require 'toolshed.env'
local a = require 'toolshed.async'
local git = require 'toolshed.git'
local dirname = 'neovim'
local path = env.get_dependency_path(dirname)
local buildpath = path .. '/build'
local marker = path .. '/update.nvim'

local build_commands = {
    { 'make', 'CMAKE_BUILD_TYPE=Release', 'CMAKE_EXTRA_FLAGS=-DCMAKE_INSTALL_PREFIX=' .. env.root },
    { 'make', 'install' },
    { 'touch', marker },
}

for _, x in ipairs(build_commands) do
    x.cwd = path
end

function M.setup()
    a.run(function()
        a.spawn_a { 'ln', '-s', env.bin .. '/nvim', vim.fn.fnamemodify('~', ':p') .. '/.local/bin/nvim' }
        env.install_dependencies {
            {
                dirname = dirname,
                repo = 'https://github.com/neovim/neovim',
                builddeps = {},
                buildcmd = build_commands,
            },
        }
    end)
end

local function rebuild()
    for _, x in ipairs(build_commands) do
        vim.schedule(function()
            vim.notify('Executing command:\n' .. vim.inspect(x), 'info', { title = 'update.nvim' })
        end)
        local ret = a.spawn_lines_a(x, print)
        if ret ~= 0 then
            vim.schedule(function()
                vim.notify('An error occurred while executing command\n' .. vim.inspect(x), 'error', { title = 'update.nvim' })
            end)
            return false
        end
    end
    vim.schedule(function()
        vim.notify('Neovim was updated successfully.\n\nPlease restart', 'info', { title = 'update.nvim' })
    end)
    return true
end

function M.update()
    return a.run(function()
        local updates = assert(a.wait(git.update_async(path)))
        if #updates ~= 0 then
            env.deleteFileOrDir(marker)
        end
        if env.file_exists(marker) then
            vim.schedule(function()
                vim.notify('Neovim is already up to date', 'info', { title = 'update.nvim' })
            end)
            return false
        end
        return rebuild()
    end)
end
return M
