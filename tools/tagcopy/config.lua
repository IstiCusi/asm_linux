function CopyLineWithInfo()
    local current_buffer_name = vim.fn.bufname("%")
    local current_line_number = vim.fn.line(".")
    local current_line = vim.fn.getline(".")
    local copied_text = string.format("%s:%d %s", current_buffer_name, current_line_number, current_line)
    vim.fn.setreg("+", copied_text)
    vim.cmd("echo 'Yanked: " .. copied_text .. "'")
end
vim.api.nvim_set_keymap('n', '<F6>', [[:lua CopyLineWithInfo()<CR>]], { noremap = true, silent = true })

