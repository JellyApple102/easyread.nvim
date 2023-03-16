local M = {}

M.config = {
    hlgroup = 'Bold',
    fileTypes = { 'text' },
    saccadeInterval = 0,
    saccadeReset = false,
    updateInsertMode = false
}

M.setup = function (config)
    M.config = config

    M.namespace = vim.api.nvim_create_namespace('easyread')

    if type(M.config.hlgroup) == 'string' then
        M.hlgroup = M.config.hlgroup
    elseif type(M.config.hlgroup) == 'table' then
        vim.api.nvim_set_hl(0, 'EasyreadHl', M.config.hlgroup)
        M.hlgroup = 'EasyreadHl'
    end
end

M.start = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local linecount = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, linecount, false)

    for i, line in ipairs(lines) do
        -- bold half of each word
        for s, w, e in string.gmatch(line, '()(%w+)()') do
            local half = math.floor(string.len(w) / 2)
            vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hlgroup, i - 1, s - 1, e - 1 - half);
        end
    end
end

M.clear = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

return M

-- TODO
-- [x] add default config and setup function
-- [] custom highlight group
-- [] default on filetypes
-- [] implement saccades interval
--   [x] reset by line or carry over option ??
-- [] update during insert mode option
-- -- autocommands?
-- [] figure out how to determine how much of a word to bold
-- -- fixation??
-- [] add vim command(s) e.g. <cmd>EasyreadToggle
-- -- :h nvim_create_user_command()
