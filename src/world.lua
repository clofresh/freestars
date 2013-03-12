local world

local World = Class{function(self, player, field)
    self.player = player
    self.field = field
end}

function World:update(dt)
    self.field:update(dt, self)
    self.player:update(dt, self)
end

function World:draw()
    self.field:draw()
    self.player:draw()
end

function World:checkCollision(self, other)
end

return {
    World = World,
}
