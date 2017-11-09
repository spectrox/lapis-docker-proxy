HostModel = {}
HostModel.__index = HostModel

function HostModel:create()
    local model = {}

    setmetatable(model, HostModel)

    model.keys = {}
    model.list_key = "hosts_list"

    local redis = require "resty.redis"

    model.redis = redis:new()
    model.redis:set_timeout(1000) -- 1 sec

    local ok, err = model.redis:connect("redis", 6379)
    if not ok then
        return nil
    end

    return model
end

function HostModel:add(host, port, ssh_port)
    local key = host .. ":" .. port

    self.redis:set(key, ssh_port)
    self.redis:sadd(self.list_key, key);
end

function HostModel:remove(host, port)
    local key = host .. ":" .. port

    self.redis:del(key)
    self.redis:srem(self.list_key, key);
end

function HostModel:get_list()
    return self.redis:smembers(self.list_key)
end

return HostModel
