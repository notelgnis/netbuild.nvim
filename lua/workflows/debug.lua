local errors = require 'netbuild.utils.errors'

local M = {
    terminal = true,
    {
        id = 'clear',
        command = function(_)
            return 'clear'
        end,
        next = function(_)
            return 'build'
        end,
    },
    {
        id = 'build',
        command = function(_)
            errors.LastErrors = {}
            return 'dotnet build'
        end,
        next = function(_) end,
    },
}
return M
