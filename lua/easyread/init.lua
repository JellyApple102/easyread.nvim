print('easyread loaded')

local M = {}

M.start = function ()
    local ns = vim.api.nvim_create_namespace('easyreadns')
    local bufnr = vim.api.nvim_get_current_buf()
    local linecount = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, linecount, false)

    for i, _ in ipairs(lines) do
        -- highlight first 3 characters in each line
        vim.api.nvim_buf_add_highlight(bufnr, ns, 'Bold', i - 1, 0, 3)
    end
end

return M
