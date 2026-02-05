return {
  'akinsho/toggleterm.nvim',
  version = "*",
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 25
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.25
      end
    end,
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = 'horizontal',
    close_on_exit = true,
    shell = vim.o.shell,
  },
  keys = {
    -- Horizontal terminal with 40 line height
    { "<leader>th", "<cmd>ToggleTerm size=25 direction=horizontal<cr>", desc = "Terminal (horizontal)" },
    -- Additional useful terminal shortcuts
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical)" },
  },
}
