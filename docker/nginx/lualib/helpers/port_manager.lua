local port_manager = {}

function port_manager.add_host(host, port, ssh_port)
    local redis = require "resty.redis"
    local red = redis:new()

    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect("redis", 6379)
    if not ok then
        return nil
    end

    local key = host .. ":" .. port

    return red:set(key, ssh_port)
end

return port_manager
