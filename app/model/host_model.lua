getRedisInstance = require "lib/redis"

HOSTS_LIST_KEY = "hosts_list"
LOGIN_LIST_KEY = "login_list_"
HOST_TO_LOGIN_KEY = "host_to_login_"
SSH_PORT_LOCK_KEY = "ssh_port_lock_"
USER_SSH_PORT_LIST_KEY = "user_ssh_port_list_"
USER_PORT_TO_PORT_KEY = "user_port_to_port_"

function lockSshPort(redis, login, port, sshPort)
    local key = SSH_PORT_LOCK_KEY .. sshPort
    local mapKey = USER_PORT_TO_PORT_KEY .. login .. "_" .. port
    local listKey = USER_SSH_PORT_LIST_KEY .. login

    redis:set(key, login)
    redis:set(mapKey, sshPort)
    redis:sadd(listKey, port)
end

function unlockSshPort(redis, sshPort)
    local key = SSH_PORT_LOCK_KEY .. sshPort

    local login = redis:get(key)

    if login then
        local listKey = USER_SSH_PORT_LIST_KEY .. login
        local list = redis:smembers(listKey)

        if list then
            for _, port in pairs(list) do
                local mapKey = USER_PORT_TO_PORT_KEY .. login .. "_" .. port

                redis:del(mapKey)
            end
        end
    end

    redis:del(key, login)
end

function isSshPortLocked(redis, login, sshPort)
    local key = SSH_PORT_LOCK_KEY .. sshPort
    local currentLogin = redis:get(key)

    if currentLogin and currentLogin ~= login then
        return true
    end

    return false
end

function pushToHostsList(redis, server)
    redis:sadd(HOSTS_LIST_KEY, server);
end

function removeFromHostsList(redis, server)
    redis:srem(HOSTS_LIST_KEY, server);
end

function pushToUserList(redis, login, server)
    local loginListKey = LOGIN_LIST_KEY .. login

    redis:sadd(loginListKey, server)
end

function removeFromUserList(redis, login, server)
    local loginListKey = LOGIN_LIST_KEY .. login

    redis:srem(loginListKey, server)
end

function assignHostToUser(redis, login, server)
    local hostToLoginKey = HOST_TO_LOGIN_KEY .. server

    redis:set(hostToLoginKey, login)
end

function detachHostFromUser(redis, server)
    local hostToLoginKey = HOST_TO_LOGIN_KEY .. server

    local login = redis:get(hostToLoginKey)

    redis:del(hostToLoginKey)

    return login
end

HostModel = {}
HostModel.__index = HostModel

function HostModel:create()
    local model = {}

    setmetatable(model, HostModel)

    return model
end

function HostModel:add(login, host, port, sshPort)
    local redis = getRedisInstance()

    local server = host .. ":" .. port

    pushToHostsList(redis, server)
    pushToUserList(redis, login, server)
    assignHostToUser(redis, login, host)

    redis:set(server, sshPort)
end

function HostModel:remove(host, port)
    local redis = getRedisInstance()

    local server = host .. ":" .. port

    redis:del(server)

    removeFromHostsList(redis, server)
    local login = detachHostFromUser(redis, server)

    if login then
        removeFromUserList(redis, login, server)
    end
end

function HostModel:getList()
    local redis = getRedisInstance()

    return redis:smembers(HOSTS_LIST_KEY)
end

function HostModel:getForUser(login)
    local redis = getRedisInstance()
    local key = USER_LIST_KEY .. login

    return redis:members(key) or {};
end

function HostModel:getSshPort(login, port)
    local redis = getRedisInstance()
    local mapKey = USER_PORT_TO_PORT_KEY .. login .. "_" .. port

    return redis:get(mapKey)
end

function HostModel:getPortsForUser(login)
    local redis = getRedisInstance()
    local userKey = USER_SSH_PORT_LIST_KEY .. login

    return redis:smembers(userKey)
end

function HostModel:isSshPortLocked(login, sshPort)
    local redis = getRedisInstance()

    return isSshPortLocked(redis, login, sshPort)
end

function HostModel:lockSshPort(port, sshPort)
    local redis = getRedisInstance()

    return lockSshPort(redis, login, port, sshPort)
end

function HostModel:unlockSshPort(sshPort)
    local redis = getRedisInstance()

    return unlockSshPort(redis, sshPort)
end

return HostModel
