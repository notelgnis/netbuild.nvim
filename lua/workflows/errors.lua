local errors = require 'netbuild.utils.errors'
local internal = require 'netbuild.utils.internal'

local M = {
    terminal = false,
    {
        id = 'show_errors',
        command = function(_)
            return function()
                if errors.LastErrors and errors.LastErrors ~= {} then
                    internal._show_errors(errors.LastErrors)
                else
                    print 'No errors found'
                end
            end
        end,
        next = function(_) end,
    },
}

return M
