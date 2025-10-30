require("config.lazy")

-- Converted from vimrc.vim to Lua

-- General options
vim.opt.background = "dark"
vim.opt.history = 10000
vim.opt.autoread = true
vim.opt.wildignore = "*.o,*~,*.pyc"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.mouse = ""

-- Text, tab and indent related
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.textwidth = 79
vim.opt.softtabstop = 4
vim.opt.linebreak = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true

-- GUI options
if vim.fn.has("gui_running") == 1 then
  vim.opt.guioptions:remove("T")
  vim.opt.guioptions:remove("e")
  vim.opt.t_Co = 256
  vim.opt.guitablabel = "%M\\ %t"
end

-- Filetype
vim.cmd("filetype plugin indent on")

-- Colorscheme with error handling
pcall(vim.cmd.colorscheme, "hybrid")
vim.api.nvim_set_hl(0, "Normal", { ctermbg = 0 })
vim.api.nvim_set_hl(0, "NonText", { ctermbg = 0 })

-- Key mappings
vim.keymap.set("n", "<C-n>", ":Explore<CR>", { silent = true })
vim.keymap.set("n", "<C-p>", ":Files<CR>", { silent = true })
vim.keymap.set("n", "<C-b>", ":Buffers<CR>", { silent = true })

-- Debugging shortcuts
vim.keymap.set("n", "<leader>db", "oimport pdb; pdb.set_trace()<Esc>")
vim.keymap.set("n", "<leader>ry", "obinding.pry<Esc>")

-- Movement mappings
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "<localleader><cr>", ":noh<cr>", { silent = true })

-- Window navigation
vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-k>", "<C-W>k")
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")

-- Tab management
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>")
vim.keymap.set("n", "<leader>to", ":tabonly<cr>")
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>")
vim.keymap.set("n", "<leader>tm", ":tabmove ")
vim.keymap.set("n", "<leader>t<leader>", ":tabnext ")

-- Directory and paste
vim.keymap.set("n", "<leader>cd", ":cd %:p:h<cr>:pwd<cr>")
vim.keymap.set("n", "<leader>pp", ":setlocal paste!<cr>")

-- Spell checking
vim.keymap.set("n", "<leader>ss", ":setlocal spell!<cr>")
vim.keymap.set("n", "<leader>sn", "]s")
vim.keymap.set("n", "<leader>sp", "[s")
vim.keymap.set("n", "<leader>sa", "zg")
vim.keymap.set("n", "<leader>s?", "z=")
vim.keymap.set("n", "<leader>r", ":%s/")

-- Ruby test mappings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function()
    vim.keymap.set("n", "<leader>t", ":TermExec cmd=\"make test TARGET=%\"<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>e", function()
      local linenum = vim.fn.line('.')
      local file = vim.fn.expand('%')
      vim.cmd('TermExec cmd="make test TARGET=' .. file .. ':' .. linenum .. '"')
    end, { buffer = true })
  end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end
})

-- Go development configuration
vim.g.go_fmt_command = "goimports"
vim.g.go_list_type = "quickfix"

-- Go build function - run GoBuild or GoTestCompile based on file type
local function build_go_files()
  local file = vim.fn.expand('%')
  if file:match('_test%.go$') then
    vim.cmd('GoTestCompile')
  elseif file:match('%.go$') then
    vim.cmd('GoBuild')
  end
end

-- Go test function
local function test_go_func()
  vim.cmd('GoTestFunc')
end

-- Go-specific key mappings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.keymap.set("n", "<leader>b", build_go_files, { buffer = true, desc = "Build Go files" })
    vim.keymap.set("n", "<leader>t", test_go_func, { buffer = true, desc = "Test Go function" })
  end
})

-- Quickfix navigation mappings (global)
vim.keymap.set("n", "<C-f>", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-a>", ":cprevious<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>a", ":cclose<CR>", { desc = "Close quickfix" })

-- Delete trailing whitespace on save
local function delete_trailing_ws()
  local save_cursor = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//ge]])
  vim.fn.setpos(".", save_cursor)
end

vim.api.nvim_create_autocmd("BufWrite", {
  pattern = {
      "*.py",
      "*.rb",
      "*.go",
      "*.js",
      "*.ts",
      "*.lua",
      "*.java",
      "*.c",
      "*.cpp",
      "*.html",
      "*.css",
      "*.md"
  },
  callback = delete_trailing_ws
})
