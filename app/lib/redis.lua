function getRedisInstance()
    local redis = require "resty.redis"

    local red = redis:new()
    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect("redis", 6379, 1)

    if err then
        ngx.log(ngx.NOTICE, err)

        return nil
    end

    if not ok then
        return nil
    end

    return red
end

return getRedisInstance
