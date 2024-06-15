vim.api.nvim_create_user_command('NetBuild', function(args)
    local command = args.args
    if command == 'build' then
        require('netbuild').build()
    elseif command == 'run' then
        require('netbuild').run()
    elseif command == 'debug' then
        require('netbuild').debug()
    elseif command == 'test' then
        require('netbuild').test()
    elseif command == 'restore' then
        require('netbuild').restore()
    elseif command == 'clean' then
        require('netbuild').clean()
    elseif command == 'rebuild' then
        require('netbuild').rebuild()
    elseif command == 'toggle' then
        require('netbuild').toggle()
    elseif command == 'errors' then
        require('netbuild').errors()
    else
        print 'Supported commands: build, run, debug.'
    end
end, {
    nargs = 1,
    complete = function(arglead, _, _)
        local completions = {}
        local options = { 'build', 'run', 'debug', 'test', 'restore', 'clean', 'rebuild', 'errors', 'toggle' }

        for _, opt in ipairs(options) do
            if opt:match('^' .. arglead) then
                table.insert(completions, opt)
            end
        end

        return completions
    end,
})
