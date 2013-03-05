if aroma then
    love = aroma
    love.mouse = {
        isDown = function() return false end,
        getPosition = function() return nil, nil end
    }
    love.graphics.point = function() end
end

vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'

images = {}
if config then
    SCREEN = vector(config.screen.width, config.screen.height)
else
    SCREEN = vector(640, 480)
end

local player
local ship = require('src/ship')
local cannon = require('src/cannon')
local furnace = require('src/furnace')
local thruster = require('src/thruster')

function love.load()
    images.ship = love.graphics.newImage("mmrnmhrm.png")
    images.torpedo = love.graphics.newImage("torpedo.png")
    local yaw = 4
    local r = 90
    local ox = 13
    local oy = 16
    local equipment = {
        furnace  = furnace.Furnace(1.25, 100, 100, 20),
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

