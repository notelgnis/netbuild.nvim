local s = require 'netbuild.utils.strings'

local M = {}

M._timer_id = nil
M._terminal_buf = nil
M._terminal_channel = nil
M._current_workflow = nil
M._current_window = nil

M._clean_up = function()
    M._timer_id = nil
    M._terminal_buf = nil
    M._current_workflow = nil
end

M._run_workflow = function(name, workflow)
    if M._timer_id then
        print 'The operation is in progress. Wait until it is finished.'
        return
    end

    M._current_window = vim.api.nvim_get_current_win()

    vim.cmd [[wa]]

    M._open_terminal(name)

    if not M._terminal_buf then
        M._clean_up()
        print 'Failed to open terminal'
        return
    end

    M._terminal_channel = vim.api.nvim_get_option_value('channel', { buf = M._terminal_buf })
    M._current_workflow = { workflow = workflow }
    M._current_workflow_step = M._current_workflow.workflow[1]
    M._state = 'not_started'

    vim.api.nvim_chan_send(M._terminal_channel, '\x15')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>i', true, false, true), 'n', false)

    M._timer_id = vim.fn.timer_start(250, M._execute_workflow, { ['repeat'] = -1 })
end

M._open_terminal = function(terminal_name)
    local windows = vim.api.nvim_list_wins()
    local terminal_found = false
    local terminal_buf = nil
    local terminal_win = nil

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:sub(-#terminal_name) == terminal_name then
            terminal_found = true
            terminal_buf = buf
            terminal_win = win
            break
        end
    end

    local bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:sub(-#terminal_name) == terminal_name then
            terminal_found = true
            terminal_buf = buf
            break
        end
    end

    if not terminal_found then
        vim.cmd 'split | terminal'
        terminal_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_name(terminal_buf, terminal_name)
    else
        if terminal_buf and not terminal_win then
            vim.cmd 'split'
            vim.api.nvim_set_current_buf(terminal_buf)
        else
            if terminal_win then
                vim.api.nvim_set_current_win(terminal_win)
                terminal_buf = vim.api.nvim_win_get_buf(terminal_win)
                vim.api.nvim_set_current_buf(terminal_buf)
            end
        end
    end

    M._terminal_buf = terminal_buf
end

M._toggle_terminal = function(terminal_name)
    local windows = vim.api.nvim_list_wins()
    local terminal_found = false
    local terminal_buf = nil
    local terminal_win = nil

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:sub(-#terminal_name) == terminal_name then
            terminal_found = true
            terminal_buf = buf
            terminal_win = win
            break
        end
    end

    local bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:sub(-#terminal_name) == terminal_name then
            terminal_found = true
            terminal_buf = buf
            break
        end
    end

    if not terminal_found then
        vim.cmd 'split | terminal'
        terminal_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_name(terminal_buf, terminal_name)
    else
        if terminal_buf and not terminal_win then
            vim.cmd 'split'
            vim.api.nvim_set_current_buf(terminal_buf)
        else
            if terminal_win then
                vim.api.nvim_win_hide(terminal_win)
            end
        end
    end
end

M._is_prompt_ready = function(output)
    if output then
        local lastLine = s._get_last_non_empty_line(output)
        if lastLine and #lastLine > 0 then
            if s._ends_with(lastLine, ' %') then
                return true
            end
        end
    end

    return false
end

M._get_step_by_id = function(workflow, id)
    for _, step in ipairs(workflow) do
        if step.id == id then
            return step
        end
    end
    return nil
end

M._execute_workflow = function()
    if not vim.api.nvim_buf_is_valid(M._terminal_buf) or not M._current_workflow or not M._terminal_buf then
        vim.fn.timer_stop(M._timer_id)
        M._clean_up()
        return
    end

    local output = vim.api.nvim_buf_get_lines(M._terminal_buf, 0, -1, false)

    if not M._is_prompt_ready(output) then
        return
    end

    if M._state == 'not_started' then
        local command = M._current_workflow_step.command(output)

        if type(command) == 'function' then
            command(output)
        else
            vim.api.nvim_chan_send(M._terminal_channel, M._current_workflow_step.command(output) .. '\n')
        end

        M._state = 'in_progress'
        return
    end

    if M._state == 'in_progress' then
        local next = M._current_workflow_step.next(output)
        if not next then
            vim.fn.timer_stop(M._timer_id)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true), 'n', false)
            M._clean_up()
        else
            if next ~= M._current_workflow_step.id then
                M._current_workflow_step = M._get_step_by_id(M._current_workflow.workflow, next)
                M._state = 'not_started'
            end
        end
    end
end

M._show_errors = function(errors)
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'
    local previewers = require 'telescope.previewers'
    local conf = require('telescope.config').values

    pickers
        .new({}, {
            prompt_title = 'Filter',
            finder = finders.new_table {
                results = errors,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.text,
                        ordinal = entry.filename .. ':' .. entry.lnum .. ' ' .. entry.text,
                        filename = entry.filename,
                        lnum = entry.lnum,
                    }
                end,
            },
            sorter = conf.generic_sorter {},
            previewer = previewers.new_buffer_previewer {
                title = 'Dotnet Build Errors',
                define_preview = function(self, entry)
                    previewers.buffer_previewer_maker(entry.filename, self.state.bufnr, {
                        bufname = self.state.bufname,
                        winid = self.state.winid,
                        callback = function(_)
                            pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, 0 })
                            pcall(vim.api.nvim_buf_call(self.state.bufnr, function()
                                vim.fn.clearmatches(self.state.winid)
                                vim.fn.matchaddpos('Search', { { entry.lnum, 1, -1 } })
                            end))
                            vim.api.nvim_set_option_value('number', true, { scope = 'local', win = self.state.winid })
                        end,
                    })
                end,
            },

            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.api.nvim_set_current_win(M._current_window)
                    vim.cmd('edit ' .. selection.filename)
                    vim.fn.cursor(selection.lnum, selection.index)
                end)
                return true
            end,
        })
        :find()
end

return M
