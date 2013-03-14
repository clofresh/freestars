local ship = require('src/ship')
local cannon = require('src/cannon')
local furnace = require('src/furnace')
local thruster = require('src/thruster')
local asteroid = require('src/asteroid')

local world

local World = Class{function(self, player, field)
    self.player = player
    self.field = field
end}

function World:init()
    self:initPlayer()
    self:initField()
end

function World:initPlayer()
    local yaw = 4
    local r = 90
    local ox = 13
    local oy = 16
    local equipment = {
        furnace  = furnace.Furnace(1.25, 100, 100, 20),
        thruster = thruster.Thruster(0.50, 1000, 1, 0.05, 0.5),
        cannon   = cannon.Cannon(0.25, 2, 20000, 4, 0.1, 0.5),
        armor    = ship.Armor(100, 3),
    }
    self.player = ship.Ship(images.ship, vector(100, 100), yaw, r, ox, oy, equipment)
end

function World:initField()
    self.field = asteroid.AsteroidField(vector(1, 1), SCREEN.x, SCREEN.y, 8, 50)
end

function World:update(dt)
    self.field:update(dt, self)
    if self.player:isDestroyed() then
        if love.keyboard.isDown("return") then
            self:initPlayer()
        end
    else
        self.player:update(dt, self)
    end
end

function World:draw()
    self.field:draw()
    if self.player:isDestroyed() then
        love.graphics.print("Game over!", 400, 300)
    else
        self.player:draw()
    end
end

function World:checkCollision(self, other)
end

return {
    World = World,
}
