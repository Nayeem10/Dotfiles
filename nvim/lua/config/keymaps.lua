-- =========================
-- Keymaps Configuration
-- =========================

-- Helper function for keymaps (defaults: noremap = true, silent = true)
local map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- =========================
-- Escape / Backspace
-- =========================
map("i", "jj", "<Esc>")                     -- Escape insert mode
map("t", "jj", "<C-\\><C-n>")               -- Escape terminal mode
map("i", "kk", "<BS>")                      -- kk as backspace in insert mode


-- =========================
-- Navigation (Arrow-style hjkl)
map({ "n", "v", "o" }, "h", "h")           -- Left
map({ "n", "v", "o" }, "j", "k")           -- Up
map({ "n", "v", "o" }, "k", "j")           -- Down
map({ "n", "v", "o" }, "l", "l")           -- Right

-- =========================
-- Window Management
map("n", "<C-l>", "<C-w>l")
map("n", "<C-Right>", "<C-w>l")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-Left>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-Down>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-Up>", "<C-w>k")

-- =========================
-- Plugin Mappings
map("n", "<F5>", function() require("dap").continue() end)  -- Debugging (nvim-dap)
map("n", "<C-n>", ":NvimTreeToggle<CR>")                     -- NvimTree toggle
map("n", "<C-f>", ":Telescope find_files<CR>")              -- Telescope find files

-- =========================
-- Editing / Clipboard
map("i", "<C-a>", "<C-o>gg<C-o>VG")                         -- Select all in insert mode
map("n", "<C-c>", '"+y')                                    -- Copy in normal mode
map("v", "<C-c>", '"+y')                                    -- Copy selection

-- =========================
-- Build / Compile / Run
map("n", "<F6>", ":5split | terminal g++ % -o %:r<CR>", { silent = false })  -- Build C++ in split

-- Ctrl+Alt+N: Compile and run C++ with input/output redirection
-- Global variable to store the terminal buffer handle
local term_buf = nil

map("n", "<C-A-n>", function()
  local file = vim.fn.expand("%")
  local base = vim.fn.expand("%:r")

  local cmd = string.format(
    "g++ -std=c++20 -DLOCAL -Wall -I/home/nayeem/Documents/CP %s -o %s && " ..
    "timeout 5s ./%s </home/nayeem/Documents/CP/Codes/input.txt >" ..
    "/home/nayeem/Documents/CP/Codes/output.txt && rm %s",
    file, base, base, base
  )

  -- Check if terminal buffer exists and is valid
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    -- Find the window showing this buffer, or open it if not visible
    local term_win = vim.fn.bufwinnr(term_buf)
    if term_win == -1 then
        vim.cmd("botright 10split")
        vim.api.nvim_set_current_buf(term_buf)
    else
        vim.cmd(term_win .. "wincmd w")
    end
    
    -- Send the command to the existing terminal
    -- \13 is the carriage return (Enter key)
    vim.api.nvim_chan_send(vim.b[term_buf].terminal_job_id, cmd .. "\13")
  else
    -- Create new split and terminal if none exist
    vim.cmd("botright 10split")
    vim.cmd("enew")
    term_buf = vim.api.nvim_get_current_buf()
    vim.fn.termopen(cmd)
  end

  vim.cmd("startinsert")
end)
