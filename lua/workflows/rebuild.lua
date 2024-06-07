local errors = require 'netbuild.utils.errors'
local strings = require 'netbuild.utils.strings'
local internal = require 'netbuild.utils.internal'

local M = {
    terminal = true,
    {
        id = 'clear',
        command = function(_)
            return 'clear'
        end,
        next = function(_)
            return 'clean'
        end,
    },
    {
        id = 'clean',
        command = function(_)
            return 'dotnet clean'
        end,
        next = function(_)
            return 'clear_after_clean'
        end,
    },
    {
        id = 'clear_after_clean',
        command = function(_)
            return 'clear'
        end,
        next = function(_)
            errors.LastErrors = {}
            return 'build'
        end,
    },
    {
        id = 'build',
        command = function(_)
            return 'dotnet build'
        end,
        next = function(output)
            if not strings._find_in_output(output, 'Build succeeded') then
                return 'parse_errors'
            end
        end,
    },
    {
        id = 'parse_errors',
        command = function(output)
            local output_str = strings._tostring(output)
            return function()
                errors.LastErrors = errors._parse_dotnet_build_output(output_str)
            end
        end,
        next = function(_)
            return 'show_errors'
        end,
    },
    {
        id = 'show_errors',
        command = function(_)
            return function()
                internal._show_errors(errors.LastErrors)
            end
        end,
        next = function(_) end,
    },
}
return M
