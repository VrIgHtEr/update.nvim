return {
    needs = { 'vrighter/toolshed.nvim' },
    after = { 'vrighter/toolshed.nvim' },
    config = function()
        require('update-nvim').setup()
    end,
}
