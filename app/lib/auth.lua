getRedisInstance = require "lib/redis"
idGenerator = require "lib/id_generator"

UserRepository = require "repository/user_repository"

AUTH_KEY = 'auth_key_'
AUTH_TTL = 3600

auth = {}

function auth.getUserByKey(ukey)
    local redis = getRedisInstance()
    local key = AUTH_KEY .. ukey

    local login, err = redis:get(key)

    if err or not login then
        return nil
    end

    if login == ngx.null then
        return nil
    end

    local repo = UserRepository:create()

    return repo:get(login)
end

function auth.setUserKey(user)
    local ukey = ngx.md5(user:getId() .. "_" .. idGenerator())
    local key = AUTH_KEY .. ukey

    local redis = getRedisInstance()

    local ok, err = redis:setex(key, AUTH_TTL, user:getLogin())

    if err then
        return nil
    end

    return ukey
end

function auth.getPasswordHash(password)
    return ngx.md5(password)
end

function auth.authenticate(login, password)
    local passwordHash = auth.getPasswordHash(password)

    local repo = UserRepository:create()
    local user = repo:get(login)

    if not user then
        return nil
    end

    if user:getPassword() ~= passwordHash then
        return nil
    end

    return auth.setUserKey(user)
end

return auth
