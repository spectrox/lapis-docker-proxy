KeyModel = {};
KeyModel.__index = KeyModel

function KeyModel:create()
    local model = {}

    setmetatable(model, KeyModel)

    model:load()

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

function KeyModel:add(key)
    self.keys[key] = true

    self:save()
end

function KeyModel:clear()
    self.keys = {}

    self:save()
end

function KeyModel:get_list()
    local result = {}
    local n = 1

    for line, _ in pairs(self.keys) do
        result[n] = line
        n = n + 1
    end

    return result
end

function KeyModel:save()
    local list = self:get_list()

    local file = io.open('/app/ssh/authorized_keys', 'w+')

    file:write(table.concat(list, "\n"))
    file:close()
end

return KeyModel
