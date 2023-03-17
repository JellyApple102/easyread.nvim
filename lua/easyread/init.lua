local M = {}

M.start = function ()
    M.clear()

    local bufnr = vim.api.nvim_get_current_buf()
    local linecount = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, linecount, false)

    local saccadecounter = 0
    for i, line in ipairs(lines) do
        -- reset saccade if configured
        if M.config.saccadeReset then
            saccadecounter = 0
        end

        -- bold half of each word
        for s, w, e in string.gmatch(line, '()(%w+)()') do
            -- reset saccadecounter if over the interval
            if saccadecounter > M.config.saccadeInterval then
                saccadecounter = 0
            end

            -- highlight word if at beginning of interval
            if saccadecounter == 0 then
                local half = math.floor(string.len(w) / 2)
                vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hlgroup, i - 1, s - 1, e - 1 - half)
                saccadecounter = saccadecounter + 1
            else
                saccadecounter = saccadecounter + 1
            end
        end
    end
end

M.clear = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

M.config = {
    hlgroup = { link = 'Bold' },
    fileTypes = { 'text' },
    saccadeInterval = 0,
    saccadeReset = false,
    updateInsertMode = false
}

M.setup = function (config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    M.namespace = vim.api.nvim_create_namespace('easyread')

    vim.api.nvim_set_hl(0, 'EasyreadHl', M.config.hlgroup)
    M.hlgroup = 'EasyreadHl'

    vim.api.nvim_create_user_command('EasyreadClear', function ()
        M.clear()
    end, {})

    vim.api.nvim_create_user_command('EasyreadStart', function ()
        M.start()
    end, {})
end

return M

-- TODO
-- [x] add default config and setup function
-- [x] custom highlight group
-- [] default on filetypes
-- [x] implement saccades interval
--   [x] reset by line or carry over option ??
-- [] update during insert mode option
-- -- autocommands?
-- [] figure out how to determine how much of a word to bold
-- -- fixation??
-- [x] add vim command(s) e.g. <cmd>EasyreadToggle?
-- -- :h nvim_create_user_command()
