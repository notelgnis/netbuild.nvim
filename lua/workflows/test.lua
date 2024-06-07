local M = {
    terminal = true,
    {
        id = 'clear',
        command = function(_)
            return 'clear'
        end,
        next = function(_)
            return 'test'
        end,
    },
    {
        id = 'test',
        command = function(_)
            return 'dotnet test'
        end,
        next = function(_) end,
    },
}
return M
