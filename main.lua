vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'

images = {}
SCREEN = vector(config.screen.width, config.screen.height)

local player
local ship = require('src/ship')
local cannon = require('src/cannon')
local furnace = require('src/furnace')
local thruster = require('src/thruster')

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
    local r = 90
    local ox = 13
    local oy = 16
    local equipment = {
        furnace  = furnace.Furnace(1.25, 100, 100, 5),
        thruster = thruster.Thruster(0.50, 1000, 1, 0.05, 0.5),
        cannon   = cannon.Cannon(0.25, 2, 20000, 4, 0.1, 0.5),
    }
    player = ship.Ship(images.ship, vector(100, 100), yaw, r, ox, oy, equipment)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    player:draw()
    local ship_x = player.pos.x % SCREEN.x
    local ship_y = player.pos.y % SCREEN.y

  love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Energy: %f
R: %f
]], 
math.floor(collectgarbage('count')),
ship_x,
ship_y,
player.equipment.furnace.capacity,
player.r
), 1, 1)

end

