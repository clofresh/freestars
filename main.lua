vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'

images = {}
SCREEN = vector(config.screen.width, config.screen.height)

local ship
local s = require('src/ship')

function love.load()
    images.ship = love.graphics.newImage("mmrnmhrm.png")
    images.torpedo = love.graphics.newImage("torpedo.png")
    local mass = 2
    local energyAttrs = {
        capacity = 100,
        maxCapacity = 100,
        rechargeRate = 5
    }
    local thrustAttrs = {
        force = 1000,
        cost = 1,
        cooldown = 0.05,
        maxWakeAge = 0.5
    }
    local shotAttrs = {
        maxAge = 0.5,
        force = 20000,
        mass = 2,
        cooldown = 0.1,
        cost = 4
    }
    local yaw = 4
    local r = 0
    local ox = 13
    local oy = 16
    local equipment = {
        furnace  = s.Furnace(1.25, 100, 100, 5),
        thruster = s.Thruster(0.50, 1000, 1, 0.05, 0.5),
        cannon   = s.Cannon(0.25, 2, 20000, 4, 0.1, 0.5),
    }
    ship = s.Ship(images.ship, vector(100, 100), yaw, r, ox, oy, equipment)
end

function love.update(dt)
    ship:update(dt)
end

function love.draw()
    ship:draw()
    local ship_x = ship.pos.x % SCREEN.x
    local ship_y = ship.pos.y % SCREEN.y

  love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Energy: %f
]], 
math.floor(collectgarbage('count')),
ship_x,
ship_y,
ship.equipment.furnace.capacity
), 1, 1)

end

