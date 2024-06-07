local M = {}

M._parse_dotnet_build_output = function(output)
    local errors = {}
    local capture_errors = false

    for line in output:gmatch '[^\r\n]+' do
        if line:match 'Build FAILED.' then
            capture_errors = true
        elseif capture_errors then
            local file, line_number, error_message = line:match '(.-)%((%d+),%d+%)%:%s*error%s*[^:]+:%s*(.+)'
            if file and line_number and error_message then
                table.insert(errors, {
                    filename = file,
                    lnum = tonumber(line_number),
                    text = error_message,
                })
            end
        end
    end

    return errors
end

return M
