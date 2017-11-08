local lapis = require("lapis")
local key_manager = require("helpers/key_manager")
local port_manager = require("helpers/port_manager")
local app = lapis.Application()

app:get("/", function()
    return "Welcome to Lapis " .. require("lapis.version")
end)

app:get("/publish", function(self)
    key_manager.add_key(self.params.key)
    port_manager.add_host(self.params.host, self.params.port, self.params.ssh_port)

    return { json = { success = true } }
end)

return app
