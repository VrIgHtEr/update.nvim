return {
    needs = { 'vrighter/toolshed.nvim' },
    after = { 'vrighter/toolshed.nvim' },
    config = function()
        require('update-nvim').setup()
        nnoremap('<leader>pn', ':lua require"update-nvim".update()<cr>', 'silent', 'Update neovim')
    end,
}
