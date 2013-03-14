local world

local World = Class{function(self, player, field)
    self.player = player
    self.field = field
end}

function World:update(dt)
    self.field:update(dt, self)
    if not self.player:isDestroyed() then
        self.player:update(dt, self)
    end
end

function World:draw()
    self.field:draw()
    if not self.player:isDestroyed() then
        self.player:draw()
    end
end

function World:checkCollision(self, other)
end

return {
    World = World,
}
