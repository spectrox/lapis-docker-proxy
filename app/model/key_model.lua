KeyModel = {};
KeyModel.__index = KeyModel

function KeyModel:create()
    local model = {}

    setmetatable(model, KeyModel)

    return model
end

function KeyModel:load()
    self.keys = {}

    local file = io.open('/app/ssh/authorized_keys', 'a+')

    if file == nil then
        return
    end

    for line in file:lines() do
        line = line:gsub("^[%s%n]*(.-)[%s%n]*$", "%1")

        if line ~= '' then
            self.keys[line] = true
        end
    end

    return
end

function KeyModel:add(login, key)
    key = key:gsub('^(.-)%s*([^%s]-)$', '%1') .. ' ' .. login

    self.keys[key] = true

    self:save()
end

function KeyModel:replace(login, newKeys)
    local allKeys = self:getList()
    local keys = {}

    if allKeys then
        for line, _ in pairs(allKeys) do
            if not string.match(line, '%s' .. login .. '$') then
                keys[line] = true
            end
        end

        self.keys = keys
    end

    for _, line in pairs(newKeys) do
        self:add(login, line)
    end
end

function KeyModel:clear()
    self.keys = {}

    self:save()
end

function KeyModel:getList()
    local result = {}
    local n = 1

    if not self.keys then
        return {}
    end

    for line, _ in pairs(self.keys) do
        result[n] = line
        n = n + 1
    end

    return result
end

function KeyModel:getForUser(login)
    local result = {}
    local n = 1

    if not self.keys then
        return {}
    end

    for line, _ in pairs(self.keys) do
        if string.match(line, '%s' .. login .. '$') then
            result[n] = line
            n = n + 1
        end
    end

    return result
end

function KeyModel:save()
    local list = self:getList()

    local file = io.open('/app/ssh/authorized_keys', 'w+')

    file:write(table.concat(list, "\n"))
    file:close()
end

return KeyModel
