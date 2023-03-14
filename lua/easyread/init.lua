print("hello world!")

local M = {}

function M.greet()
    print("hello from module!")
end

M.get_lines = function ()
    local numlines = vim.api.nvim_buf_line_count(0)
    local lines = vim.api.nvim_buf_get_lines(0, 0, numlines, false)

    print('lines: ', numlines)
    for index, value in ipairs(lines) do
        print(index, ' : ', value)
    end
end

return M
