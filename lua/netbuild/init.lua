local utils = require 'netbuild.utils.internal'

local M = {}
M._opts = {
    terminal_name = 'netbuild-console',
}
M.setup = function(opts)
    if opts then
        for k, v in pairs(opts) do
            if v ~= nil then
                M._opts[k] = v
            end
        end
    end
end

M.build = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.build')
end

M.run = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.run')
end

M.debug = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.debug')
end

M.test = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.test')
end

M.clean = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.clean')
end

M.restore = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.restore')
end

M.rebuild = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.rebuild')
end

M.errors = function()
    utils._run_workflow(M._opts.terminal_name, require 'workflows.errors')
end

return M
