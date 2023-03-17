local M = {}

M.highlight = function()
    M.clear()
    M.active = true

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

M.clear = function()
    M.active = false
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

M.setup = function(config)
    -- config
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    M.active = false

    -- highlights
    M.namespace = vim.api.nvim_create_namespace('easyread')
    vim.api.nvim_set_hl(0, 'EasyreadHl', M.config.hlgroup)
    M.hlgroup = 'EasyreadHl'

    -- user commands
    vim.api.nvim_create_user_command('EasyreadClear', function()
        M.clear()
    end, {})

    vim.api.nvim_create_user_command('EasyreadStart', function()
        M.highlight()
    end, {})

    vim.api.nvim_create_user_command('EasyreadSaccadeInterval', function(opts)
        M.config.saccadeInterval = tonumber(opts.fargs[1])
        M.highlight()
    end, { nargs = 1 })

    vim.api.nvim_create_user_command('EasyreadSaccadeReset', function()
        if M.config.saccadeReset then
            M.config.saccadeReset = false
        else
            M.config.saccadeReset = true
        end
        M.highlight()
    end, {})

    vim.api.nvim_create_user_command('EasyreadUpdateInsert', function()
        if M.config.updateInsertMode then
            M.config.updateInsertMode = false
        else
            M.config.updateInsertMode = true
        end
    end, {})

    -- auto commands
    local group = vim.api.nvim_create_augroup('easyread', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        pattern = M.config.fileTypes,
        group = group,
        callback = function() M.highlight() end
    })

    vim.api.nvim_create_autocmd('InsertLeave', {
        pattern = '*',
        group = group,
        callback = function()
            if M.active then
                M.highlight()
            end
        end
    })

    vim.api.nvim_create_autocmd('TextChangedI', {
        pattern = '*',
        group = group,
        callback = function()
            if M.config.updateInsertMode and M.active then
                M.highlight()
            end
        end
    })
end

return M

-- TODO
-- [x] add default config and setup function
-- [x] custom highlight group
-- [x] default on filetypes
-- [x] implement saccades interval
--   [x] reset by line or carry over option ??
-- [x] update during insert mode option
-- [] figure out how to determine how much of a word to bold
-- -- fixation??
-- [x] add user commands
