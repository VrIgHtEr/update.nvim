local M = {}
local env = require 'toolshed.env'
local a = require 'toolshed.async'
local git = require 'toolshed.git'
local dirname = 'neovim'
local marker = env.get_dependency_path(dirname) .. '/update.nvim'

local build_commands = {
    { 'make', 'CMAKE_BUILD_TYPE=Release', 'CMAKE_EXTRA_FLAGS=-DCMAKE_INSTALL_PREFIX=' .. env.root },
    { 'make', 'install' },
    { 'touch', marker },
}

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
        vim.notify('Executing command:\n' .. vim.inspect(x), 'info', { title = 'update.nvim' })
        local ret = a.spawn_lines_a(x, print)
        if ret ~= 0 then
            vim.schedule(function()
                vim.notify('An error occurred while executing command\n' .. vim.inspect(x), 'error', { title = 'update.nvim' })
            end)
            return false
        end
        return true
    end
end

function M.update()
    return a.run(function()
        local updates = assert(git.update_a(env.get_dependency_path(dirname)))
        if #updates ~= 0 then
            env.deleteFileOrDir(marker)
        end
        if env.file_exists(marker) then
            return false
        end
        return rebuild()
    end)
end
return M
