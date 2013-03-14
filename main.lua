vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'
require('src/util')

SCREEN = vector(config.screen.width, config.screen.height)

local World = require('src/world').World
local ship = require('src/ship')
local cannon = require('src/cannon')
local furnace = require('src/furnace')
local thruster = require('src/thruster')
local asteroid = require('src/asteroid')

local world
images = {}

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
        armor    = ship.Armor(100, 3),
    }
    local player = ship.Ship(images.ship, vector(100, 100), yaw, r, ox, oy, equipment)
    local field = asteroid.AsteroidField(vector(1, 1), SCREEN.x, SCREEN.y, 8, 50)
    world = World(player, field)
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end
