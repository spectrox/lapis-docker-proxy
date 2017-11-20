getRedisInstance = require "lib/redis"

UserModel = require "model/user_model"

USER_LIST_KEY = "users"
USER_ID_KEY = "user_id_"
USER_PASSWORD_KEY = "user_password_"


function getUserIdKey(login)
    return USER_ID_KEY .. login
end

function getUserPasswordKey(login)
    return USER_PASSWORD_KEY .. login
end

function isValidLogin(login)
    return string.match(login, '^[a-z0-9%_%-%.]+$')
end

function collectUserModel(id, login, password)
    local user = UserModel:create(id)
    user:setLogin(login)
    user:setPassword(password)

    return user
end

UserRepository = {};
UserRepository.__index = UserRepository

function UserRepository:create()
    local model = {}

    setmetatable(model, UserRepository)

    return model
end

function UserRepository:get(login)
    if not isValidLogin(login) then
        return nil
    end

    local redis = getRedisInstance()

    local res, err = redis:sismember(USER_LIST_KEY, login)
    if err then
        ngx.log(ngx.NOTICE, "cannot check if user already exists, " .. err)
    end

    if not res or res == ngx.null then
        return nil
    end

    local id = redis:get(getUserIdKey(login))
    local password = redis:get(getUserPasswordKey(login))

    return collectUserModel(id, login, password)
end

function UserRepository:getAll()
    local redis = getRedisInstance()
    local res, err = redis:smembers(USER_LIST_KEY)

    if err then
        ngx.log(ngx.NOTICE, "cannot get user list, " .. err)
    end

    local users = {}

    for login in res do
        users[login] = self:get(login)
    end

    return users
end

function UserRepository:save(user)
    local isValid, err = self.validate(user)

    if not isValid then
        return nil, err
    end

    local redis = getRedisInstance()

    local res, err = redis:sismember(user:getLogin())
    if err then
        ngx.log(ngx.NOTICE, "cannot check if user already exists, " .. err)
        return nil
    end

    if not res then
        redis:sadd(USER_LIST_KEY, user:getLogin())
    end

    local userIdKey = getUserIdKey(user:getLogin())
    local userPasswordKey = getUserPasswordKey(user:getLogin())

    redis:set(userIdKey, user:getId())
    redis:set(userPasswordKey, user:getPassword())

    return true
end

function UserRepository:validate(user)
    if not user:getLogin() then
        return false, "Empty login"
    end

    if not isValidLogin(login) then
        return false, "Not valid login"
    end

    if not user:getPassword() then
        return false, "Empty password"
    end

    return true, nil
end

return UserRepository
