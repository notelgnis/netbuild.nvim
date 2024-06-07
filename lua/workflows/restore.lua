local M = {
    terminal = true,
    {
        id = 'clear',
        command = function(_)
            return 'clear'
        end,
        next = function(_)
            return 'restore'
        end,
    },
    {
        id = 'restore',
        command = function(_)
            return 'dotnet restore'
        end,
        next = function(_) end,
    },
}
return M
