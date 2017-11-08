local key_manager = {}

function key_manager.add_key(new_key)
    local file = io.open('/app/ssh/authorized_keys', 'a+')

    local arr = {}
    arr[new_key] = true

    if not file == nil then
        for line in file:lines() do
            arr[line] = true
        end

        file:close()
    end

    file = io.open('/app/ssh/authorized_keys', 'w+')

    local result = ''
    for line, _ in ipairs(arr) do
        result = result .. "\n" .. line
    end

    file:write(result)
    file:close()
end

return key_manager
