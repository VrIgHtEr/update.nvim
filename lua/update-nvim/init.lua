local M = {}
local env = require 'toolshed.env'
local a = require 'toolshed.async'
local dirname = 'neovim'

function M.setup()
    return a.run(function()
        return env.install_dependencies {
            {
                dirname = dirname,
                repo = 'https://github.com/neovim/neovim',
                builddeps = {},
                buildcmd = {
                    { 'rm', '-rf', 'build/' },
                    { 'make', 'CMAKE_EXTRA_FLAGS=-DCMAKE_INSTALL_PREFIX=' .. env.root },
                    { 'make', 'install' },
                },
            },
        }
    end)
end

return M
