UserModel = {};
UserModel.__index = UserModel

function UserModel:create(id)
    local model = {
        id = id,
        login = "",
        password = "",
    }

    setmetatable(model, UserModel)

    return model
end

function UserModel:getId()
    return self.id
end

function UserModel:getLogin()
    return self.login
end

function UserModel:setLogin(login)
    self.login = login
end

function UserModel:getPassword()
    return self.password
end

function UserModel:setPassword(password)
    self.password = password
end

return UserModel

