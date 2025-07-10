return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        -- Enable splitjoin
        require('mini.splitjoin').setup()
        -- Enable indentscope
        require('mini.indentscope').setup()
    end,
}
