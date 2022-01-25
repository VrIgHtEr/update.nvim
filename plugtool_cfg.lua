return {
    plugin_type = require('plugtool.constants').type.update,
    config = function()
        require('update-nvim').setup()
        nnoremap('<leader>pn', ':lua require"update-nvim".update()<cr>', 'silent', 'Update neovim')
    end,
}
