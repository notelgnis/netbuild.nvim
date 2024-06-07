---@diagnostic disable: undefined-global
describe('buildandrun', function()
    before_each(function()
        -- put some setup code here
    end)

    it('can require buildandrun', function()
        require 'netbuildn.init'
    end)

    it('should fail for this line', function()
        local result = require('netbuildn.init')._ends_with('(base) roman.stefanov@Romans-MacBook-Pro buildandrun.nvim % dotnet build', 's %')
        assert.is_false(result)
    end)
end)
