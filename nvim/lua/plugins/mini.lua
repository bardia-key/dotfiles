return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        require('mini.splitjoin').setup()
        require('mini.indentscope').setup()
        require('mini.icons').setup()
    end,
}
