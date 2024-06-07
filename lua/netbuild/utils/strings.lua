local M = {}

M._trim = function(s)
    return (s:gsub('^%s*(.-)%s*$', '%1'))
end

M._starts_with = function(str, start)
    return str:sub(1, #start) == start
end

M._ends_with = function(str, ending)
    return ending == '' or str:sub(-#ending) == ending
end

M._find_in_output = function(output, pattern)
    for i = #output, 1, -1 do
        if output[i] ~= '' and output[i]:find(pattern) then
            return true
        end
    end
    return false
end

M._get_last_non_empty_line = function(output)
    for i = #output, 1, -1 do
        if output[i] ~= '' and output[i] ~= nil then
            return M._trim(output[i])
        end
    end
    return nil
end

M._tostring = function(output)
    local result = ''
    for i = 1, #output do
        result = result .. output[i] .. '\n'
    end
    return result
end

return M
