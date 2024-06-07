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
        next = function(_) end,
    },
}
return M
