local M = {}

M.config = {
    hlValues = {
        ['1'] = 1,
        ['2'] = 1,
        ['3'] = 2,
        ['4'] = 2,
        ['fallback'] = 0.4
    },
    hlgroupOptions = { link = 'Bold' },
    fileTypes = { 'text' },
    saccadeInterval = 0,
    saccadeReset = false,
    updateWhileInsert = true
}

M.check_config = function(config)
    if config.hlValues then
        M.config.hlValues = {}
    end
    if config.fileTypes then
        M.config.fileTypes = {}
    end
    if config.hlgroupOptions then
        M.config.hlgroupOptions = {}
    end
end

M.setup = function(config)
    -- config
    M.check_config(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    M.activeBufs = {}

    -- highlights
    M.namespace = vim.api.nvim_create_namespace('easyread')
    vim.api.nvim_set_hl(0, 'EasyreadHl', M.config.hlgroupOptions)
    M.hlgroup = 'EasyreadHl'
end

M.highlight = function()
    M.clear()

    local bufnr = vim.api.nvim_get_current_buf()
    M.activate_buf(bufnr)
    local linecount = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, linecount, false)

    local saccadecounter = 0
    for i, line in ipairs(lines) do
        -- reset saccade if configured
        if M.config.saccadeReset then
            saccadecounter = 0
        end

        -- highlight according to hlValues
        for s, w in string.gmatch(line, '()(%w+)') do
            -- reset saccadecounter if over the interval
            if saccadecounter > M.config.saccadeInterval then
                saccadecounter = 0
            end

            -- highlight word if at beginning of interval
            if saccadecounter == 0 then
                local length = string.len(w)
                local strLength = tostring(length)
                local toHl = 0

                if M.config.hlValues[strLength] then
                    toHl = M.config.hlValues[strLength]
                else
                    toHl = math.floor(length * M.config.hlValues['fallback'] + 0.5)
                end

                vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hlgroup, i - 1, s - 1, s - 1 + toHl)
            end

            saccadecounter = saccadecounter + 1
        end
    end
end

M.clear = function()
    local bufnr = vim.api.nvim_get_current_buf()
    M.deactivate_buf(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

M.activate_buf = function(bufnr)
    M.activeBufs[bufnr] = true
end

M.deactivate_buf = function(bufnr)
    M.activeBufs[bufnr] = nil
end

M.check_active_buf = function(bufnr)
    return M.activeBufs[bufnr] ~= nil
end

-- user commands
vim.api.nvim_create_user_command('EasyreadToggle', function()
    local bufnr = vim.api.nvim_get_current_buf()
    if M.check_active_buf(bufnr) then
        M.clear()
    else
        M.highlight()
    end
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

vim.api.nvim_create_user_command('EasyreadUpdateWhileInsert', function()
    if M.config.updateWhileInsert then
        M.config.updateWhileInsert = false
    else
        M.config.updateWhileInsert = true
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
        local bufnr = vim.api.nvim_get_current_buf()
        if M.check_active_buf(bufnr) then
            M.highlight()
        end
    end
})

vim.api.nvim_create_autocmd('TextChangedI', {
    pattern = '*',
    group = group,
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if M.config.updateWhileInsert and M.check_active_buf(bufnr) then
            M.highlight()
        end
    end
})

return M
