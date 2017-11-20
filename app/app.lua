local lapis = require "lapis"
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local app = lapis.Application()
app:enable("etlua")

KeyModel = require "model/key_model";
HostModel = require "model/host_model";

auth = require "lib/auth"

app:before_filter(function(self)
    if self.route_name == "login" then
        return
    end

    if not self.cookies.ukey then
        self:write({ json = { code = "REDIRECT_AUTH" } })
        return
    end

    local user = auth.getUserByKey(self.cookies.ukey)
    if user then
        self.user = user
    else
        self:write({ json = { code = "REDIRECT_AUTH" } })
        return
    end
end)

app.cookie_attributes = function()
    local date = require("date")
    local expires = date(true):adddays(30):fmt("${http}")
    return "Expires=" .. expires .. "; Path=/; HttpOnly"
end

app:get("root", "/", function()
    return { render = "spa" }
end)

app:match("login", "/login", respond_to({
    GET = function()
        return { render = "login" }
    end,
    POST = json_params(function(self)
        if self.params.login and self.params.password then
            local ukey = auth.authenticate(self.params.login, self.params.password)

            if ukey then
                self.cookies.ukey = ukey

                return { json = { code = 'OK', redirect_to = self:url_for('root') } }
            end
        end

        return { json = { code = "ERROR", message = "Authorization failed" } }
    end)
}))

app:get("api.list", "/api/list", function(self)
    local hostModel = HostModel:create()
    local hostsList = hostModel:getForUser(self.user.login)
    local portsList = hostModel:getPortsForUser(self.user.login)

    local keyModel = KeyModel:create()
    local keysList = keyModel:getForUser(self.user.login)

    return { json = { hosts = hostsList, ports = portsList, keys = keysList } }
end)

app:post("api.port.add", "/api/port/add", function(self)
    if not self.params.port or not self.params.ssh_port then
        return { json = { code = 'ERROR', message = 'Port is not specified' } }
    end

    local hostModel = HostModel:create()

    if hostModel:isSshPortLocked(self.user.login, self.params.ssh_port) then
        return { json = { code = 'ERROR', message = 'Port is busy' } }
    end

    hostModel:lockSshPort(self.user.login, self.params.port, self.params.ssh_port)

    return { json = { code = 'OK' } }
end)

app:post("api.key.add", "/api/key/add", function(self)
    if not self.params.key then
        return { json = { code = 'ERROR', message = 'Key is not specified' } }
    end

    local keyModel = KeyModel:create()
    keyModel:load()
    keyModel:add(self.user.login, self.params.key)

    return { json = { code = 'OK' } }
end)

app:post("api.host.add", "/api/host/add", function(self)
    if not self.params.host or not self.params.port then
        return { json = { code = 'ERROR', message = 'Host is not specified' } }
    end

    local hostModel = HostModel:create()
    local sshPort = hostModel:getSshPort(self.user.login, self.params.port)

    if not sshPort then
        return { json = { code = 'ERROR', message = 'Port mapping was not found' } }
    end

    hostModel:add(self.user.login, self.params.host, self.params.port, sshPort)

    return { json = { code = 'OK' } }
end)

return app
