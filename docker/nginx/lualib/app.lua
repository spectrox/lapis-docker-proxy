local lapis = require("lapis")
local app = lapis.Application()

KeyModel = require "model/key_model";
HostModel = require "model/host_model";

app:get("/", function()
    local host_model = HostModel:create()
    local hosts_list = host_model:get_list()

    local key_model = KeyModel:create()
    local keys_list = key_model:get_list()

    return { json = { hosts = hosts_list, keys = keys_list } }
end)

app:get("/publish", function(self)
    local keys = KeyModel:create()
    local hosts = HostModel:create()

    keys:add(self.params.key);
    hosts:add(self.params.host, self.params.port, self.params.ssh_port)

    return { json = { success = true } }
end)

return app
