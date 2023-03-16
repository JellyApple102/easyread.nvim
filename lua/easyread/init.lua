local M = {}

M.start = function ()
    local ns = vim.api.nvim_create_namespace('easyreadns')
    local bufnr = vim.api.nvim_get_current_buf()
    local linecount = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, linecount, false)

    for i, line in ipairs(lines) do
        -- bold half of each word
        for s, w, e in string.gmatch(line, '()(%w+)()') do
            local half = math.floor(string.len(w) / 2)
            vim.api.nvim_buf_add_highlight(bufnr, ns, 'Bold', i - 1, s - 1, e - 1 - half);
        end
    end
end

return M
