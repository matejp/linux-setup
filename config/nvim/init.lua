-- No Plugins Neovim Configuration
-- Based on https://github.com/YanivZalach/Vim_Config_NO_PLUGINS

vim.g.mapleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 20

-- vim.opt.compatible is not valid in Neovim (always off)
vim.opt.visualbell = true
vim.opt.encoding = "utf-8"
vim.opt.mouse = "a"
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.smarttab = true
vim.opt.path:append("**")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.showmatch = true
vim.opt.history = 1000
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wildmenu = true
vim.opt.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
-- vim.opt.undoreload is not a valid Neovim option; removed
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.complete:append("k")
vim.opt.completeopt = "menu,menuone,noinsert"

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

vim.cmd([[colorscheme slate]])

-- Statusline functions (Lua only; Vimscript versions removed as duplicates)
local function statusline_mode()
    local mode = vim.fn.mode()
    if mode == "n" then return "NORMAL"
    elseif mode == "V" then return "VISUAL LINE"
    elseif mode == "v" or mode == "no" then return "VISUAL"
    elseif mode == "i" then return "INSERT"
    elseif mode == "R" then return "REPLACE"
    elseif mode == "c" then return "COMMAND"
    elseif mode == "!" then return "SHELL"
    else return "VIM"
    end
end

local function spell_check_status()
    -- vim.opt.spell:get() returns the actual boolean value
    if vim.opt.spell:get() then
        return " [SPELL]"
    else
        return ""
    end
end

-- Expose functions globally so the statusline %{} expressions can call them
StatuslineMode = statusline_mode
SpellCheckStatus = spell_check_status

vim.opt.laststatus = 2
vim.opt.statusline = "%2* %{v:lua.StatuslineMode()} %{v:lua.SpellCheckStatus()} %1* <- %f -> %4*%m%=%h%r%4*%c/%l/%L %1*|%y %4*%P t:%n"

vim.cmd([[
hi User2 ctermbg=lightgreen ctermfg=black guibg=lightgreen guifg=black
hi User1 ctermbg=brown ctermfg=white guibg=black guifg=white
hi User3 ctermbg=brown ctermfg=lightcyan guibg=black guifg=lightblue
hi User4 ctermbg=brown ctermfg=green guibg=black guifg=lightgreen
]])

vim.cmd([[
function! ToggleHebrew()
    if &rtl
        set norl
        set keymap=
        set spell
        echo 'Hebrew mode OFF'
    else
        set rtl
        set keymap=hebrew
        set nospell
        echo 'Hebrew mode ON'
    endif
endfunction

function! DoHex()
    let current_file = expand('%')
    let new_file = current_file . '.hex'
    execute 'w !xxd > ' . new_file
    echo 'Hex file created: ' . new_file
endfunction

function! UndoHex()
    let current_file = expand('%')
    let new_file_stage1 = substitute(current_file, '\.hex$', '', '')
    let file_name = substitute(new_file_stage1, '\(.*\)\.\(\w\+\)$', '\1', '')
    let file_extension = substitute(new_file_stage1, '\(.*\)\.\(\w\+\)$', '\2', '')
    let new_file = file_name . 'M.' . file_extension
    execute 'w !xxd -r > ' . new_file
    echo 'Reversed Hex file created: ' . new_file
endfunction
]])

vim.api.nvim_set_keymap("n", "<Esc>", "<cmd>noh<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("n", "Q", "gq<CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>a", "ggVG", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>e", ":Lex<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>o", ":Explore<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-t>", ":ter<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-t>", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })
vim.api.nvim_set_keymap("t", "<C-q>", "<C-\\><C-n>:q!<CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>y", ":split ", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>x", ":vsplit ", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>t", "gt", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>c", ":tabedit ", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-q>", ":wq<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>ht", ":call ToggleHebrew()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>hx", ":call DoHex()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>v", "<C-v>", { noremap = true })

vim.api.nvim_set_keymap("v", "<C-c>", '"*y :let @+=@*<CR>', { noremap = true })
vim.api.nvim_set_keymap("v", "+y", '"*y :let @+=@*<CR>', { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>r", ":registers<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("v", "J", ":m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("v", "K", ":m '<-2<CR>gv=gv", { noremap = true })

vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true })

vim.api.nvim_set_keymap("n", "x", '"_x', { noremap = true })

vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-z>", ":setlocal spell! spelllang=en_us<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.has("gui_running") == 1 then
            vim.opt.guifont = "JetBrainsMono Nerd Font:h12"
        end
    end,
})

print("Neovim configured - No Plugins Edition")
