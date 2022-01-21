local M = {}
local env = require 'toolshed.env'
local a = require 'toolshed.async'
local dirname = 'neovim'

function M.setup()
    a.run(function()
        a.spawn_a { 'ln', '-s', env.bin .. '/nvim', vim.fn.fnamemodify('~', ':p') .. '/.local/bin/nvim' }
        env.install_dependencies {
            {
                dirname = dirname,
                repo = 'https://github.com/neovim/neovim',
                builddeps = {},
                buildcmd = {
                    { 'rm', '-rf', 'build/' },
                    { 'make', 'CMAKE_EXTRA_FLAGS=-DCMAKE_INSTALL_PREFIX=' .. env.root },
                    { 'make', 'install' },
                    { 'rm', '-rf', 'build/' },
                },
            },
        }
    end)
end

return M
